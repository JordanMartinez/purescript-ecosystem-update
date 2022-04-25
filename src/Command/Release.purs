module Command.Release where

import Prelude

import Constants (jqScripts, libDir, repoFiles)
import Data.Array (elem, find, fold)
import Data.Array as Array
import Data.Foldable (for_)
import Data.Formatter.DateTime (FormatterCommand(..), format)
import Data.HashMap as HM
import Data.List.Types (List(..), (:))
import Data.Maybe (Maybe(..), isJust, maybe, maybe')
import Data.Newtype (unwrap)
import Data.String (Pattern(..), Replacement(..))
import Data.String as String
import Data.Version (Version)
import Data.Version as Version
import DependencyGraph (generateAllReleaseInfo, useNextMajorVersion)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Effect.Now (nowDateTime)
import Node.ChildProcess (ExecOptions)
import Node.ChildProcess as CP
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, unlink, writeTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Node.Stream as Stream
import Partial.Unsafe (unsafeCrashWith)
import Tools.Jq (updateBowerDepsJqScript)
import Types (BranchName, GitHubOwner, GitHubProject, Package)
import Utils (SpawnExit(..), execAff', spawnAff, spawnAff', splitLines, throwIfExecErrored, throwIfSpawnErrored, withSpawnResult)

createPrForNextReleaseBatch :: { submitPr :: Boolean, branchName :: Maybe BranchName, deleteBranchIfExist :: Boolean, keepPrBody :: Boolean } -> Aff Unit
createPrForNextReleaseBatch { submitPr, branchName, deleteBranchIfExist, keepPrBody } = do
  { fullGraph, unfinishedPkgsGraph } <- generateAllReleaseInfo useNextMajorVersion
  writeTextFile UTF8 jqScripts.updateBowerDepsToReleaseVersion
    $ updateBowerDepsJqScript (append "v" <<< Version.showVersion) fullGraph

  let
    -- pkgsInNextBatch = HM.filter (\r -> Array.elem (unwrap r.pkg) ["now", "web-touchevents"]) unfinishedPkgsGraph
    pkgsInNextBatch = HM.filter (\r -> r.depCount == 0) unfinishedPkgsGraph
    -- pkgsInNextBatch = unfinishedPkgsGraph

  for_ pkgsInNextBatch makeRelease
  where
  releaseBranchName = maybe "next-release" unwrap branchName
  makeRelease info = do
    log $ "## Doing release changes for '" <> unwrap info.pkg <> "'"
    -- only prepare and submit PR if branch name doesn't already exist on remote
    -- as we may have already submitted a PR but not gotten it merged yet.
    branchResult <- execAff' "git branch -r" inRepoDir
    throwIfExecErrored branchResult
    let
      prAlreadySubmitted =
        branchResult.stdout
          # splitLines
          # map String.trim
          # elem ("origin/" <> releaseBranchName)
    if prAlreadySubmitted then do
      log "... PR already submitted. Skipping."
    else do
      log $ "... resetting to clean state"
      throwIfExecErrored =<< execAff' "git reset --hard HEAD" inRepoDir
      throwIfExecErrored =<< execAff' ("git checkout upstream/" <> unwrap info.defaultBranch) inRepoDir
      when deleteBranchIfExist do
        localBranchResult <- execAff' "git branch" inRepoDir
        throwIfExecErrored localBranchResult
        when (isJust $ find ((==) releaseBranchName <<< String.drop 2) $ splitLines localBranchResult.stdout) do
          void $ execAff' ("git branch -D " <> releaseBranchName) inRepoDir
      throwIfExecErrored =<< execAff' ("git switch -c " <> releaseBranchName) inRepoDir
      log $ "... updating bower.json file (if any)"
      bowerStatus <- updateBowerToReleasedVersions info.pkg
      log $ "... updating CI's node version to 14 (if needed)"
      nodeStatus <- updateNode info.pkg
      log $ "... updating changelog file (if any)"
      changelogStatus <- updateChangelog info.owner info.repo info.pkg info.version
      log $ "... preparing PR"
      releaseBodyUri <- do
        let
          content = case changelogStatus of
            FileChanged x -> x
            _ -> "First release compatible with PureScript 0.15.0"
        cp <- spawnAff "jq" ["--slurp", "--raw-input", "--raw-output", "@uri" ]
        liftEffect $ void $ Stream.writeString (CP.stdin cp) UTF8 content (pure unit)
        liftEffect $ void $ Stream.end (CP.stdin cp) (pure unit)
        jqResult <- withSpawnResult cp
        throwIfSpawnErrored jqResult
        when (jqResult.exit /= Exited 0) do
          liftEffect $ throw $ "jq exited with error: " <> show jqResult.exit
        pure $ jqResult.stdout
          # String.replaceAll (Pattern "(") (Replacement "%28")
          # String.replaceAll (Pattern ")") (Replacement "%29")
          # String.replaceAll (Pattern "[") (Replacement "%5B")
          # String.replaceAll (Pattern "]") (Replacement "%5D")
      withBodyPrFile bowerStatus nodeStatus changelogStatus releaseBodyUri \bodyPrFilePath -> do
        if submitPr then do
          log $ "... submitting PR"
          throwIfExecErrored =<< execAff' ("git push -f -u origin " <> releaseBranchName) inRepoDir
          result <- withSpawnResult =<< spawnAff' "gh" (ghPrCreateArgs bodyPrFilePath) inRepoDir
          log $ result.stdout
          log $ result.stderr
        else do
          log "... not submitting PR. Rerun with the `--submit-pr` flag."
      log $ ""
    where
    owner' = unwrap info.owner
    repo' = unwrap info.repo
    pkg' = unwrap info.pkg
    version' = "v" <> Version.showVersion info.version
    repoDir = Path.concat [ libDir, pkg' ]
    inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
    inRepoDir r = r { cwd = Just repoDir }

    withBodyPrFile bowerStatus nodeStatus changelogStatus releaseBodyUri runAction = do
      absPath <- liftEffect $ Path.resolve [] $ Path.concat [ repoDir, "pr-body.txt" ]
      writeTextFile UTF8 absPath $ Array.intercalate "\n" $ prBodyLines bowerStatus nodeStatus changelogStatus releaseBodyUri
      runAction absPath
      unless keepPrBody $ unlink absPath
    ghPrCreateArgs bodyFilePath =
      [ "pr"
      , "create"
      , "--title"
      , "Prepare v" <> Version.showVersion info.version <> " release (1st PS 0.15.0-compatible release)"
      , "--body-file"
      , bodyFilePath
      , "--label"
      , "purs-0.15"
      ]
    prBodyLines bowerStatus nodeStatus changelogStatus releaseBodyUri =
      [ "**Description of the change**"
      , ""
      , "Backlinking to purescript/purescript#4244. Prepares project for first release that is compatible with PureScript v0.15.0."
      , ""
      , ":robot: This is an automated pull request to prepare the next release of this library. PR was created via the [Release.purs](https://github.com/JordanMartinez/purescript-ecosystem-update/blob/master/src/purescript/Command/Release.purs) file. Some of the following steps are already done; others should be performed by a human once the pull request is merged:"
      , ""
      ]
      <> bowerPart
      <> nodePart
      <> changelogPart
      <>
        [ "- [ ] Publish a GitHub [release](" <> newReleaseUrl releaseBodyUri <> ")."
        , "- [ ] Upload the release to Pursuit with `pulp publish`."
        ]
      where
      bowerPart = case bowerStatus of
        FileDoesNotExist _ -> [ "- [x] Bower dependencies: `bower.json` file does not exist." ]
        FileHadNoChanges _ -> [ "- [x] Bower dependencies: no changes needed." ]
        FileChanged _ -> [ "- [x] Updated bower dependencies to 0.15.0-compatible versions" ]
      nodePart = case nodeStatus of
        FileDoesNotExist x -> absurd x
        FileHadNoChanges _ -> [ "- [x] ci.yml: Node already set to 14." ]
        FileChanged _ -> [ "- [x] ci.yml: Node updated to 14." ]
      changelogPart = case changelogStatus of
        FileDoesNotExist _ -> [ "- [x] Changelog: `CHANGELOG.md` file does not exist. This should be investigated further." ]
        FileHadNoChanges _ -> [ "- [x] Changelog: file had no changes. This should be investigated further if not `aff-promise`." ]
        FileChanged _ -> [ "- [x] Updated changelog" ]
    newReleaseUrl releaseBodyUri = fold
      [ "https://github.com/"
      , owner'
      , "/"
      , repo'
      , "/releases/new?tag="
      , version'
      , "&title="
      , version'
      , "&body="
      , releaseBodyUri
      ]

data FileStatus exist noChanges changed
  = FileDoesNotExist exist
  | FileHadNoChanges noChanges
  | FileChanged changed

data ChangeReason
  = FileAdded
  | FileRegenerated

derive instance (Eq a, Eq b, Eq c) => Eq (FileStatus a b c)
derive instance (Ord a, Ord b, Ord c) => Ord (FileStatus a b c)

updateBowerToReleasedVersions :: Package -> Aff (FileStatus Unit Unit Unit)
updateBowerToReleasedVersions pkg = do
  fileExists <- liftEffect $ exists bowerFile
  if fileExists then do
    original <- readTextFile UTF8 bowerFile
    result <- withSpawnResult =<< spawnAff "jq" ["--from-file", jqScripts.updateBowerDepsToReleaseVersion, "--", bowerFile ]
    throwIfSpawnErrored result
    let new = result.stdout
    -- easiest way to check whether a change has occurred
    if (original /= new) then do
      writeTextFile UTF8 bowerFile new
      throwIfExecErrored =<< execAff' ("git add " <> repoFiles.bowerJsonFile) inRepoDir
      throwIfExecErrored =<< execAff' "git commit -m \"Update the bower dependencies\"" inRepoDir
      pure $ FileChanged unit
    else do
      pure $ FileHadNoChanges unit
  else do
    pure $ FileDoesNotExist unit
  where
  pkg' = unwrap pkg
  repoDir = Path.concat [ libDir, pkg']
  inRepoDir :: ExecOptions -> ExecOptions
  inRepoDir r = r { cwd = Just repoDir }
  bowerFile = Path.concat [ repoDir, repoFiles.bowerJsonFile ]

updateNode :: Package -> Aff (FileStatus Void Unit Unit)
updateNode pkg = do
  fileExists <- liftEffect $ exists ciFile
  unless fileExists do
    liftEffect $ throw $ ciFile <> " does not exist."
  original <- readTextFile UTF8 ciFile
  let
    new =
      original
        # String.replace (Pattern "uses: actions/setup-node@v1") (Replacement "uses: actions/setup-node@v2")
        # String.replace (Pattern "node-version: \"12\"") (Replacement "node-version: \"14.x\"")
  if original == new then do
    pure $ FileHadNoChanges unit
  else do
    writeTextFile UTF8 ciFile new
    throwIfExecErrored =<< execAff' ("git add " <> repoFiles.ciYmlFile) inRepoDir
    throwIfExecErrored =<< execAff' "git commit -m \"Update Node to 14 in CI\"" inRepoDir
    pure $ FileChanged unit
  where
  pkg' = unwrap pkg
  repoDir = Path.concat [ libDir, pkg']
  ciFile = Path.concat [ repoDir, repoFiles.ciYmlFile ]
  inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
  inRepoDir r = r { cwd = Just repoDir }

updateChangelog :: GitHubOwner -> GitHubProject -> Package -> Version -> Aff (FileStatus Unit Unit String)
updateChangelog owner repo pkg nextVersion = do
  fileExists <- liftEffect $ exists clFilePath
  if fileExists then do
    original <- readTextFile UTF8 clFilePath
    todayDateStr <- map (formatYYYYMMDD) $ liftEffect nowDateTime
    let
      updateChangeLogIfDifferent releaseContents newContent
        | original == newContent = pure $ FileHadNoChanges unit
        | otherwise = do
            writeTextFile UTF8 clFilePath newContent
            throwIfExecErrored =<< execAff' ("git add " <> repoFiles.changelogFile) (_ { cwd = Just repoDir })
            throwIfExecErrored =<< execAff' "git commit -m \"Update the changelog\"" (_ { cwd = Just repoDir })
            pure $ FileChanged
              $ Array.intercalate "\n"
              $ Array.reverse
              $ Array.dropWhile (\s -> String.trim s == "")
              $ Array.reverse
              $ Array.dropWhile (\s -> String.trim s == "")
              $ releaseContents

      isVersionHeader = isJust <<< String.stripPrefix (Pattern "##")
      lines = splitLines original
      { before: prefaceAndUnreleasedHdr, after: changeLogContent } =
        maybe' (\_ -> unsafeCrashWith $ "Could not find unreleased header for " <> repoDir) identity do
          unreleasedHeaderIdx <- Array.findIndex isVersionHeader lines
          pure $ Array.splitAt (unreleasedHeaderIdx + 1) lines

    case map (\idx -> Array.splitAt idx changeLogContent) $ Array.findIndex isVersionHeader changeLogContent of
      Nothing -> do
        let
          releaseContents =
            [ ""
            , "Initial release"
            ]
          newContent = Array.intercalate "\n"
            $ prefaceAndUnreleasedHdr
            <> unreleasedSectionContent
            <> nextReleaseHeader todayDateStr
            <> releaseContents

        updateChangeLogIfDifferent releaseContents newContent
      Just { before: releaseContents, after: remainingChangeLogContent } -> do
        let
          newContent = Array.intercalate "\n"
            $ prefaceAndUnreleasedHdr
            <> unreleasedSectionContent
            <> nextReleaseHeader todayDateStr
            <> releaseContents
            <> remainingChangeLogContent

        updateChangeLogIfDifferent releaseContents newContent
  else do
    pure $ FileDoesNotExist unit
  where
  owner' = unwrap owner
  repo' = unwrap repo
  pkg' = unwrap pkg
  repoDir = Path.concat [ libDir, pkg']
  clFilePath = Path.concat [ repoDir, repoFiles.changelogFile ]
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

unreleasedSectionContent :: Array String
unreleasedSectionContent =
  [ ""
  , "Breaking changes:"
  , ""
  , "New features:"
  , ""
  , "Bugfixes:"
  , ""
  , "Other improvements:"
  , ""
  ]