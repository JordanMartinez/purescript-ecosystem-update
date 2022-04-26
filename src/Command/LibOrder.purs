module Command.LibOrder where

import Prelude

import Command (DependencyStage(..))
import Constants (orderFiles)
import Data.Argonaut.Decode (decodeJson, parseJson, printJsonDecodeError)
import Data.Array (catMaybes, foldl, sortBy)
import Data.Array as Array
import Data.Either (either)
import Data.Foldable (for_)
import Data.FunctorWithIndex (mapWithIndex)
import Data.HashMap (HashMap, toArrayBy)
import Data.HashSet (HashSet)
import Data.HashSet as Set
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (unwrap)
import Data.String (Pattern(..))
import Data.String.CodeUnits (stripSuffix)
import Data.String.CodeUnits as SCU
import Data.String.Utils (padEnd)
import DependencyGraph (getDependencyGraph, getNextReleaseInfo)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Types (GitCloneUrl, Package(..), ReleaseInfo)
import Utils (execAff', mkdir, spawnAff, splitLines, throwIfSpawnErrored, withSpawnResult)

initCmd :: Aff Unit
initCmd = do
  mkdir orderFiles.dir { recursive: true }
  writeTextFile UTF8 orderFiles.readmeFile $ Array.intercalate "\n"
    [ "## What is this?"
    , ""
    , Array.fold
      [ "This directory stores the output of the `updateOrder`, "
      , "`releaseOrder`, and `spagoOrder` commands. Each 'order' file "
      , "helps one know what libraries to work on next at a given stage "
      , " in the release cycle. "
      ]
    , ""
    , "## What do I need to do?"
    , ""
    , Array.fold
      [ "There are generally two files for the 'order' commands. "
      , "The first is the 'order' file. The second is the packages that "
      , "have already been updated or released. These are the packages "
      , "that get removed from the full calculated dependency graph "
      , "before the order file is generated. So..."
      ]
    , Array.fold
      [ "- update stage. Every time a library gets updated, "
      , "add its name (e.g. `prelude`) to the `updated-packages` file. "
      , "This will remove those packages from the order file and put the next "
      , "libraries at the top of the file."
      ]
    , Array.fold
      [ "- release stage. Every time a library gets released, "
      , "add its name (e.g. `prelude`) to the `released-packages` file. "
      ]
    , Array.fold
      [ "- package set stage. If any libraries are deprecated, add their name "
      , "to the `spago-deprecated-packages` file. Once all core/contrib/node/web "
      , "libraries are released, and the package set is being filled with "
      , "3rd-party libraries that are now being updated, add each 3rd-party package name "
      , "(once added to the package set) to the **`releeased-packages`** file."
      ]
    , ""
    , Array.fold
      [ "Moreover, the " <> orderFiles.lastStablePackageSet <> " file needs to be updated "
      , "to refer to the last stable package set before the breaking change."
      ]
    ]
  writeTextFile UTF8 orderFiles.lastStablePackageSet """
let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.14.7-20220418/packages.dhall
        sha256:2523a5659d0f3b198ffa2f800da147e0120578842e492a7148e4b44f357848b3

in  upstream
"""
  result <- execAff' "spago upgrade-set" (_ { cwd = Just orderFiles.dir})
  for_ result.error \e -> do
    log $ "Attempted to upgrade the package set to latest stable version, but command failed."
    log "Exec result error:"
    log $ show e
    log $ "Stdout:"
    log $ result.stdout
    log $ "Stderr:"
    log $ result.stderr
    log ""
    log $ "You will need to update the package set in '" <> orderFiles.lastStablePackageSet <> "' manually."

generateLibOrder :: DependencyStage -> Aff Unit
generateLibOrder = case _ of
  UpdateOrder -> do
    nextReleaseInfo <- getNextReleaseInfo
    updatedPackages <- splitLines <$> readTextFile UTF8 orderFiles.updatedPkgsFile
    let
      { unfinishedPkgsGraph } = getDependencyGraph nextReleaseInfo updatedPackages
    writeTextFile UTF8 orderFiles.updateOrderFile
      $ linearizePackageDependencyOrder (simplifyReleaseInfoRecord nextReleaseInfo) unfinishedPkgsGraph
  ReleaseOrder -> do
    nextReleaseInfo <- getNextReleaseInfo
    releasedPackages <- splitLines <$> readTextFile UTF8 orderFiles.releasedPkgsFile
    let
      { unfinishedPkgsGraph } = getDependencyGraph nextReleaseInfo releasedPackages
    writeTextFile UTF8 orderFiles.releaseOrderFile
      $ linearizePackageDependencyOrder (simplifyReleaseInfoRecord nextReleaseInfo) unfinishedPkgsGraph
  SpagoOrder -> do
    dtjResult <- withSpawnResult =<< spawnAff "dhall-to-json" [ "--file", orderFiles.lastStablePackageSet ]
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
    releasedPackages <- splitLines <$> readTextFile UTF8 orderFiles.releasedPkgsFile
    deprecatedPkgs <- splitLines <$> readTextFile UTF8 orderFiles.deprecatedPkgsFile
    let
      { unfinishedPkgsGraph } = getDependencyGraph nextReleaseInfo (releasedPackages <> deprecatedPkgs)
    writeTextFile UTF8 orderFiles.spagoOrderFile
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

