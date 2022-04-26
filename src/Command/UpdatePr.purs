module Command.UpdatePr where

import Prelude

import Constants (libDir, prFiles)
import Data.Array (elem)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.String as String
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (writeTextFile)
import Node.Path (FilePath)
import Node.Path as Path
import Types (PackageInfo)
import Utils (execAff', mkdir, spawnAff', splitLines, throwIfExecErrored, withSpawnResult)

initCmd :: Aff Unit
initCmd = do
  mkdir prFiles.dir { recursive: true }
  writeTextFile UTF8 prFiles.readmeFile $ Array.intercalate "\n"
    [ "## What is this?"
    , ""
    , Array.fold
      [ "This directory stores a filewhose text is used as the PR body when submitting a PR "
      , "that updates a library to the next breaking PureScript release."
      ]
    , ""
    , "## What do I need to do?"
    , ""
    , "- Create a new \"meta\" issue in the PureScript repo and update the 'backlinking to' issue number to that issue."
    , "- Update the file's content (e.g. the PureScript version used)."
    ]
  writeTextFile UTF8 prFiles.updatePrBodyFile $ Array.intercalate "\n"
    [ "**Description of the change**"
    , ""
    , "Backlinking to purescript/purescript#4244"
    , ""
    , "Updates project to compile on v0.15.0 PureScript."
    , ""
    , "---"
    , ""
    , "**Checklist:**"
    , ""
    , "- [x] Added the change to the changelog's \"Unreleased\" section with a reference to this PR (e.g. \"- Made a change (#0000)\")"
    , "- [x] Linked any existing issues or proposals that this pull request should close"
    , "- [ ] Updated or added relevant documentation"
    , "- [ ] Added a test for the contribution (if applicable)"
    , ""
    ]

createPrForUpdate :: { package :: PackageInfo, openWeb :: Boolean } -> Aff Unit
createPrForUpdate { package: info, openWeb } = do
  log $ "## Doing release changes for '" <> pkg' <> "'"
  branchResult <- execAff' "git branch --show-current" inRepoDir
  throwIfExecErrored branchResult
  let
    currentlyCheckedOutBranch = String.trim branchResult.stdout
  unless (currentlyCheckedOutBranch /= "") do
    liftEffect $ throw "You do not have a local branch checked out."
  -- only prepare and submit PR if branch name doesn't already exist on remote
  -- as we may have already submitted a PR but not gotten it merged yet.
  remoteBranchResult <- execAff' "git branch -r" inRepoDir
  throwIfExecErrored remoteBranchResult
  let
    prAlreadySubmitted =
      remoteBranchResult.stdout
        # splitLines
        # map (String.trim <<< String.drop 2)
        # elem ("origin/" <> currentlyCheckedOutBranch)
  if prAlreadySubmitted then do
    log $ "... The 'origin' remote already has a branch named: " <> currentlyCheckedOutBranch
    log "    We'll assume the PR has already submitted. Skipping."
  else do
    log $ "... submitting PR using branch " <> currentlyCheckedOutBranch
    absPath <- liftEffect $ Path.resolve [] prFiles.updatePrBodyFile
    throwIfExecErrored =<< execAff' ("git push -f -u origin " <> currentlyCheckedOutBranch) inRepoDir
    result <- withSpawnResult =<< spawnAff' "gh" (ghPrCreateArgs absPath) inRepoDir
    log $ result.stdout
    log $ result.stderr
  where
  pkg' = unwrap info.package
  repoDir = Path.concat [ libDir, pkg' ]

  inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
  inRepoDir r = r { cwd = Just repoDir }

  ghPrCreateArgs bodyFilePath =
    [ "pr"
    , "create"
    , "--title"
    , "Update project to PureScript 0.15"
    , "--body-file"
    , bodyFilePath
    , "--label"
    , "purs-0.15"
    , "--label"
    , "type: breaking change"
    ]
    <> (if openWeb then [ "--web" ] else [])
