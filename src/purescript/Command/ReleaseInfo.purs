module Command.ReleaseInfo where

import Prelude

import Constants (libDir, releaseFiles, repoFiles)
import Control.Monad.Except (runExcept)
import Data.Argonaut.Core (stringifyWithIndent)
import Data.Argonaut.Decode as Json
import Data.Argonaut.Encode (encodeJson)
import Data.Array (elem)
import Data.Either (either)
import Data.Filterable as Array
import Data.Foldable (foldl)
import Data.Formatter.DateTime (FormatterCommand(..), format)
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.String (Pattern(..))
import Data.String as String
import Data.String.Regex (regex, replace)
import Data.String.Regex.Flags (dotAll, multiline, noFlags)
import Data.Traversable (traverse)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Now (nowDateTime)
import Foreign (readArray, readString, unsafeFromForeign, unsafeToForeign)
import Foreign.Index (readProp)
import Foreign.Keys (keys)
import Foreign.Object as Object
import Node.ChildProcess as CP
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Node.Stream as Stream
import Packages (packages)
import Safe.Coerce (coerce)
import Types (Package(..), PackageInfo, ReleaseInfo)
import Utils (execAff', rightOrCrash, spawnAff, spawnAff', splitLines, throwIfExecErrored, throwIfSpawnErrored, withSpawnResult)

generateReleaseInfo :: Aff Unit
generateReleaseInfo = do
  releaseInfo <- traverse getReleaseInfo packages
  let
    obj = releaseInfo # flip foldl Object.empty \acc next -> do
      Object.insert (unwrap next.pkg) next acc
  dt <- liftEffect nowDateTime
  writeTextFile UTF8 (releaseFiles.releaseInfoPath $ formatYYYYMMDD dt)
    $ stringifyWithIndent 2
    $ encodeJson obj
  where
  formatYYYYMMDD = format
    $ YearFull
    : Placeholder "-"
    : MonthTwoDigits
    : Placeholder "-"
    : DayOfMonthTwoDigits
    : Nil
  getReleaseInfo :: PackageInfo -> Aff (ReleaseInfo String)
  getReleaseInfo info = do
    log $ "Getting release info for '" <> pkg' <> "'"
    throwIfExecErrored =<< execAff' "git fetch --tags upstream" inRepoDir
    gitTagResult <- withSpawnResult =<< spawnAff' "git" ["tag"] inRepoDir
    throwIfSpawnErrored gitTagResult
    let
      tags = gitTagResult.stdout
        # splitLines
        # Array.filter ((/=) "")
    throwIfExecErrored =<< execAff' "git reset --hard HEAD" inRepoDir
    throwIfExecErrored =<< execAff' ("git checkout upstream/" <> defaultBranch') inRepoDir

    { hasBowerJsonFile
    , bowerDependencies
    , bowerDevDependencies
    } <- getBowerDepsInfo
    { hasFile: hasSpagoDhallFile
    , dependencies: spagoDependencies
    } <- getDhallDependenciesField $ Path.concat [ repoDir, repoFiles.spagoDhallFile ]
    { hasFile: hasTestDhallFile
    , dependencies: spagoTestDependencies
    } <- getDhallDependenciesField $ Path.concat [ repoDir, repoFiles.testDhallFile ]
    pure
      { pkg: info.name
      , gitTags: tags
      , hasBowerJsonFile
      , bowerDependencies
      , bowerDevDependencies
      , hasSpagoDhallFile
      , spagoDependencies
      , hasTestDhallFile
      , spagoTestDependencies
      }
    where
    pkg' = unwrap info.name
    defaultBranch' = unwrap info.defaultBranch
    repoDir = Path.concat [ libDir, pkg' ]
    bowerFile = Path.concat [ repoDir, repoFiles.bowerJsonFile ]
    inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
    inRepoDir r = r { cwd = Just repoDir }
    arrStrToArrPkg :: Array String -> Array Package
    arrStrToArrPkg = coerce

    getBowerDepsInfo = do
      bowerFileExists <- liftEffect $ exists bowerFile
      if not bowerFileExists then do
        pure { hasBowerJsonFile: false, bowerDependencies: [], bowerDevDependencies: [] }
      else do
        contents <- readTextFile UTF8 bowerFile
        let
          json = unsafeToForeign
            $ rightOrCrash "Impossible: could not parse bower.json file"
            $ Json.parseJson contents
          getDeps keyName = either (const []) identity $ runExcept do
            hasKey <- elem keyName <$> keys json
            if not hasKey then do
              pure []
            else do
              dependenciesObj <- readProp keyName json

              let
                dependencies = dependenciesObj
                  # unsafeFromForeign
                  # Object.keys
                  # Array.filterMap (String.stripPrefix (Pattern "purescript-"))
                  # Array.filter ((/=) "")
                  # arrStrToArrPkg
              pure dependencies
          bowerDependencies = getDeps "dependencies"
          bowerDevDependencies = getDeps "devDependencies"

        pure { hasBowerJsonFile: true, bowerDependencies, bowerDevDependencies }

    getDhallDependenciesField file = do
      dhallFileExists <- liftEffect $ exists file
      if not dhallFileExists then do
        pure { hasFile: false, dependencies: [] }
      else do
        contents <- readTextFile UTF8 file
        let
          spagoDhallFieldRegex = rightOrCrash "Invalid pkgs field regex"
            $ regex ", +packages=[ \n]+[^,]+," noFlags
          testDhallFieldRegex = rightOrCrash "Invalid pkgs field regex"
            $ regex "let +([^ ]+) +=.+in +([^ ]+)" (multiline <> dotAll)
          contentWithNoImports = contents
            # replace spagoDhallFieldRegex ","
            # replace testDhallFieldRegex "let $1 = { sources = [] : List Text, dependencies = [] : List Text }\nin $1"

        spawnedDtj <- spawnAff "dhall-to-json" []
        liftEffect do
          void $ Stream.writeString (CP.stdin spawnedDtj) UTF8 contentWithNoImports (pure unit)
          void $ Stream.end (CP.stdin spawnedDtj) (pure unit)
        result <- withSpawnResult spawnedDtj
        throwIfSpawnErrored result
        let
          json = unsafeToForeign
            $ rightOrCrash "Impossible: could not parse bower.json file"
            $ Json.parseJson result.stdout
          dependencies = arrStrToArrPkg $ either (const []) identity $ runExcept do
            arr <- readProp "dependencies" json
            dependenciesArr <- readArray arr
            traverse readString dependenciesArr

        pure { hasFile: true, dependencies }
