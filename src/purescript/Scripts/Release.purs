module Scripts.Release where

import Prelude

import Constants (bowerJsonFile, changelogFile)
import Data.Argonaut.Decode (decodeJson, parseJson, printJsonDecodeError)
import Data.Array (fold)
import Data.Array as Array
import Data.Either (either, hush)
import Data.Foldable (foldl, for_, maximum)
import Data.Formatter.DateTime (FormatterCommand(..), format)
import Data.HashMap as HM
import Data.HashSet as Set
import Data.List.Types (List(..), (:))
import Data.Maybe (Maybe(..), fromMaybe, isJust, maybe, maybe')
import Data.Newtype (unwrap)
import Data.String as String
import Data.Version (Version)
import Data.Version as Version
import DependencyGraph (findAllTransitiveDeps)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (throw, throwException)
import Effect.Now (nowDateTime)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.ChildProcess (ExecOptions)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Partial.Unsafe (unsafeCrashWith)
import Record as Record
import Type.Proxy (Proxy(..))
import Types (BranchName, GitCloneUrl, GitHubOwner, GitHubProject, Package)
import Utils (execAff', spawnAff, withSpawnResult)

type ReleaseInfo =
  { pkg :: Package
  , repoUrl :: GitCloneUrl
  , repoOrg :: GitHubOwner
  , repoProj :: GitHubProject
  , defaultBranch :: BranchName
  , gitTags :: Array String
  , inBowerRegistry :: Boolean
  , hasBowerJsonFile :: Boolean
  , bowerDependencies :: Array Package
  , bowerDevDependencies :: Array Package
  , hasSpagoDhallFile :: Boolean
  , spagoDependencies :: Array Package
  , hasTestDhallFile :: Boolean
  , spagoTestDependencies :: Array Package
  }

main :: Effect Unit
main = launchAff_ do
  let
    releaseDir = Path.concat [ "files", "release" ]
  releaseInfoContent <- readTextFile UTF8 $ Path.concat [ releaseDir, "next-release-info_2022-04-15T13:28:12.552Z.json" ]
  (releaseInfo :: Object ReleaseInfo) <- either (liftEffect <<< throw <<< printJsonDecodeError) pure $ parseJson releaseInfoContent >>= decodeJson
  let
    parseVersion :: String -> Maybe Version
    parseVersion versionStr =
      fromMaybe versionStr (String.stripPrefix (String.Pattern "v") versionStr)
        # Version.parseVersion
        -- drop any prerelease or build meta info
        # map
          (
            Version.runVersion \mjr mnr p _ _ ->
              Version.version mjr mnr p Nil Nil
          )
        # hush

    releaseInfoWithNextVersion = releaseInfo <#> \v -> v
      # Record.insert
          (Proxy :: Proxy "nextVersion")
          (v.gitTags
            # map parseVersion
            # Array.catMaybes
            # maximum
            # maybe
                (Version.version 1 0 0 Nil Nil)
                Version.bumpMajor
          )
      # Record.delete (Proxy :: Proxy "gitTags")

    fullPackageGraph :: HM.HashMap Package (Set.HashSet Package)
    fullPackageGraph = releaseInfoWithNextVersion # flip foldl HM.empty \acc next -> do
      HM.insert next.pkg (Set.fromFoldable
        if next.hasBowerJsonFile then next.bowerDependencies <> next.bowerDevDependencies
        else if next.hasSpagoDhallFile then next.spagoDependencies <> next.spagoTestDependencies
        else []) acc

    dependencyGraph = findAllTransitiveDeps fullPackageGraph
    allReleaseInfo = dependencyGraph # HM.toArrayBy \k v ->
      case Object.lookup (unwrap k) releaseInfoWithNextVersion of
        Nothing -> unsafeCrashWith $ "Impossible happened: '" <> unwrap k <> "' does not exist in object map."
        Just { pkg, repoUrl, repoOrg, repoProj, inBowerRegistry, nextVersion, defaultBranch } ->
          { pkg
          , repoUrl
          , owner: repoOrg
          , repo: repoProj
          , defaultBranch
          , nextVersion
          , inBowerRegistry
          , dependencies: Set.toArray v
          }

    jqScriptUpdateBowerWithReleaseVersion = do
      let
        header = "if has(\"dependencies\") then .dependencies |= ("
        separatorLines =
          [ "  ."
          , ") else . end |"
          , "if has (\"devDependencies\") then .devDependencies |= ("
          ]
        footer =
          [ "  ."
          , ") else . end"
          ]
        updates = allReleaseInfo # flip foldl [] \acc info -> do
          -- if in registry
          --  "if has("purescript-node-fs") then ."purescript-node-fs" |= "^4.2.0" else . end |"
          -- if not:
          --  "if has("purescript-web-streams") then ."purescript-web-streams" |= "https://github.com/purescript-web/purescript-web-streams.git#^4.2.0" else . end |"
          let
            repo = unwrap info.repo
            owner = unwrap info.owner
            versionStr = Version.showVersion info.nextVersion
          Array.snoc acc $ fold
              [ "  if has(\""
              , repo
              , "\") then .\""
              , repo
              , "\" |= \""
              , if info.inBowerRegistry then "^" <> versionStr
                else "https://github.com/" <> owner <> "/" <> repo <> ".git#^" <> versionStr
              , "\" else . end |"
              ]
      Array.intercalate "\n"
        $ Array.singleton header
        <> updates
        <> separatorLines
        <> updates
        <> footer

  writeTextFile
    UTF8
    jqScriptUpdateBowerToReleasedVersionFile
    jqScriptUpdateBowerWithReleaseVersion

  for_ allReleaseInfo \info -> do
    log $ "Doing release changes for '" <> unwrap info.pkg <> "'"
    let
      inRepoDir :: ExecOptions -> ExecOptions
      inRepoDir r = r { cwd = Just $ Path.concat [ "..", unwrap info.owner, unwrap info.repo ]}
    log $ "... resetting to clean state"
    void $ execAff' "git reset --hard HEAD" inRepoDir
    void $ execAff' ("git checkout origin/" <> unwrap info.defaultBranch) inRepoDir
    void $ execAff' "git branch -D test-next-release" inRepoDir
    void $ execAff' "git switch -c test-next-release" inRepoDir
    log $ "... updating bower.json file (if any)"
    updateBowerToReleasedVersions info.owner info.repo
    log $ "... updating changelog file (if any)"
    updateChangelog info.owner info.repo info.nextVersion
    log $ ""

jqScriptUpdateBowerToReleasedVersionFile :: FilePath
jqScriptUpdateBowerToReleasedVersionFile =
  Path.concat [ "src", "jq", "update-bower-json-release-versions.txt"]

updateBowerToReleasedVersions :: GitHubOwner -> GitHubProject -> Aff Unit
updateBowerToReleasedVersions owner repo = whenM (liftEffect $ exists bowerFile) do
  original <- readTextFile UTF8 bowerFile
  result <- withSpawnResult =<< spawnAff "jq" ["--from-file", jqScriptUpdateBowerToReleasedVersionFile, "--", bowerFile ]
  let new = result.stdout
  -- easiest way to check whether a change has occurred
  when (original /= new) do
    writeTextFile UTF8 bowerFile result.stdout
    gitAddResult <- execAff' ("git add " <> bowerJsonFile) inRepoDir
    for_ gitAddResult.error (liftEffect <<< throwException)
    gitCommitResult <- execAff' "git commit -m \"Update the bower dependencies\"" inRepoDir
    for_ gitCommitResult.error (liftEffect <<< throwException)
  where
  owner' = unwrap owner
  repo' = unwrap repo
  repoDir = Path.concat ["..", owner', repo']
  inRepoDir :: ExecOptions -> ExecOptions
  inRepoDir r = r { cwd = Just repoDir }
  bowerFile = Path.concat [ repoDir, bowerJsonFile ]

updateChangelog :: GitHubOwner -> GitHubProject -> Version -> Aff Unit
updateChangelog owner repo nextVersion = whenM (liftEffect $ exists clFilePath) do
  original <- readTextFile UTF8 clFilePath
  let
    lines = String.split (String.Pattern "\n") original
    unreleasedHeaderIdx = maybe' (\_ -> unsafeCrashWith $ "Could not find unreleased header for " <> repoDir) identity do
      Array.findIndex (isJust <<< String.stripPrefix (String.Pattern "##")) lines
    { before, after } = Array.splitAt (unreleasedHeaderIdx + 1) lines

  todayDateStr <- map (formatYYYYMMDD) $ liftEffect nowDateTime
  let
    new = Array.intercalate "\n"
      $ before
      <> unreleasedSectionContent
      <> nextReleaseHeader todayDateStr
      <> after

  when (original /= new) do
    writeTextFile UTF8 clFilePath new
    gitAddResult <- execAff' ("git add " <> changelogFile) (_ { cwd = Just repoDir })
    for_ gitAddResult.error (liftEffect <<< throwException)
    gitCommitResult <- execAff' "git commit -m \"Update the changelog\"" (_ { cwd = Just repoDir })
    for_ gitCommitResult.error (liftEffect <<< throwException)
  where
  owner' = unwrap owner
  repo' = unwrap repo
  repoDir = Path.concat ["..", owner', repo']
  clFilePath = Path.concat [ repoDir, changelogFile ]
  formatYYYYMMDD = format
    $ YearFull
    : Placeholder "-"
    : MonthTwoDigits
    : Placeholder "-"
    : DayOfMonthTwoDigits
    : Nil
  nextReleaseHeader todayDateStr = Array.singleton $ fold
    [ "## [v"
    , versionStr
    , "](https://github.com/"
    , owner'
    , "/"
    , repo'
    , "/releases/tag/v"
    , versionStr
    , ") - "
    , todayDateStr
    ]
  versionStr = Version.showVersion nextVersion

  unreleasedSectionContent =
    [ ""
    , "Breaking changes:"
    , ""
    , "New features:"
    , "Bugfixes:"
    , ""
    , "Other improvements:"
    , ""
    ]