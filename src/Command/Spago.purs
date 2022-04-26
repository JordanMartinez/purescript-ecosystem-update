module Command.Spago where

import Prelude

import Constants (libDir, repoFiles, spagoFiles)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Types (PackageInfo)
import Utils (copyFile, execAff', mkdir, throwIfExecErrored)

initCmd :: Aff Unit
initCmd = do
  mkdir spagoFiles.dir { recursive: true }
  writeTextFile UTF8 spagoFiles.readmeFile $ Array.intercalate "\n"
    [ "## What is this?"
    , ""
    , "This directory stores spago-related files used to update libraries' dependencies. "
    , ""
    , "## What do I need to do?"
    , ""
    , "Modify the `packages-prepare-set.dhall` file to refer to the package sets repo's 'prepare' branch "
    , "for the upcoming breaking release. The file should NOT have the hash produced via `dhall freeze` "
    , "as this package set will change over time as more libraries are added to it."
    ]
  writeTextFile UTF8 spagoFiles.preparePackageSetFile """let upstream =
      https://raw.githubusercontent.com/purescript/package-sets/prepare-0.15/src/packages.dhall

in  upstream
"""

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
