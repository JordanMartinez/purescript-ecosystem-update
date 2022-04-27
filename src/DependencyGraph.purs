module DependencyGraph where

import Prelude

import Constants (releaseInfoFiles)
import Control.Monad.Rec.Class (Step(..), tailRec)
import Data.Argonaut.Decode (decodeJson, parseJson, printJsonDecodeError)
import Data.Array as Array
import Data.Either (either)
import Data.Foldable (class Foldable, foldl)
import Data.HashMap (HashMap, lookup)
import Data.HashMap as HM
import Data.HashMap as HashMap
import Data.HashSet (HashSet)
import Data.HashSet as HashSet
import Data.HashSet as Set
import Data.List (List(..))
import Data.List as List
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Newtype (unwrap)
import Data.String as String
import Data.Tuple (Tuple(..))
import Data.Version (Version, version)
import Data.Version as Version
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Exception (throw)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile)
import Partial.Unsafe (unsafeCrashWith)
import Safe.Coerce (coerce)
import Type.Row (type (+))
import Types (DependencyGraphRows, Package(..), PackageRows, ReleaseInfo)

getNextReleaseInfo :: Aff (Object (ReleaseInfo String String))
getNextReleaseInfo = do
  releaseInfoContent <- readTextFile UTF8 releaseInfoFiles.nextReleaseInfo
  either (liftEffect <<< throw <<< printJsonDecodeError) pure
    $ decodeJson =<< parseJson releaseInfoContent

getDependencyGraph
  :: forall r
   . Object { | PackageRows + DependencyGraphRows r }
  -> Array String
  -> { fullGraph :: HashMap Package (HashSet Package)
     , unfinishedPkgsGraph :: HashMap Package (HashSet Package)
     }
getDependencyGraph nextReleaseInfo finishedPackages = do
  { fullGraph: graphWithTransDeps
  , unfinishedPkgsGraph
  }
  where
  graphWithTransDeps = findAllTransitiveDeps $ foldl foldFn HM.empty nextReleaseInfo
    where
    foldFn acc next = do
      HM.insert
        next.package
        ( Set.fromFoldable $
            if next.hasBowerJsonFile then next.bowerDependencies <> next.bowerDevDependencies
            else if next.hasSpagoDhallFile then next.spagoDependencies <> next.spagoTestDependencies
            else []
        )
        acc

  depsToRemove :: HashSet Package
  depsToRemove = finishedPackages
    # map String.trim
    # Array.filter ((/=) "")
    # (coerce :: Array String -> Array Package)
    # Set.fromFoldable

  unfinishedPkgsGraph =
    (foldl (flip HashMap.delete) graphWithTransDeps depsToRemove) <#> \v -> do
      Set.difference v depsToRemove

findAllTransitiveDeps
  :: HashMap Package (HashSet Package)
  -> HashMap Package (HashSet Package)
findAllTransitiveDeps packageMap = foldl buildMap HashMap.empty $ Array.filter ((/=) "" <<< unwrap) $ HashMap.keys packageMap
  where
  buildMap :: HashMap Package (HashSet Package) -> Package -> HashMap Package (HashSet Package)
  buildMap mapSoFar packageName = do
    case lookup packageName mapSoFar of
      Just _ ->
        mapSoFar
      Nothing ->
        let
          { updatedMap } = getDepsRecursively packageName mapSoFar
        in
          updatedMap

  getDepsRecursively
    :: Package
    -> HashMap Package (HashSet Package)
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

overridePackageVersions :: forall f a. Foldable f => (f a -> Tuple String Version -> f a) -> f a -> f a
overridePackageVersions overrideVersion pkgGraph = foldl overrideVersion pkgGraph packageVersionOverrides

objVersionStr
  :: forall r
   . Object { version :: String | r }
  -> Tuple String Version
  -> Object { version :: String | r }
objVersionStr obj (Tuple package version) = Object.alter
    case _ of
      Nothing -> unsafeCrashWith $ "Could not find package " <> package <> "; cannot override version"
      Just r -> Just $ r { version = append "^" $ Version.showVersion version }
    package
    obj

packageVersionOverrides :: Array (Tuple String Version)
packageVersionOverrides =
  [ Tuple "arraybuffer-types" $ version 3 0 2 Nil Nil
  , Tuple "type-equality" $ version 4 0 1 Nil Nil
  , Tuple "react" $ version 10 0 1 Nil Nil
  , Tuple "colors" $ version 7 0 1 Nil Nil
  , Tuple "quickcheck" $ version 8 0 1 Nil Nil
  , Tuple "node-fs" $ version 7 0 1 Nil Nil
  ]