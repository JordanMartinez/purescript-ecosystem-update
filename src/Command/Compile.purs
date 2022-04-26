module Command.Compile where

import Prelude

import Constants (libDir, repoFiles)
import Data.Filterable (filterMap)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.Traversable (for_)
import Data.Tuple (Tuple(..))
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Types (GitHubOwner(..), PackageInfo)
import Utils (execAff', hasFFI, throwIfExecErrored)

initCmd :: Aff Unit
initCmd = do
  pure unit

compile
  :: { package :: PackageInfo
     , clearBowerCache :: Boolean
     , skipPulp :: Boolean
     , skipBowerInstall :: Boolean
     , skipEslint :: Boolean
     , skipFormat :: Boolean
     , skipSpago :: Boolean
     , skipSpagoInstall :: Boolean
     , skipTests :: Boolean
     }
  -> Aff Unit
compile { package: info, clearBowerCache, skipPulp, skipBowerInstall, skipSpago, skipSpagoInstall, skipTests, skipEslint, skipFormat } = do
  bowerExists <- liftEffect $ exists bowerFile
  spagoExists <- liftEffect $ exists spagoFile
  spagoTestExists <- liftEffect $ exists spagoTestFile
  testDirExists <- liftEffect $ exists testDir

  throwIfExecErrored =<< execAff' "npm install" inRepoDir
  if info.owner == GitHubOwner "purescript" then do
    unless skipPulp do
      unless skipBowerInstall do
        when clearBowerCache do
          throwIfExecErrored =<< execAff' "bower cache clean" inRepoDir
        throwIfExecErrored =<< execAff' "bower install --production" inRepoDir
      throwIfExecErrored =<< execAff' "npm run -s build" inRepoDir
      unless skipBowerInstall do
        throwIfExecErrored =<< execAff' "bower install" inRepoDir
      unless skipTests do
        throwIfExecErrored =<< execAff' "npm run -s test --if-present" inRepoDir
  else do
    when (bowerExists && not skipPulp) do
      unless skipBowerInstall do
        when clearBowerCache do
          throwIfExecErrored =<< execAff' "bower cache clean" inRepoDir
        throwIfExecErrored =<< execAff' "bower install" inRepoDir
      unless skipPulp do
        throwIfExecErrored =<< execAff' "pulp build -- \"--strict\"" inRepoDir
      when (testDirExists && not skipTests) do
        throwIfExecErrored =<< execAff' "pulp test -- \"--strict\"" inRepoDir

    when (spagoExists && not skipSpago) do
      unless skipSpagoInstall do
        throwIfExecErrored =<< execAff' "spago install" inRepoDir
      throwIfExecErrored =<< execAff' "spago build -u \"--strict\"" inRepoDir
      when (testDirExists && not skipTests) do
        if spagoTestExists then do
          throwIfExecErrored =<< execAff' "spago -x test.dhall test -u \"--strict\"" inRepoDir
        else do
          throwIfExecErrored =<< execAff' "spago test -u \"--strict\"" inRepoDir
  unless skipFormat do
    throwIfExecErrored =<< execAff' "purs-tidy check src/ test/" inRepoDir
  unless skipEslint do
    ffiStatus <- hasFFI info.package
    for_ (ffiStatus # filterMap \(Tuple dir hasFfi) -> if hasFfi then Just dir else Nothing) \dir -> do
      throwIfExecErrored =<< execAff' ("eslint " <> dir) inRepoDir
  where
  pkg' = unwrap info.package
  repoDir = Path.concat [ libDir, pkg' ]

  inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
  inRepoDir r = r { cwd = Just repoDir }
  bowerFile = Path.concat [ repoDir, repoFiles.bowerJsonFile ]
  spagoFile = Path.concat [ repoDir, repoFiles.spagoDhallFile ]
  spagoTestFile = Path.concat [ repoDir, repoFiles.testDhallFile ]
  testDir = Path.concat [ repoDir, repoFiles.testDir ]
