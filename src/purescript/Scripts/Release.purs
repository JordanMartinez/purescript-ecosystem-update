module Scripts.Release where

import Prelude

import Data.Argonaut.Decode (decodeJson, parseJson, printJsonDecodeError)
import Data.Either (either)
import Data.Foldable (foldl)
import Data.FunctorWithIndex (mapWithIndex)
import Data.HashMap as HM
import Data.HashSet as Set
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Debug (spy, spyWith)
import DependencyGraph (findAllTransitiveDeps, mkOrderedContent, mkSortedPackageArray, removeFinishedDeps)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.Path as Path
import Partial.Unsafe (unsafeCrashWith)
import Types (BranchName, GitCloneUrl, GitHubOwner, GitHubProject, Package)

type ReleaseInfo =
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

main :: Effect Unit
main = launchAff_ do
  let
    releaseDir = Path.concat [ "files", "release" ]
  content <- readTextFile UTF8 $ Path.concat [ releaseDir, "next-release-info_2022-04-14T22:49:25.771Z.json" ]
  (releaseInfo :: Object ReleaseInfo) <- either (liftEffect <<< throw <<< printJsonDecodeError) pure $ parseJson content >>= decodeJson
  let
    depsToRemove = []
    fullPackageGraph :: HM.HashMap Package (Set.HashSet Package)
    fullPackageGraph = releaseInfo # flip foldl HM.empty \acc next -> do
      HM.insert next.pkg (Set.fromFoldable
        if next.hasBowerJsonFile then next.bowerDependencies <> next.bowerDevDependencies
        else if next.hasSpagoDhallFile then next.spagoDependencies <> next.spagoTestDependencies
        else []) acc

    unreleasedPackageGraph = removeFinishedDeps depsToRemove fullPackageGraph
    dependencyGraph = findAllTransitiveDeps unreleasedPackageGraph
    dependencyGraphWithMeta = dependencyGraph # mapWithIndex \k v ->
      case Object.lookup (unwrap k) releaseInfo of
        Nothing -> unsafeCrashWith $ "Impossible happened: '" <> unwrap k <> "' does not exist in object map."
        Just { repoOrg, repoProj } -> { owner: repoOrg, repo: repoProj, dependencies: Set.toArray v, depCount: Set.size v }
    orderedContent = mkOrderedContent $ mkSortedPackageArray dependencyGraphWithMeta
  writeTextFile UTF8 (Path.concat [ releaseDir, "release-order"]) orderedContent

  {-
  recalculate the dependency graph (the real one, not the estimated spago one)
  make the following changes:
    - update the changelog
        - read the file
        - find the first line after the '## Unreleased' header
        - split it in two
        - add the unreleased changelog content under header
        - add the release data over sectoin part
        - recombine the two
        - write to file
        - git commit
    - update the bower.json file's dependencies
        - generate the jq script
        - use `jq` to update the file using a script
        - git commit
    - potentially add `purs-tidy` to ci.yml
        - not sure but maybe `yq` can work?
  -}