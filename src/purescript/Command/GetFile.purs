module Command.GetFile where

import Prelude

import Constants (libDir)
import Data.Array as Array
import Data.Formatter.DateTime (FormatterCommand(..), format)
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..))
import Data.Monoid (power)
import Data.Newtype (unwrap)
import Data.Traversable (traverse)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Now (nowDateTime)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.Path (FilePath)
import Node.Path as Path
import Packages (packages)
import Types (PackageInfo)
import Utils (execAff', throwIfExecErrored)

getFile :: FilePath -> Aff Unit
getFile file = do
  files <- traverse getFile' packages
  let
    content = "All repo's '" <> file <> "':\n\n" <> Array.fold files
  dt <- liftEffect nowDateTime
  writeTextFile UTF8 (Path.concat [ "files", file <> "_" <> formatYYYYMMDD dt <> ".md"]) content
  where
  formatYYYYMMDD = format
    $ YearFull
    : Placeholder "-"
    : MonthTwoDigits
    : Placeholder "-"
    : DayOfMonthTwoDigits
    : Nil
  getFile' :: PackageInfo -> Aff String
  getFile' info = do
    log $ "Getting file for '" <> pkg' <> "'"
    throwIfExecErrored =<< execAff' "git fetch upstream" inRepoDir
    throwIfExecErrored =<< execAff' "git reset --hard HEAD" inRepoDir
    throwIfExecErrored =<< execAff' ("git checkout upstream/" <> defaultBranch') inRepoDir
    content <- readTextFile UTF8 $ Path.concat [ repoDir, file ]
    pure $ Array.intercalate "\n"
      [ "## " <> pkg'
      , ""
      , power "-" 45
      , content
      , power "-" 45
      , ""
      ]
    where
    pkg' = unwrap info.name
    defaultBranch' = unwrap info.defaultBranch
    repoDir = Path.concat [ libDir, pkg' ]
    inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
    inRepoDir r = r { cwd = Just repoDir }
