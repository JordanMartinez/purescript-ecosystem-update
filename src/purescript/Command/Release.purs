module Command.Release where

import Prelude

import Constants (jqScripts, libDir, pursTidyFiles, repoFiles)
import Data.Array (fold)
import Data.Array as Array
import Data.Either (either)
import Data.Foldable (foldl, for_)
import Data.Formatter.DateTime (FormatterCommand(..), format)
import Data.HashMap as HM
import Data.List.Types (List(..), (:))
import Data.Maybe (Maybe(..), isJust, maybe, maybe')
import Data.Monoid (power)
import Data.Newtype (unwrap)
import Data.String (codePointFromChar)
import Data.String as String
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (multiline)
import Data.Tuple (Tuple(..))
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
import Node.FS.Aff (appendTextFile, readTextFile, readdir, unlink, writeTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Node.Stream as Stream
import Partial.Unsafe (unsafeCrashWith)
import Types (BranchName, GitHubOwner, GitHubProject, Package)
import Utils (SpawnExit(..), copyFile, execAff', spawnAff, spawnAff', throwIfExecErrored, throwIfSpawnErrored, withSpawnResult)

createPrForNextReleaseBatch :: { submitPr :: Boolean, branchName :: Maybe BranchName } -> Aff Unit
createPrForNextReleaseBatch { submitPr, branchName } = do
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
    jqScripts.updateBowerDepsToReleaseVersion
    jqScriptUpdateBowerWithReleaseVersion

  let
    -- pkgsInNextBatch = HM.filter (\r -> r.pkg == Package "prelude") unfinishedPkgsGraph
    pkgsInNextBatch = HM.filter (\r -> r.depCount == 0) unfinishedPkgsGraph

  for_ pkgsInNextBatch makeRelease
  where
  releaseBranchName = maybe "next-release" unwrap branchName
  makeRelease info = do
    log $ "## Doing release changes for '" <> unwrap info.pkg <> "'"
    log $ "... resetting to clean state"
    void $ execAff' "git reset --hard HEAD" inRepoDir
    void $ execAff' ("git checkout upstream/" <> unwrap info.defaultBranch) inRepoDir
    void $ execAff' ("git switch -c " <> releaseBranchName) inRepoDir
    log $ "... updating `ci.yml` file to include `purs-tidy` (if needed)"
    pursTidyStatus <- ensurePursTidyAdded info.pkg
    log $ "... updating bower.json file (if any)"
    bowerStatus <- updateBowerToReleasedVersions info.pkg
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
        # String.replaceAll (String.Pattern "(") (String.Replacement "%28")
        # String.replaceAll (String.Pattern ")") (String.Replacement "%29")
        # String.replaceAll (String.Pattern "[") (String.Replacement "%5B")
        # String.replaceAll (String.Pattern "]") (String.Replacement "%5D")
    withBodyPrFile bowerStatus pursTidyStatus changelogStatus releaseBodyUri \bodyPrFilePath -> do
      if submitPr then do
        log $ "... submitting PR"
        void $ execAff' ("git push -f -u upstream " <> releaseBranchName) inRepoDir
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

    withBodyPrFile bowerStatus pursTidyStatus changelogStatus releaseBodyUri runAction = do
      absPath <- liftEffect $ Path.resolve [] $ Path.concat [ repoDir, "pr-body.txt" ]
      writeTextFile UTF8 absPath $ Array.intercalate "\n" $ prBodyLines bowerStatus pursTidyStatus changelogStatus releaseBodyUri
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
    prBodyLines bowerStatus pursTidyStatus changelogStatus releaseBodyUri =
      [ "**Description of the change**"
      , ""
      , "Backlinking to purescript/purescript#4244. Prepares project for first release that is compatible with PureScript v0.15.0."
      , ""
      , ":robot: This is an automated pull request to prepare the next release of this library. PR was created via the [Release.purs](https://github.com/JordanMartinez/purescript-ecosystem-update/blob/master/src/purescript/Command/Release.purs) file. Some of the following steps are already done; others should be performed by a human once the pull request is merged:"
      , ""
      ]
      <> tidyOpPart
      <> tidyRcPart
      <> formattingPart
      <> pursTidyCiPart
      <> bowerPart
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
      tidyOpPart = case pursTidyStatus.tidyOpFileStatus of
        FileDoesNotExist x -> absurd x
        FileHadNoChanges _ -> [ "- [x] .tidyoperators: No change needed" ]
        FileChanged FileRegenerated -> [ "- [x] .tidyoperators: File regenerated." ]
        FileChanged FileAdded -> [ "- [x] .tidyoperators: File added" ]
      tidyRcPart = case pursTidyStatus.tidyRcFileStatus of
        FileDoesNotExist x -> absurd x
        FileHadNoChanges _ -> [ "- [x] .tidyrc.json: No change needed" ]
        FileChanged FileRegenerated -> [ "- [x] .tidyrc.json: File regenerated." ]
        FileChanged FileAdded -> [ "- [x] .tidyrc.json: File added" ]
      formattingPart = case pursTidyStatus.formattingStatus of
        true -> [ "- [x] `purs-tidy`: formatted files." ]
        false -> [ "- [x] `purs-tidy`: formatting files did not cause a change." ]
      pursTidyCiPart = case pursTidyStatus.ciFileStatus of
        true -> [ "- [x] `purs-tidy`: check formatting step added to CI." ]
        false -> [ "- [x] `purs-tidy`: CI already checks formatting" ]
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
    let new = result.stdout
    -- easiest way to check whether a change has occurred
    if (original /= new) then do
      writeTextFile UTF8 bowerFile new
      gitAddResult <- execAff' ("git add " <> repoFiles.bowerJsonFile) inRepoDir
      throwIfExecErrored gitAddResult
      gitCommitResult <- execAff' "git commit -m \"Update the bower dependencies\"" inRepoDir
      throwIfExecErrored gitCommitResult
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

ensurePursTidyAdded
  :: Package
  -> Aff
    { ciFileStatus :: Boolean
    , formattingStatus :: Boolean
    , tidyOpFileStatus :: FileStatus Void Boolean ChangeReason
    , tidyRcFileStatus :: FileStatus Void Unit ChangeReason
    }
ensurePursTidyAdded pkg = do
  fileExists <- liftEffect $ exists ciFile
  unless fileExists do
    liftEffect $ throw $ repoFiles.ciYmlFile <> " did not exist for repo: " <> repoDir
  tidyOpFileStatus <- do
    hadTidyOpFile <- liftEffect $ exists tidyOpFile
    dirGlobs <- do
      let
        getGlobs arr = case Array.uncons arr of
          Just { head: Tuple checkFile getDirGlobs, tail } -> do
            ifM checkFile getDirGlobs (getGlobs tail)
          Nothing -> do
            liftEffect $ throw
              $ "Could not determine source globs for `purs-tidy generate-operators`.\n"
              <> "bower.json, spago.dhall, or test.dhall files not found for " <> repoDir
      getGlobs
        [ Tuple (liftEffect $ exists $ Path.concat [ repoDir, repoFiles.bowerJsonFile ]) do
            void $ execAff' "bower cache clean" inRepoDir
            void $ execAff' "bower install" inRepoDir
            let
              srcDir = [ Path.concat ["src", "**", "*.purs" ] ]
            testDir <- do
              hasTestDir <- liftEffect $ exists $ Path.concat [ repoDir, "test" ]
              pure $ if not hasTestDir then [] else [ Path.concat ["test", "**", "*.purs" ] ]
            bowerDirs <- do
              hasBowerDir <- liftEffect $ exists $ Path.concat [ repoDir, "bower_components"]
              if not hasBowerDir then do
                pure []
              else do
                bowerDirs <- readdir $ Path.concat [ repoDir, "bower_components"]
                pure $ bowerDirs <#> \s ->
                  Path.concat [ "bower_components", s, "src", "**", "*.purs" ]
            pure $ bowerDirs <> srcDir <> testDir
        , Tuple (liftEffect $ exists $ Path.concat [ repoDir, repoFiles.testDhallFile ]) do
            throwIfExecErrored =<< execAff' ("spago -x " <> repoFiles.testDhallFile <> " install") inRepoDir
            map (String.split (String.Pattern "\n") <<< _.stdout) $ execAff' ("spago -x " <> repoFiles.testDhallFile <> " sources") inRepoDir
        , Tuple (liftEffect $ exists $ Path.concat [ repoDir, repoFiles.spagoDhallFile ]) do
            throwIfExecErrored =<< execAff' "spago install" inRepoDir
            map (String.split (String.Pattern "\n") <<< _.stdout) $ execAff' ("spago sources") inRepoDir
        ]
    genCmd <- withSpawnResult =<< spawnAff' "purs-tidy" (Array.cons "generate-operators" dirGlobs) inRepoDir
    throwIfSpawnErrored genCmd
    nowHasTidyOpFile <- liftEffect $ exists tidyOpFile
    when (not hadTidyOpFile && nowHasTidyOpFile) do
      appendTextFile UTF8 (Path.concat [ libDir, repoFiles.gitIgnoreFile ]) "\n!.tidyoperators\n"
      void $ execAff' "git add .gitignore" inRepoDir
      void $ execAff' "git commit -m \"Stop ignoring '.tidyoperators'\"" inRepoDir
    gitDiff <- execAff' ("git status --short " <> repoFiles.tidyOperatorsFile) inRepoDir
    throwIfExecErrored gitDiff
    let contentChanged = String.trim gitDiff.stdout /= ""
    when contentChanged do
      gitCiAddResult <- execAff' ("git add " <> repoFiles.tidyOperatorsFile) inRepoDir
      throwIfExecErrored gitCiAddResult
      let
        msg
          | hadTidyOpFile = "Regenerated .tidyoperators file"
          | otherwise = "Added .tidyoperators file"
      gitCiCommitResult <- execAff' ("git commit -m \"" <> msg <> "\"") inRepoDir
      throwIfExecErrored gitCiCommitResult
    pure case hadTidyOpFile, contentChanged of
      true, true -> FileChanged FileRegenerated
      false, true -> FileChanged FileAdded
      _, false -> FileHadNoChanges hadTidyOpFile

  tidyRcFileStatus <- do
    hadTidyRcFile <- liftEffect $ exists tidyRcFile
    flip copyFile tidyRcFile case tidyOpFileStatus of
      FileHadNoChanges false -> pursTidyFiles.tidyRcNoOperatorsFile
      _ -> pursTidyFiles.tidyRcWithOperatorsFile
    nowHasTidyRcFile <- liftEffect $ exists tidyRcFile
    when (not hadTidyRcFile && nowHasTidyRcFile) do
      -- add file to gitignore
      appendTextFile UTF8 (Path.concat [ libDir, repoFiles.gitIgnoreFile ]) "\n!.tidyrc.json\n"
      void $ execAff' "git add .gitignore" inRepoDir
      void $ execAff' "git commit -m \"Stop ignoring '.tidyrc.json'\"" inRepoDir
    gitDiff <- execAff' ("git status --short " <> repoFiles.tidyRcJsonFile) inRepoDir
    throwIfExecErrored gitDiff
    let contentChanged = String.trim gitDiff.stdout /= ""
    when contentChanged do
      gitCiAddResult <- execAff' ("git add " <> repoFiles.tidyRcJsonFile) inRepoDir
      throwIfExecErrored gitCiAddResult
      let
        msg
          | hadTidyRcFile = "Regenerated .tidyrc.json file"
          | otherwise = "Added .tidyrc.json file"
      gitCiCommitResult <- execAff' ("git commit -m \"" <> msg <> "\"") inRepoDir
      throwIfExecErrored gitCiCommitResult
    pure case hadTidyRcFile, contentChanged of
      true, true -> FileChanged FileRegenerated
      false, true -> FileChanged FileAdded
      true, false -> FileHadNoChanges unit
      false, false -> unsafeCrashWith $ "Impossible: `.tidyrc.json` file must now exist in " <> repoDir

  formattingStatus <- do
    ptResult <- execAff' ("purs-tidy format-in-place src test") inRepoDir
    throwIfExecErrored ptResult

    gitDiff <- execAff' ("git diff --shortstat") inRepoDir
    throwIfExecErrored gitDiff
    let contentChanged = String.trim gitDiff.stdout /= ""
    when contentChanged do
      gitAddSrcResult <- execAff' ("git add src/") inRepoDir
      throwIfExecErrored gitAddSrcResult
      whenM (liftEffect $ exists $ Path.concat [ repoDir, "test"]) do
        gitAddTestResult <- execAff' ("git add test/") inRepoDir
        throwIfExecErrored gitAddTestResult
      gitCommitPtResult <- execAff' "git commit -m \"Formatted code via purs-tidy\"" inRepoDir
      throwIfExecErrored gitCommitPtResult
    pure contentChanged

  ciFileStatus <- do
    original <- readTextFile UTF8 ciFile
    let
      -- the colon below is what separates the configuration of purs-tidy
      -- from its usage
      pursTidyConfigLine = either (\_ -> unsafeCrashWith "invalid regex") identity
        $ regex "^( +)purs-tidy: \"[^\"]+\"( +)?$" multiline
      -- the colon below is what separates the configuration of purs-tidy
      -- from its usage
      pursTidyUsageLine = either (\_ -> unsafeCrashWith "invalid regex") identity
        $ regex "purs-tidy check" multiline
    if test pursTidyConfigLine original && test pursTidyUsageLine original then do
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
        gitCiAddResult <- execAff' ("git add " <> repoFiles.ciYmlFile) inRepoDir
        throwIfExecErrored gitCiAddResult
        gitCiCommitResult <- execAff' "git commit -m \"Added purs-tidy and check formatting step\"" inRepoDir
        throwIfExecErrored gitCiCommitResult
        pure true
      else do
        pure false
  pure { tidyOpFileStatus, tidyRcFileStatus, formattingStatus, ciFileStatus }
  where
  pkg' = unwrap pkg
  repoDir = Path.concat [ libDir, pkg']
  inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
  inRepoDir r = r { cwd = Just repoDir }
  ciFile = Path.concat [ repoDir, repoFiles.ciYmlFile ]
  tidyRcFile = Path.concat [ repoDir, repoFiles.tidyRcJsonFile ]
  tidyOpFile = Path.concat [ repoDir, repoFiles.tidyOperatorsFile ]

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
            gitAddResult <- execAff' ("git add " <> repoFiles.changelogFile) (_ { cwd = Just repoDir })
            throwIfExecErrored gitAddResult
            gitCommitResult <- execAff' "git commit -m \"Update the changelog\"" (_ { cwd = Just repoDir })
            throwIfExecErrored gitCommitResult
            pure $ FileChanged
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