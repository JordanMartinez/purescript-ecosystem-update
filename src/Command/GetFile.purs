module Command.GetFile where

import Prelude

import Command (GetFileOutput(..))
import Constants (getFileFiles, libDir)
import Data.Argonaut.Core (stringifyWithIndent)
import Data.Argonaut.Encode (encodeJson)
import Data.Array as Array
import Data.Array.NonEmpty as NEA
import Data.Foldable (foldl, for_)
import Data.FoldableWithIndex (foldlWithIndex)
import Data.FoldableWithIndex as FI
import Data.Formatter.DateTime (FormatterCommand(..), format)
import Data.HashMap as HM
import Data.HashSet (toArray)
import Data.HashSet as HashSet
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Monoid (power)
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..), fst, snd)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Effect.Now (nowDateTime)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, readdir, writeTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath, extname)
import Node.Path as Path
import Packages (packages)
import Safe.Coerce (coerce)
import Types (Package(..), PackageInfo)
import Utils (execAff', justOrCrash, mkdir, padWith, rmRf, throwIfExecErrored)

initCmd :: Aff Unit
initCmd = do
  mkdir getFileFiles.dir { recursive: true }
  mkdir getFileFiles.summaryDir { recursive: true }
  mkdir getFileFiles.keyedDir { recursive: true }
  writeTextFile UTF8 getFileFiles.readmeFile $ Array.intercalate "\n"
    [ "## What is this?"
    , ""
    , Array.fold
      [ "This directory stores the output of the `getFile` command. "
      , "When needing to make changes across all libraries, it can be helpful "
      , "to see how many variants there are, so that all edge cases are known sooner."
      ]
    , "- `summary`: the summary dir stores the output when the 'summary' option is used. "
    , "- `keyed`: the keyed dir contains the outputs when the 'keyed' option is used. "
    , ""
    , "## What do I need to do?"
    , ""
    , "Nothing. The files stored in this directory will be generated by the program."
    ]

getFile :: GetFileOutput -> Array FilePath -> Aff Unit
getFile desiredOutput filePaths = do
  case desiredOutput of
    AsSummaryFile -> do
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
      writeTextFile UTF8 (Path.concat [ getFileFiles.summaryDir, filePathName <> "_" <> formatYYYYMMDD dt <> ".md" ])
        $ "All repo's '" <> fullFilePath <> "':\n\n" <> Array.intercalate "\n" fileContent.arr
    AsKeyedDirectory dir replaceDir -> do
      let
        parentDir = Path.concat [ getFileFiles.keyedDir, dir ]
      dirExists <- liftEffect $ exists parentDir
      when dirExists do
        children <- readdir parentDir
        if Array.null children || replaceDir then do
          rmRf parentDir
        else do
          liftEffect $ throw $ "directory at path " <> parentDir <> " already exists and contains files."
      fileToPkgMap <- Array.foldM getFile' HM.empty packages
      mkdir parentDir { recursive: true }
      let
        pkgMapArr = fileToPkgMap
          # flip foldlWithIndex { count: 1, arr: [] } (\file acc pkgSet -> do
            { count: acc.count + 1
            , arr: Array.snoc acc.arr $ { file, pkgSet, entryNum: acc.count }
            })
          # _.arr
        pathExtName = extname $ Path.concat filePaths
        fileNameFor entryNum = (padWith 2 '0' $ show entryNum) <> pathExtName
        arrPkgToArrString :: Array Package -> Array String
        arrPkgToArrString = coerce
      for_ pkgMapArr \{ file, pkgSet, entryNum } -> do
        case file of
          Nothing ->
            writeTextFile UTF8 (Path.concat [ parentDir, "packages-with-file-missing.txt" ])
              $ Array.intercalate "\n"
              $ arrPkgToArrString
              $ Array.sort
              $ toArray pkgSet
          Just fileContent -> do
            writeTextFile UTF8 (Path.concat [ parentDir, fileNameFor entryNum ]) fileContent
      let
        summaryContent = pkgMapArr # flip foldl [] \acc { pkgSet, entryNum } ->
              acc
              <> [ "## `" <> fileNameFor entryNum <> "`"
                 , ""
                 ]
              <> (arrPkgToArrString $ Array.sort $ toArray pkgSet)
              <> [ "" ]

        summaryJson :: Object (Maybe String)
        summaryJson = pkgMapArr # flip foldl Object.empty \acc { file, pkgSet, entryNum } -> do
          let fileName = fileNameFor entryNum
          foldl (\accMap n -> Object.insert (unwrap n) (fileName <$ file) accMap) acc pkgSet
      dt <- liftEffect nowDateTime
      writeTextFile UTF8 (Path.concat [ parentDir, "summary_" <> formatYYYYMMDD dt <> ".md" ])
        $ append ("All repo's '" <> fullFilePath <> "':\n\n") $ Array.intercalate "\n" summaryContent
      writeTextFile UTF8 (Path.concat [ parentDir, "summary_" <> formatYYYYMMDD dt <> ".json" ])
        $ stringifyWithIndent 2
        $ encodeJson summaryJson
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
