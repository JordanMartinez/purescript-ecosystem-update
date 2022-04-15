module Command.Release where

import Prelude

import Constants (bodyOfReleasePrFile, bowerJsonFile, changelogFile, updateBowerJsonReleaseVersionsFile)
import Data.Array (fold)
import Data.Array as Array
import Data.Foldable (foldl, for_)
import Data.Formatter.DateTime (FormatterCommand(..), format)
import Data.HashMap as HM
import Data.List.Types (List(..), (:))
import Data.Maybe (Maybe(..), isJust, maybe')
import Data.Newtype (unwrap)
import Data.String as String
import Data.Version (Version)
import Data.Version as Version
import DependencyGraph (generateAllReleaseInfo, useNextMajorVersion)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (throwException)
import Effect.Now (nowDateTime)
import Node.ChildProcess (ExecOptions)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Partial.Unsafe (unsafeCrashWith)
import Types (GitHubOwner, GitHubProject)
import Utils (execAff', spawnAff, spawnAff', withSpawnResult)

createPrForNextReleaseBatch :: Aff Unit
createPrForNextReleaseBatch = do
  { fullGraph, unfinishedPkgsGraph } <- generateAllReleaseInfo useNextMajorVersion

  let
    jqScriptUpdateBowerWithReleaseVersion = do
      let
        updates = fullGraph # flip foldl [] \acc info -> do
          -- if in registry
          --  "if has("purescript-node-fs") then ."purescript-node-fs" |= "^4.2.0" else . end |"
          -- if not:
          --  "if has("purescript-web-streams") then ."purescript-web-streams" |= "https://github.com/purescript-web/purescript-web-streams.git#^4.2.0" else . end |"
          let
            repo = unwrap info.repo
            owner = unwrap info.owner
            versionStr = Version.showVersion info.version
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
        $ [ "if has(\"dependencies\") then .dependencies |= (" ]
        <> updates
        <>
          [ "  ."
          , ") else . end |"
          , "if has (\"devDependencies\") then .devDependencies |= ("
          ]
        <> updates
        <>
          [ "  ."
          , ") else . end"
          ]

  writeTextFile
    UTF8
    updateBowerJsonReleaseVersionsFile
    jqScriptUpdateBowerWithReleaseVersion

  let
    pkgsInNextBatch = HM.filter (\r -> r.depCount == 0) unfinishedPkgsGraph

  for_ pkgsInNextBatch \info -> do
    log $ "Doing release changes for '" <> unwrap info.pkg <> "'"
    let
      inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
      inRepoDir r = r { cwd = Just $ Path.concat [ "..", unwrap info.owner, unwrap info.repo ]}
    log $ "... resetting to clean state"
    void $ execAff' "git reset --hard HEAD" inRepoDir
    void $ execAff' ("git checkout origin/" <> unwrap info.defaultBranch) inRepoDir
    void $ execAff' "git branch -D test-next-release" inRepoDir
    void $ execAff' "git switch -c test-next-release" inRepoDir
    log $ "... updating bower.json file (if any)"
    updateBowerToReleasedVersions info.owner info.repo
    log $ "... updating changelog file (if any)"
    updateChangelog info.owner info.repo info.version
    log $ "... submitting a PR"
    void $ execAff' "git push -u origin test-next-release" inRepoDir
    absBodyOfReleasePrFile <- liftEffect $ Path.resolve [] bodyOfReleasePrFile
    void $ spawnAff' "gh" (ghPrCreateArgs info absBodyOfReleasePrFile) inRepoDir
    log $ ""
  where
  ghPrCreateArgs info bodyFilePath =
    [ "pr"
    , "create"
    , "--title"
    , "\"Prepare v" <> Version.showVersion info.version <> " release, a PS 0.15.0-compatible release\""
    , "--body-file"
    , bodyFilePath
    , "--label"
    , "purs-0.15"
    ]

updateBowerToReleasedVersions :: GitHubOwner -> GitHubProject -> Aff Unit
updateBowerToReleasedVersions owner repo = whenM (liftEffect $ exists bowerFile) do
  original <- readTextFile UTF8 bowerFile
  result <- withSpawnResult =<< spawnAff "jq" ["--from-file", updateBowerJsonReleaseVersionsFile, "--", bowerFile ]
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