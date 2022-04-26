module Command.LibOrder where

import Prelude

import Command (DependencyStage(..))
import Constants (releaseFiles)
import Data.Array (foldl, sortBy)
import Data.HashMap (HashMap, toArrayBy)
import Data.HashSet (HashSet)
import Data.HashSet as Set
import Data.Newtype (unwrap)
import Data.String.CodeUnits as SCU
import Data.String.Utils (padEnd)
import DependencyGraph (getDependencyGraph, getNextReleaseInfo)
import Effect.Aff (Aff)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Types (GitHubOwner, GitHubRepo, Package, ReleaseInfo)
import Utils (justOrCrash, splitLines)

generateLibOrder :: DependencyStage -> Aff Unit
generateLibOrder depStage = do
  nextReleaseInfo <- getNextReleaseInfo
  case depStage of
    UpdateOrder -> do
      updatedPackages <- splitLines <$> readTextFile UTF8 releaseFiles.updatedPkgsFile
      let
        { unfinishedPkgsGraph } = getDependencyGraph nextReleaseInfo updatedPackages
      writeTextFile UTF8 releaseFiles.updateOrderFile
        $ linearizePackageDependencyOrder nextReleaseInfo unfinishedPkgsGraph
    ReleaseOrder -> do
      releasedPackages <- splitLines <$> readTextFile UTF8 releaseFiles.releasedPkgsFile
      let
        { unfinishedPkgsGraph } = getDependencyGraph nextReleaseInfo releasedPackages
      writeTextFile UTF8 releaseFiles.releaseOrderFile
        $ linearizePackageDependencyOrder nextReleaseInfo unfinishedPkgsGraph
  where
  linearizePackageDependencyOrder
    :: forall lastVersion nextVersion
    . Object (ReleaseInfo lastVersion nextVersion)
    -> HashMap Package (HashSet Package)
    -> String
  linearizePackageDependencyOrder releaseInfo =
    toArrayBy (\k v -> do
      let
        { owner, repo } = justOrCrash "Impossible. Package is not in release info JSON file"
          $ Object.lookup (unwrap k) releaseInfo
      { package: k
      , depCount: Set.size v
      , dependencies: Set.toArray v
      , owner
      , repo
      }
    )
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
          , owner :: GitHubOwner
          , repo :: GitHubRepo
          }
      -> String
    mkOrderedContent arr = foldResult.str
      where
      githubRepo owner repo = "https://github.com/" <> unwrap owner <> "/" <> unwrap repo
      maxLength = foldl maxPartLength { dep: 0, package: 0, repo: 0 } arr
      maxPartLength acc r =
        { dep: max acc.dep $ SCU.length $ show r.depCount
        , package: max acc.package $ SCU.length $ unwrap r.package
        , repo: max acc.repo $ SCU.length $ githubRepo r.owner r.repo
        }
      foldResult = foldl buildLine { init: true, str: "" } arr
      buildLine acc r = do
        let
          depCount = padEnd maxLength.dep $ show r.depCount
          package = padEnd maxLength.package $ unwrap r.package
          repo = padEnd maxLength.repo $ githubRepo r.owner r.repo
          nextLine = depCount <> " " <> package <> " " <> repo <> " " <> show r.dependencies
        { init: false
        , str: if acc.init then nextLine else acc.str <> "\n" <> nextLine
        }

