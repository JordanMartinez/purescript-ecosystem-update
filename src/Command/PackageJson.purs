module Command.PackageJson where

import Prelude

import Constants (libDir, repoFiles)
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.Version (Version)
import Data.Version as Version
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Types (Package)
import Utils (execAff', spawnAff', throwIfExecErrored, throwIfSpawnErrored, withSpawnResult)

-- | Use to update `pulp` or `purescript-psa`
-- | in the `package.json` file
updateDevDepTo :: Package -> String -> Version -> Aff Unit
updateDevDepTo pkg tool version = do
  fileExists <- liftEffect $ exists repoFiles.packageJsonFile
  when fileExists do
    contents <- readTextFile UTF8 packageJsonFile
    result <- withSpawnResult =<< spawnAff' "jq" [ jqScript, "--", repoFiles.packageJsonFile ] inRepoDir
    throwIfSpawnErrored result
    when (contents /= result.stdout) do
      writeTextFile UTF8 packageJsonFile result.stdout
      throwIfExecErrored =<< execAff' ("git add " <> repoFiles.packageJsonFile) inRepoDir
      let msg = "Updated " <> tool <> " to " <> versionStr
      throwIfExecErrored =<< execAff' ("git commit -m \"" <> msg <> "\"") inRepoDir
  where
  inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
  inRepoDir r = r { cwd = Just repoDir }
  repoDir = Path.concat [ libDir, unwrap pkg ]
  packageJsonFile = Path.concat [ repoDir, repoFiles.packageJsonFile ]
  versionStr = Version.showVersion version

  jqScript :: String
  jqScript = Array.intercalate " "
    [ "if has (\"devDependencies\") then"
    , "  .devDependencies |= ("
    , "    if has(\"" <> tool <> "\") then .\"" <> tool <> "\" = \"" <> versionStr <> "\" else . end"
    , "  )"
    , "else . end"
    ]
