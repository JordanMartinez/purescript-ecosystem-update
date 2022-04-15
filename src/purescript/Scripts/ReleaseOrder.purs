module Scripts.ReleaseOrder where

import Prelude

import Data.Argonaut.Decode (decodeJson, parseJson, printJsonDecodeError)
import Data.Array as Array
import Data.Either (Either(..), either)
import Data.Foldable (foldl, maximum)
import Data.FunctorWithIndex (mapWithIndex)
import Data.HashMap as HM
import Data.HashSet as Set
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.String as String
import Data.Traversable (traverse)
import Data.Version as Version
import DependencyGraph (findAllTransitiveDeps, mkOrderedContent, mkSortedPackageArray, removeFinishedDeps)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Effect.Exception (throw)
import Foreign.Object (Object)
import Foreign.Object as Object
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.Path as Path
import Partial.Unsafe (unsafeCrashWith)
import Record as Record
import Safe.Coerce (coerce)
import Type.Proxy (Proxy(..))
import Types (BranchName, GitCloneUrl, GitHubOwner, GitHubProject, Package(..))

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
  releaseInfoContent <- readTextFile UTF8 $ Path.concat [ releaseDir, "next-release-info_2022-04-15T13:28:12.552Z.json" ]
  (releaseInfo :: Object ReleaseInfo) <- either (liftEffect <<< throw <<< printJsonDecodeError) pure $ parseJson releaseInfoContent >>= decodeJson
  releasedPkgsContent <- readTextFile UTF8 $ Path.concat [ releaseDir, "released-pkgs" ]
  let
    depsToRemove :: Array Package
    depsToRemove = releasedPkgsContent
      # String.split (String.Pattern "\n")
      # map String.trim
      # Array.filter ((/=) "")
      # (coerce :: Array String -> Array Package)

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
  writeTextFile UTF8 (Path.concat [ releaseDir, "library-release-order"]) orderedContent
