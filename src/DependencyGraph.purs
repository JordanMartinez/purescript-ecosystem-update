module DependencyGraph where

import Prelude

import Constants (releaseFiles)
import Control.Monad.Rec.Class (Step(..), tailRec)
import Data.Argonaut.Decode (decodeJson, parseJson, printJsonDecodeError)
import Data.Array (sortBy)
import Data.Array as Array
import Data.Either (either, hush)
import Data.Foldable (foldl, maximum)
import Data.FunctorWithIndex (mapWithIndex)
import Data.HashMap (HashMap, lookup, toArrayBy)
import Data.HashMap as HM
import Data.HashMap as HashMap
import Data.HashSet (HashSet)
import Data.HashSet as HashSet
import Data.HashSet as Set
import Data.List (List(..))
import Data.List as List
import Data.Maybe (Maybe(..), fromMaybe, maybe)
import Data.Newtype (unwrap)
import Data.String as String
import Data.String.CodeUnits as SCU
import Data.String.Utils (padEnd)
import Data.Version (Version)
import Data.Version as Version
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Exception (throw)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.FS.Sync (exists)
import Node.Path (dirname)
import Partial.Unsafe (unsafeCrashWith)
import Record as Record
import Safe.Coerce (coerce)
import Type.Proxy (Proxy(..))
import Types (BranchName, GitCloneUrl, GitHubOwner, GitHubProject, Package(..))
import Utils (mkdir, splitLines)

type NextReleaseInfo =
  { pkg :: Package
  , repoUrl :: GitCloneUrl
  , repoOrg :: GitHubOwner
  , repoProj :: GitHubProject
  , defaultBranch :: BranchName
  , gitTags :: Array String
  , inBowerRegistry :: Boolean
  , hasBowerJsonFile :: Boolean
  , bowerDependencies :: Array Package
  , bowerDevDependencies :: Array Package
  , hasSpagoDhallFile :: Boolean
  , spagoDependencies :: Array Package
  , hasTestDhallFile :: Boolean
  , spagoTestDependencies :: Array Package
  }

-- | `version` is one of the following:
-- | - `BranchName` - when doing the initial update
-- | - `Version` - when doing the release
type DependenciesWithMeta version =
  { pkg :: Package
  , repoUrl :: GitCloneUrl
  , owner :: GitHubOwner
  , repo :: GitHubProject
  , defaultBranch :: BranchName
  , inBowerRegistry :: Boolean
  , version :: version
  , dependencies :: Array Package
  , depCount :: Int
  }

useNextMajorVersion :: BranchName -> Array String -> Version
useNextMajorVersion _ gitTags = do
  gitTags
    # map parseVersion
    # Array.catMaybes
    # maximum
    # maybe
        (Version.version 1 0 0 Nil Nil)
        Version.bumpMajor
  where
  parseVersion :: String -> Maybe Version
  parseVersion versionStr =
    fromMaybe versionStr (String.stripPrefix (String.Pattern "v") versionStr)
      # Version.parseVersion
      -- drop any prerelease or build meta info
      # map
          ( Version.runVersion \mjr mnr p _ _ ->
              Version.version mjr mnr p Nil Nil
          )
      # hush

useBranchName :: BranchName -> Array String -> BranchName
useBranchName b _ = b

generateAllReleaseInfo
  :: forall version
   . (BranchName -> Array String -> version)
  -> Aff
       { fullGraph :: HashMap Package (DependenciesWithMeta version)
       , unfinishedPkgsGraph :: HashMap Package (DependenciesWithMeta version)
       }
generateAllReleaseInfo f = do
  unlessM (liftEffect $ exists releaseFiles.releasedPkgsFile) do
    mkdir (dirname releaseFiles.releasedPkgsFile) { recursive: true }
    writeTextFile UTF8 releaseFiles.releasedPkgsFile ""
  generateAllReleaseInfo'
    { nextReleaseInfo: releaseFiles.nextReleaseInfo
    , releasedPkgsFile: releaseFiles.releasedPkgsFile
    }
    f

generateAllReleaseInfo'
  :: forall version
   . { nextReleaseInfo :: String
     , releasedPkgsFile :: String
     }
  -> (BranchName -> Array String -> version)
  -> Aff
       { fullGraph :: HashMap Package (DependenciesWithMeta version)
       , unfinishedPkgsGraph :: HashMap Package (DependenciesWithMeta version)
       }
