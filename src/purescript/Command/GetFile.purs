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

getFile :: Array FilePath -> Aff Unit
getFile filePaths = do
  files <- traverse getFile' packages
  let
    content = "All repo's '" <> fullFilePath <> "':\n\n" <> Array.fold files
  dt <- liftEffect nowDateTime
  writeTextFile UTF8 (Path.concat [ "files", filePathName <> "_" <> formatYYYYMMDD dt <> ".md"]) content
  where
  formatYYYYMMDD = format
    $ YearFull
    : Placeholder "-"
    : MonthTwoDigits
    : Placeholder "-"
    : DayOfMonthTwoDigits
    : Nil
  lineSeparator = power "-" 45
  fullFilePath = Path.concat filePaths
  filePathName = Array.intercalate "_" filePaths
  getFile' :: PackageInfo -> Aff String
  getFile' info = do
    log $ "Getting file for '" <> pkg' <> "'"
    throwIfExecErrored =<< execAff' "git fetch upstream" inRepoDir
    throwIfExecErrored =<< execAff' "git reset --hard HEAD" inRepoDir
    throwIfExecErrored =<< execAff' ("git checkout upstream/" <> defaultBranch') inRepoDir
    content <- readTextFile UTF8 $ Path.concat $ Array.cons repoDir filePaths
    pure $ Array.intercalate "\n"
      [ "## " <> pkg'
      , ""
      , lineSeparator
      , content
      , lineSeparator
      , ""
      , ""
      ]
    where
    pkg' = unwrap info.name
    defaultBranch' = unwrap info.defaultBranch
    repoDir = Path.concat [ libDir, pkg' ]
    inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
    inRepoDir r = r { cwd = Just repoDir }
