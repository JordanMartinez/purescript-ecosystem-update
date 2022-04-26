module Command.LibOrder where

import Prelude

import Command (DependencyStage(..))
import Constants (releaseFiles, spagoFiles)
import Data.Argonaut.Decode (decodeJson, parseJson, printJsonDecodeError)
import Data.Array (catMaybes, foldl, sortBy)
import Data.Either (either)
import Data.FunctorWithIndex (mapWithIndex)
import Data.HashMap (HashMap, toArrayBy)
import Data.HashSet (HashSet)
import Data.HashSet as Set
import Data.Maybe (fromMaybe)
import Data.Newtype (unwrap)
import Data.String (Pattern(..))
import Data.String.CodeUnits (stripSuffix)
import Data.String.CodeUnits as SCU
import Data.String.Utils (padEnd)
import DependencyGraph (getDependencyGraph, getNextReleaseInfo)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Exception (throw)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Types (GitCloneUrl, Package(..), ReleaseInfo)
import Utils (mkdir, spawnAff, splitLines, throwIfSpawnErrored, withSpawnResult)

initCmd :: Aff Unit
initCmd = do
  mkdir releaseFiles.dir { recursive: true }

generateLibOrder :: DependencyStage -> Aff Unit
generateLibOrder = case _ of
  UpdateOrder -> do
    nextReleaseInfo <- getNextReleaseInfo
    updatedPackages <- splitLines <$> readTextFile UTF8 releaseFiles.updatedPkgsFile
    let
      { unfinishedPkgsGraph } = getDependencyGraph nextReleaseInfo updatedPackages
    writeTextFile UTF8 releaseFiles.updateOrderFile
      $ linearizePackageDependencyOrder (simplifyReleaseInfoRecord nextReleaseInfo) unfinishedPkgsGraph
  ReleaseOrder -> do
    nextReleaseInfo <- getNextReleaseInfo
    releasedPackages <- splitLines <$> readTextFile UTF8 releaseFiles.releasedPkgsFile
    let
      { unfinishedPkgsGraph } = getDependencyGraph nextReleaseInfo releasedPackages
    writeTextFile UTF8 releaseFiles.releaseOrderFile
      $ linearizePackageDependencyOrder (simplifyReleaseInfoRecord nextReleaseInfo) unfinishedPkgsGraph
  SpagoOrder -> do
    dtjResult <- withSpawnResult =<< spawnAff "dhall-to-json" [ "--file", spagoFiles.lastStablePackageSet ]
    throwIfSpawnErrored dtjResult
    (packageGraph :: Object { dependencies :: Array Package, repo :: GitCloneUrl }) <-
      either (liftEffect <<< throw <<< printJsonDecodeError) pure
        $ decodeJson =<< parseJson dtjResult.stdout
    let
      nextReleaseInfo = packageGraph # mapWithIndex \key { dependencies } -> do
        { package: Package key
        , hasBowerJsonFile: false
        , bowerDependencies: []
        , bowerDevDependencies: []
        , hasSpagoDhallFile: true
        , spagoDependencies: dependencies
        , hasTestDhallFile: false
        , spagoTestDependencies: []
        }
      simplifiedObj = packageGraph # map \{ repo } -> do
        let
          repo' = unwrap repo
        fromMaybe repo' $ stripSuffix (Pattern ".git") repo'
    releasedPackages <- splitLines <$> readTextFile UTF8 releaseFiles.releasedPkgsFile
    deprecatedPkgs <- splitLines <$> readTextFile UTF8 releaseFiles.deprecatedPkgsFile
    let
      { unfinishedPkgsGraph } = getDependencyGraph nextReleaseInfo (releasedPackages <> deprecatedPkgs)
    writeTextFile UTF8 releaseFiles.spagoOrderFile
      $ linearizePackageDependencyOrder simplifiedObj unfinishedPkgsGraph
  where
  simplifyReleaseInfoRecord
    :: Object (ReleaseInfo String String)
    -> Object String
  simplifyReleaseInfoRecord = map \v ->
    "https://github.com/" <> unwrap v.owner <> "/" <> unwrap v.repo

  linearizePackageDependencyOrder
    :: Object String
    -> HashMap Package (HashSet Package)
    -> String
  linearizePackageDependencyOrder releaseInfo =
    toArrayBy (\k v -> do
      githubRepo <- Object.lookup (unwrap k) releaseInfo
      pure
        { package: k
        , depCount: Set.size v
        , dependencies: Set.toArray v
        , githubRepo
        }
    )
      >>> catMaybes
      >>> sortBy
        ( \l r ->
            case compare l.depCount r.depCount of
              EQ -> compare l.package r.package
              x -> x
        )
      >>> mkOrderedContent
    where
    mkOrderedContent
      :: Array
          { package :: Package
          , depCount :: Int
          , dependencies :: Array Package
          , githubRepo :: String
          }
      -> String
    mkOrderedContent arr = foldResult.str
      where
      maxLength = foldl maxPartLength { dep: 0, package: 0, repo: 0 } arr
      maxPartLength acc r =
        { dep: max acc.dep $ SCU.length $ show r.depCount
        , package: max acc.package $ SCU.length $ unwrap r.package
        , repo: max acc.repo $ SCU.length $ r.githubRepo
        }
      foldResult = foldl buildLine { init: true, str: "" } arr
      buildLine acc r = do
        let
          depCount = padEnd maxLength.dep $ show r.depCount
          package = padEnd maxLength.package $ unwrap r.package
          repo = padEnd maxLength.repo $ r.githubRepo
          nextLine = depCount <> " " <> package <> " " <> repo <> " " <> show r.dependencies
        { init: false
        , str: if acc.init then nextLine else acc.str <> "\n" <> nextLine
        }

