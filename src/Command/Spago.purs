module Command.Spago where

import Prelude

import Constants (libDir, repoFiles, spagoFiles)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Types (PackageInfo)
import Utils (copyFile, execAff', mkdir, throwIfExecErrored)

initCmd :: Aff Unit
initCmd = do
  mkdir spagoFiles.dir { recursive: true }

-- | Updates a given package's `packages.dhall` to the one stored
-- | in `files/spago/packages.dhall`
updatePackageSet :: { package :: PackageInfo } -> Aff Unit
updatePackageSet { package: info } = do
  packagesDhallExists <- liftEffect $ exists packagesDhallFile
  if packagesDhallExists then do
    before <- readTextFile UTF8 packagesDhallFile
    copyFile spagoFiles.preparePackageSetFile packagesDhallFile
    after <- readTextFile UTF8 packagesDhallFile
    if before /= after then do
      throwIfExecErrored =<< execAff' "git add packages.dhall" inRepoDir
      throwIfExecErrored =<< execAff' "git commit -m \"Update packages.dhall to prepare package set\"" inRepoDir
    else do
      log $ pkg' <> ": `packages.dhall` file had no changes."
  else do
    log $ pkg' <> ": `packages.dhall` file does not exist"
  where
  pkg' = unwrap info.package
  repoDir = Path.concat [ libDir, pkg' ]

  inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
  inRepoDir r = r { cwd = Just repoDir }
  packagesDhallFile = Path.concat [ repoDir, repoFiles.packagesDhallFile ]
