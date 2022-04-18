module Command.Release where

import Prelude

import Constants (bowerJsonFile, changelogFile, ciYmlFile, updateBowerJsonReleaseVersionsFile)
import Data.Array (fold)
import Data.Array as Array
import Data.Either (either)
import Data.Foldable (foldl, for_)
import Data.Formatter.DateTime (FormatterCommand(..), format)
import Data.HashMap as HM
import Data.List.Types (List(..), (:))
import Data.Maybe (Maybe(..), fromMaybe, isJust, maybe, maybe')
import Data.Monoid (power)
import Data.Newtype (unwrap)
import Data.String (codePointFromChar)
import Data.String as String
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (multiline)
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
import Types (GitHubOwner, GitHubProject)
import Utils (SpawnExit(..), execAff', spawnAff, spawnAff', throwIfExecErrored, throwIfSpawnErrored, withSpawnResult)

createPrForNextReleaseBatch :: { noDryRun :: Boolean } -> Aff Unit
createPrForNextReleaseBatch { noDryRun } = do
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
    -- pkgsInNextBatch = HM.filter (\r -> r.pkg == Package "prelude") unfinishedPkgsGraph
    pkgsInNextBatch = HM.filter (\r -> r.depCount == 0) unfinishedPkgsGraph

  for_ pkgsInNextBatch makeRelease
  where
  makeRelease info = do
    log $ "## Doing release changes for '" <> unwrap info.pkg <> "'"
    log $ "... resetting to clean state"
    void $ execAff' "git reset --hard HEAD" inRepoDir
    void $ execAff' ("git checkout origin/" <> unwrap info.defaultBranch) inRepoDir
    void $ execAff' "git reset --hard HEAD" inRepoDir
    void $ execAff' ("git branch -D " <> releaseBranchName) inRepoDir
    void $ execAff' ("git switch -c " <> releaseBranchName) inRepoDir
    log $ "... updating bower.json file (if any)"
    bowerUpdated <- updateBowerToReleasedVersions info.owner info.repo
    log $ "... updating `ci.yml` file to include `purs-tidy` (if needed)"
    pursTidyAdded <- ensurePursTidyAdded info.owner info.repo
    log $ "... updating changelog file (if any)"
    releaseBody <- updateChangelog info.owner info.repo info.version
    log $ "... preparing PR"
    releaseBodyUri <- do
      let
        content = fromMaybe "First release compatible with PureScript 0.15.0" releaseBody
      cp <- spawnAff "jq" ["--slurp", "--raw-input", "--raw-output", "@uri" ]
      liftEffect $ void $ Stream.writeString (CP.stdin cp) UTF8 content (pure unit)
      liftEffect $ void $ Stream.end (CP.stdin cp) (pure unit)
      jqResult <- withSpawnResult cp
      throwIfSpawnErrored jqResult
      when (jqResult.exit /= Exited 0) do
        liftEffect $ throw $ "jq exited with error: " <> show jqResult.exit
      pure $ jqResult.stdout
    withBodyPrFile bowerUpdated pursTidyAdded releaseBody releaseBodyUri \bodyPrFilePath -> do
      log $ "... submitting PR"
      if noDryRun then do
        void $ execAff' ("git push -f -u origin " <> releaseBranchName) inRepoDir
        result <- withSpawnResult =<< spawnAff' "gh" (ghPrCreateArgs bodyPrFilePath) inRepoDir
        log $ result.stdout
        log $ result.stderr
      else do
        log "....... Ran `peu` without the `--no-dry-run` flag. So, no PR will be submitted."
    log $ ""
    where
    owner' = unwrap info.owner
    repo' = unwrap info.repo
    version' = "v" <> Version.showVersion info.version
    repoDir = Path.concat [ "..", owner', repo' ]
    inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
    inRepoDir r = r { cwd = Just repoDir }
    releaseBranchName = "test-next-release"

    withBodyPrFile bowerChanged pursTidyAdded releaseBody releaseBodyUri runAction = do
      absPath <- liftEffect $ Path.resolve [] $ Path.concat [ repoDir, "pr-body.txt" ]
      writeTextFile UTF8 absPath $ Array.intercalate "\n" $ prBodyLines bowerChanged pursTidyAdded releaseBody releaseBodyUri
      runAction absPath
      unlink absPath
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
    prBodyLines bowerChanged pursTidyAdded releaseBody releaseBodyUri =
      [ "**Description of the change**"
      , ""
      , "Backlinking to purescript/purescript#4244. Prepares project for first release that is compatible with PureScript v0.15.0."
      , ""
      , ":robot: This is an automated pull request to prepare the next release of this library. PR was created via the [Release.purs](https://github.com/JordanMartinez/purescript-ecosystem-update/blob/master/src/purescript/Command/Release.purs) file. Some of the following steps are already done; others should be performed by a human once the pull request is merged:"
      , ""
      ]
      <> (Array.singleton $ if bowerChanged then "- [x] Updated bower dependencies to 0.15.0-compatible versions"
        else "- [x] Bower dependencies: either no changes needed or `bower.json` file does not exist.")
      <> (if pursTidyAdded then ["- [x] `purs-tidy` added to CI and used to format `src` and `test` dirs (if applicable)"] else [])
      <> (maybe [] (const ["- [x] Updated changelog"]) releaseBody)
      <>
        [ "- [ ] Publish a GitHub [release](" <> newReleaseUrl releaseBodyUri <> ")."
        , "- [ ] Upload the release to Pursuit with `pulp publish`."
        ]
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

updateBowerToReleasedVersions :: GitHubOwner -> GitHubProject -> Aff Boolean
updateBowerToReleasedVersions owner repo = do
  fileExists <- liftEffect $ exists bowerFile
  if fileExists then do
    original <- readTextFile UTF8 bowerFile
    result <- withSpawnResult =<< spawnAff "jq" ["--from-file", updateBowerJsonReleaseVersionsFile, "--", bowerFile ]
    let new = result.stdout
    -- easiest way to check whether a change has occurred
    if (original /= new) then do
      writeTextFile UTF8 bowerFile result.stdout
      gitAddResult <- execAff' ("git add " <> bowerJsonFile) inRepoDir
      throwIfExecErrored gitAddResult
      gitCommitResult <- execAff' "git commit -m \"Update the bower dependencies\"" inRepoDir
      throwIfExecErrored gitCommitResult
      pure true
    else do
      pure false
  else do
    pure false
  where
  owner' = unwrap owner
  repo' = unwrap repo
  repoDir = Path.concat ["..", owner', repo']
  inRepoDir :: ExecOptions -> ExecOptions
  inRepoDir r = r { cwd = Just repoDir }
  bowerFile = Path.concat [ repoDir, bowerJsonFile ]

ensurePursTidyAdded :: GitHubOwner -> GitHubProject -> Aff Boolean
ensurePursTidyAdded owner repo = do
  fileExists <- liftEffect $ exists ciFile
  if fileExists then do
    original <- readTextFile UTF8 ciFile
    let
      -- the colon below is what separates the configuration of purs-tidy
      -- from its usage
      pursTidyConfigLine = either (\_ -> unsafeCrashWith "invalid regex") identity
        $ regex "^( +)purs-tidy: \"[^\"]+\"( +)?$" multiline
    if test pursTidyConfigLine original then do
      pure false
    else do
      let
        justOrCrash :: forall a. String -> Maybe a -> a
        justOrCrash msg = maybe' (\_ -> unsafeCrashWith msg) identity
        rightOrCrash msg = either (\_ -> unsafeCrashWith msg) identity
        lines = String.split (String.Pattern "\n") original
        setupPsLineRegex = rightOrCrash "invalid regex for setupPsLine"
          $ regex "^( +)(- )?uses: purescript-contrib/setup-purescript" multiline
        withLineRegex = rightOrCrash "invalid regex for withLine"
          $ regex "^( +)with:" multiline

        new :: String
        new = justOrCrash "" do
          setupPsIdx <- Array.findIndex (test setupPsLineRegex) lines
          let { after: postSetup } = Array.splitAt setupPsIdx lines
          withIdx <- Array.findIndex (test withLineRegex) postSetup
          let { after: postWith } = Array.splitAt withIdx postSetup
          firstBlankLineIdx <- Array.findIndex (\s -> String.trim s == "") postWith
          let { before, after } = Array.splitAt (setupPsIdx + withIdx + firstBlankLineIdx) lines
          withLine <- Array.index postSetup withIdx
          let
            numOfSpaces = String.length $ String.takeWhile (\cp -> cp == codePointFromChar ' ') withLine
            firstEntryIndent = power " " (numOfSpaces - 2)
            entryIndent = firstEntryIndent <> "  "
            optionIndent = entryIndent <> "  "
          pure $ Array.intercalate "\n"
            $ before
            <> Array.singleton (optionIndent <> "purs-tidy: \"latest\"")
            <> (Array.reverse $ Array.dropWhile (\s -> String.trim s == "") $ Array.reverse after)
            <>
              [""
              , firstEntryIndent <> "- name: Check formatting"
              , entryIndent <> "run: purs-tidy check src test"
              , ""
              ]

      -- easiest way to check whether a change has occurred
      if (original /= new) then do
        writeTextFile UTF8 ciFile new
        gitCiAddResult <- execAff' ("git add " <> ciYmlFile) inRepoDir
        throwIfExecErrored gitCiAddResult
        gitCiCommitResult <- execAff' "git commit -m \"Add purs-tidy\"" inRepoDir
        throwIfExecErrored gitCiCommitResult

        ptResult <- execAff' ("purs-tidy format-in-place src test") inRepoDir
        throwIfExecErrored ptResult

        gitDiff <- execAff' ("git diff --shortstat") inRepoDir
        throwIfExecErrored gitDiff
        when (String.trim gitDiff.stdout /= "") do
          gitAddSrcResult <- execAff' ("git add src/") inRepoDir
          throwIfExecErrored gitAddSrcResult
          whenM (liftEffect $ exists $ Path.concat [ repoDir, "test"]) do
            gitAddTestResult <- execAff' ("git add test/") inRepoDir
            throwIfExecErrored gitAddTestResult
          gitCommitPtResult <- execAff' "git commit -m \"Formatted code via purs-tidy\"" inRepoDir
          throwIfExecErrored gitCommitPtResult
        pure true
      else do
        pure false
  else do
    pure false
  where
  owner' = unwrap owner
  repo' = unwrap repo
  repoDir = Path.concat ["..", owner', repo']
  inRepoDir :: ExecOptions -> ExecOptions
  inRepoDir r = r { cwd = Just repoDir }
  ciFile = Path.concat [ repoDir, ciYmlFile ]

updateChangelog :: GitHubOwner -> GitHubProject -> Version -> Aff (Maybe String)
updateChangelog owner repo nextVersion = do
  fileExists <- liftEffect $ exists clFilePath
  if fileExists then do
    original <- readTextFile UTF8 clFilePath
    todayDateStr <- map (formatYYYYMMDD) $ liftEffect nowDateTime
    let
      updateChangeLogIfDifferent releaseContents newContent
        | original == newContent = pure Nothing
        | otherwise = do
            writeTextFile UTF8 clFilePath newContent
            gitAddResult <- execAff' ("git add " <> changelogFile) (_ { cwd = Just repoDir })
            throwIfExecErrored gitAddResult
            gitCommitResult <- execAff' "git commit -m \"Update the changelog\"" (_ { cwd = Just repoDir })
            throwIfExecErrored gitCommitResult
            pure $ Just
              $ Array.intercalate "\n"
              $ Array.reverse
              $ Array.dropWhile (\s -> String.trim s == "")
              $ Array.reverse
              $ Array.dropWhile (\s -> String.trim s == "")
              $ releaseContents

      isVersionHeader = isJust <<< String.stripPrefix (String.Pattern "##")
      lines = String.split (String.Pattern "\n") original
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
    pure Nothing
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
    , ""
    , "Bugfixes:"
    , ""
    , "Other improvements:"
    , ""
    ]