module Command.Bower where

import Prelude

import Constants (jqScripts, libDir, repoFiles)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import DependencyGraph (getNextReleaseInfo)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Tools.Jq (regenerateJqBowerUpdateScripts)
import Types (PackageInfo)
import Utils (execAff', spawnAff', throwIfExecErrored, throwIfSpawnErrored, withSpawnResult)

-- | Updates a single package's bower deps to their default branch
updatePackageDepsToBranchVersion :: { package :: PackageInfo } -> Aff Unit
updatePackageDepsToBranchVersion { package: info } = do
  nextReleaseInfo <- getNextReleaseInfo
  regenerateJqBowerUpdateScripts nextReleaseInfo
  jqScriptAbsPath <- liftEffect $ Path.resolve [] jqScripts.updateBowerDepsToBranchNameVersion
  updateBowerDepsToBranchVersion jqScriptAbsPath info "Update bower deps to default branch versions"

-- | Updates a single package's bower deps to their default branch
updatePackageDepsToReleaseVersion :: { package :: PackageInfo } -> Aff Unit
updatePackageDepsToReleaseVersion { package: info } = do
  nextReleaseInfo <- getNextReleaseInfo
  regenerateJqBowerUpdateScripts nextReleaseInfo
  jqScriptAbsPath <- liftEffect $ Path.resolve [] jqScripts.updateBowerDepsToReleaseVersion
  updateBowerDepsToBranchVersion jqScriptAbsPath info "Update bower deps to release versions"

-- | Code for updating a package's bower.json deps to default branch.
-- | Can be used to update a single package or multiple ones via traverse.
updateBowerDepsToBranchVersion :: FilePath -> PackageInfo -> String -> Aff Unit
updateBowerDepsToBranchVersion jqScriptAbsPath info commitMsg = do
  bowerExists <- liftEffect $ exists bowerFile
  if bowerExists then do
    before <- readTextFile UTF8 bowerFile
    throwIfSpawnErrored =<< withSpawnResult =<< spawnAff' "jq" [ "--from-file", jqScriptAbsPath, repoFiles.bowerJsonFile ] inRepoDir
    after <- readTextFile UTF8 bowerFile
    if before /= after then do
      throwIfExecErrored =<< execAff' "git add bower.json" inRepoDir
      throwIfExecErrored =<< execAff' ("git commit -m \"" <> commitMsg <> "\"") inRepoDir
    else do
      log $ pkg' <> ": `bower.json` file had no changes."
  else do
    log $ pkg' <> ": `bower.json` file does not exist"
  where
  pkg' = unwrap info.package
  repoDir = Path.concat [ libDir, pkg' ]

  inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
  inRepoDir r = r { cwd = Just repoDir }
  bowerFile = Path.concat [ repoDir, repoFiles.bowerJsonFile ]
