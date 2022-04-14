module DependencyGraph where

import Prelude

import Control.Monad.Rec.Class (Step(..), tailRec)
import Data.Array (foldl, sortBy)
import Data.Array as Array
import Data.HashMap (HashMap, lookup, toArrayBy)
import Data.HashMap as HashMap
import Data.HashSet (HashSet)
import Data.HashSet as HashSet
import Data.HashSet as Set
import Data.List as List
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (unwrap)
import Data.String.CodeUnits as SCU
import Data.String.Utils (padEnd)
import Types (GitHubOwner, GitHubProject, Package)

findAllTransitiveDeps :: HashMap Package (HashSet Package) -> HashMap Package (HashSet Package)
findAllTransitiveDeps packageMap = foldl buildMap HashMap.empty $ Array.filter ((/=) "" <<< unwrap) $ HashMap.keys packageMap
  where
  buildMap :: HashMap Package (HashSet Package) -> Package -> HashMap Package (HashSet Package)
  buildMap mapSoFar packageName  = do
    case lookup packageName mapSoFar of
      Just _ ->
        mapSoFar
      Nothing ->
        let { updatedMap } = getDepsRecursively packageName mapSoFar
        in updatedMap

  getDepsRecursively :: Package -> HashMap Package (HashSet Package)
    -> { deps :: HashSet Package, updatedMap :: HashMap Package (HashSet Package) }
  getDepsRecursively packageName mapSoFar = do
    let
      direct = fromMaybe Set.empty $ lookup packageName packageMap
    tailRec go { packageName, mapSoFar, allDeps: direct, remaining: List.fromFoldable direct }

  go :: _ -> Step _ _
  go state@{ packageName, mapSoFar, allDeps, remaining } = case List.uncons remaining of
    Nothing -> do
      Done { deps: allDeps, updatedMap: HashMap.unionWith (HashSet.union) mapSoFar (HashMap.singleton packageName allDeps) }
    Just { head: package, tail } -> do
      case lookup packageName mapSoFar of
        Just deps -> do
          Loop $ state { allDeps = HashSet.union state.allDeps deps, remaining = tail }
        Nothing -> do
          let { deps, updatedMap } = getDepsRecursively package mapSoFar
          Loop $ state { allDeps = allDeps <> deps, mapSoFar = updatedMap, remaining = tail }

removeFinishedDeps :: Array Package -> HashMap Package (HashSet Package) -> HashMap Package (HashSet Package)
removeFinishedDeps [] packageMap = packageMap
removeFinishedDeps depsToRemove packageMap = do
  let removedKeys = foldl (flip HashMap.delete) packageMap depsToRemove
  removedKeys <#> \deps ->
      foldl (flip Set.delete) deps depsToRemove

mkSortedPackageArray :: HashMap Package { owner :: GitHubOwner, repo :: GitHubProject, dependencies :: Array Package, depCount :: Int } -> Array { package :: Package, owner :: GitHubOwner, repo :: GitHubProject, dependencies :: Array Package, depCount :: Int }
mkSortedPackageArray =
  toArrayBy (\k { owner, repo, dependencies, depCount } ->
    { package: k, owner, repo, dependencies, depCount })
  >>> sortBy (\l r ->
      case compare l.depCount r.depCount of
        EQ -> compare l.package r.package
        x -> x
  )

mkOrderedContent :: Array { package :: Package, owner :: GitHubOwner, repo :: GitHubProject, dependencies :: Array Package, depCount :: Int } -> String
mkOrderedContent arr = foldResult.str
  where
  mkFullRepo owner repo = "https://github.com/" <> unwrap owner <> "/" <> unwrap repo
  maxLength = foldl maxPartLength { dep: 0, package: 0, repo: 0 } arr
  maxPartLength acc r =
    { dep:     max acc.dep     $ SCU.length $ show r.depCount
    , package: max acc.package $ SCU.length $ unwrap r.package
    , repo:    max acc.repo    $ SCU.length $ mkFullRepo r.owner r.repo
    }
  foldResult = foldl buildLine {init: true, str: ""} arr
  buildLine acc r =
    let
      depCount = padEnd maxLength.dep $ show r.depCount
      package = padEnd maxLength.package $ unwrap r.package
      repo = padEnd maxLength.repo $ mkFullRepo r.owner r.repo
      nextLine = depCount <> " " <> package <> " " <> repo <> " " <> show r.dependencies
    in { init: false
       , str: if acc.init then nextLine else acc.str <> "\n" <> nextLine
       }
