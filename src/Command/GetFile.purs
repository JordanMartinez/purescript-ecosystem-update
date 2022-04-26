module Command.GetFile where

import Prelude

import Constants (getFileDir, libDir)
import Data.Array as Array
import Data.Array.NonEmpty as NEA
import Data.FoldableWithIndex as FI
import Data.Formatter.DateTime (FormatterCommand(..), format)
import Data.HashMap as HM
import Data.HashSet as HashSet
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Monoid (power)
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..), fst, snd)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Now (nowDateTime)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Packages (packages)
import Safe.Coerce (coerce)
import Types (Package(..), PackageInfo)
import Utils (execAff', justOrCrash, mkdir, throwIfExecErrored)

initCmd :: Aff Unit
initCmd = do
  mkdir getFileDir { recursive: true }

getFile :: Array FilePath -> Aff Unit
getFile filePaths = do
  fileToPkgMap <- Array.foldM getFile' HM.empty packages
  let
    fileContent = fileToPkgMap # flip FI.foldlWithIndex { count: 1, arr: [] } \fileStatus acc pkgSet -> do
      { count: acc.count + 1
      , arr: acc.arr
          <>
            [ "## Entry " <> show acc.count
            , ""
            , "Packages with this file:"
            , NEA.foldr1 (\l r -> l <> ", " <> r)
                $ (coerce :: _ Package -> _ String)
                $ NEA.sort
                $ justOrCrash "Package set must be non-empty"
                $ NEA.fromArray
                $ Array.fromFoldable pkgSet
            , ""
            ]
          <>
            ( case fileStatus of
                Nothing -> [ "No such content" ]
                Just content ->
                  [ lineSeparator <> syntaxHighlighter
                  , content
                  , lineSeparator
                  ]
            )
          <>
            [ ""
            , ""
            ]
      }

  dt <- liftEffect nowDateTime
  writeTextFile UTF8 (Path.concat [ getFileDir, filePathName <> "_" <> formatYYYYMMDD dt <> ".md" ])
    $ "All repo's '" <> fullFilePath <> "':\n\n" <> Array.intercalate "\n" fileContent.arr
  where
  formatYYYYMMDD = format
    $ YearFull
        : Placeholder "-"
        : MonthTwoDigits
        : Placeholder "-"
        : DayOfMonthTwoDigits
        : Nil
  lineSeparator = power "`" 12
  fullFilePath = Path.concat filePaths
  filePathName = Array.intercalate "_" filePaths
  syntaxHighlighter = fromMaybe "" do
    let
      extension = Path.extname fullFilePath
    snd <$> Array.find (fst >>> (==) extension)
      [ Tuple ".json" "json"
      , Tuple ".js" "javascript"
      , Tuple ".yml" "yml"
      , Tuple ".purs" "purs"
      , Tuple ".dhall" "dhall"
      , Tuple ".md" "markdown"
      ]

  getFile'
    :: HM.HashMap (Maybe String) (HashSet.HashSet Package)
    -> PackageInfo
    -> Aff (HM.HashMap (Maybe String) (HashSet.HashSet Package))
  getFile' hashMap info = do
    log $ "Getting file for '" <> pkg' <> "'"
    throwIfExecErrored =<< execAff' "git fetch upstream" inRepoDir
    throwIfExecErrored =<< execAff' "git reset --hard HEAD" inRepoDir
    throwIfExecErrored =<< execAff' ("git checkout upstream/" <> defaultBranch') inRepoDir
    fileExists <- liftEffect $ exists filePathFromPeu
    let
      insertPkg = case _ of
        Nothing -> Just $ HashSet.singleton info.package
        Just s -> Just $ HashSet.insert info.package s
    if fileExists then do
      content <- readTextFile UTF8 filePathFromPeu
      pure $ HM.alter insertPkg (Just content) hashMap
    else do
      pure $ HM.alter insertPkg Nothing hashMap
    where
    filePathFromPeu = Path.concat $ Array.cons repoDir filePaths
    pkg' = unwrap info.package
    defaultBranch' = unwrap info.defaultBranch
    repoDir = Path.concat [ libDir, pkg' ]

    inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
    inRepoDir r = r { cwd = Just repoDir }