generateAllReleaseInfo' { nextReleaseInfo, releasedPkgsFile } extractVersion = do
  releaseInfoContent <- readTextFile UTF8 nextReleaseInfo
  (releaseInfo :: Object NextReleaseInfo) <- do
    either (liftEffect <<< throw <<< printJsonDecodeError) pure
      $ parseJson releaseInfoContent >>= decodeJson
  releasedPkgsContent <- readTextFile UTF8 releasedPkgsFile
  let
    depsToRemove :: Array Package
    depsToRemove = releasedPkgsContent
      # splitLines
      # map String.trim
      # Array.filter ((/=) "")
      # (coerce :: Array String -> Array Package)

    releaseInfoWithVersion = releaseInfo <#> \v -> v
      # Record.insert (Proxy :: Proxy "version") (extractVersion v.defaultBranch v.gitTags)
      # Record.delete (Proxy :: Proxy "gitTags")

    fullPackageGraph :: HM.HashMap Package (Set.HashSet Package)
    fullPackageGraph = releaseInfo # flip foldl HM.empty \acc next -> do
      HM.insert
        next.pkg
        ( Set.fromFoldable $
            if next.hasBowerJsonFile then next.bowerDependencies <> next.bowerDevDependencies
            else if next.hasSpagoDhallFile then next.spagoDependencies <> next.spagoTestDependencies
            else []
        )
        acc

    fullGraphWithMeta = fullPackageGraph
      # findAllTransitiveDeps
      # mapWithIndex \k v -> do
          case Object.lookup (unwrap k) releaseInfoWithVersion of
            Nothing -> unsafeCrashWith $
              "Impossible happened: '" <> unwrap k <> "' does not exist in object map."
            Just { pkg, repoUrl, repoOrg, repoProj, defaultBranch, version, inBowerRegistry } ->
              { pkg
              , repoUrl
              , owner: repoOrg
              , repo: repoProj
              , defaultBranch
              , version
              , inBowerRegistry
              , dependencies: v
              }

    finalVal
      { pkg, repoUrl, owner, repo, defaultBranch, version, inBowerRegistry }
      dependencies
      depCount =
      { pkg, repoUrl, owner, repo, defaultBranch, version, inBowerRegistry, dependencies, depCount }

    fullGraph = fullGraphWithMeta
      <#> \v -> finalVal v (Set.toArray v.dependencies) (Set.size v.dependencies)

    unfinishedPkgsGraph =
      (foldl (flip HashMap.delete) fullGraphWithMeta depsToRemove)
        <#> \v -> do
          let newDeps = foldl (flip Set.delete) v.dependencies depsToRemove
          finalVal v (Set.toArray newDeps) (Set.size newDeps)

  pure { fullGraph, unfinishedPkgsGraph }

findAllTransitiveDeps :: HashMap Package (HashSet Package) -> HashMap Package (HashSet Package)
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

removeFinishedDeps :: Array Package -> HashMap Package (HashSet Package) -> HashMap Package (HashSet Package)
removeFinishedDeps [] packageMap = packageMap
removeFinishedDeps depsToRemove packageMap = do
  let removedKeys = foldl (flip HashMap.delete) packageMap depsToRemove
  removedKeys <#> \deps ->
    foldl (flip Set.delete) deps depsToRemove

type LinearPackageDependencyInfo r =
  { pkg :: Package
  , owner :: GitHubOwner
  , repo :: GitHubProject
  , dependencies :: Array Package
  , depCount :: Int
  | r
  }

linearizePackageDependencyOrder
  :: forall version
   . HashMap Package (DependenciesWithMeta version)
  -> String
linearizePackageDependencyOrder =
  toArrayBy (\_ r -> r)
    >>> sortBy
      ( \l r ->
          case compare l.depCount r.depCount of
            EQ -> compare l.pkg r.pkg
            x -> x
      )
    >>> mkOrderedContent
  where
  mkOrderedContent :: forall r. Array (LinearPackageDependencyInfo r) -> String
  mkOrderedContent arr = foldResult.str
    where
    githubRepo owner repo = "https://github.com/" <> unwrap owner <> "/" <> unwrap repo
    maxLength = foldl maxPartLength { dep: 0, package: 0, repo: 0 } arr
    maxPartLength acc r =
      { dep: max acc.dep $ SCU.length $ show r.depCount
      , package: max acc.package $ SCU.length $ unwrap r.pkg
      , repo: max acc.repo $ SCU.length $ githubRepo r.owner r.repo
      }
    foldResult = foldl buildLine { init: true, str: "" } arr
    buildLine acc r = do
      let
        depCount = padEnd maxLength.dep $ show r.depCount
        package = padEnd maxLength.package $ unwrap r.pkg
        repo = padEnd maxLength.repo $ githubRepo r.owner r.repo
        nextLine = depCount <> " " <> package <> " " <> repo <> " " <> show r.dependencies
      { init: false
      , str: if acc.init then nextLine else acc.str <> "\n" <> nextLine
      }
