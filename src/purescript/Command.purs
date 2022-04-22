module Command where


import Data.Either (Either)
import Data.Maybe (Maybe)
import Data.Version (Version)
import Node.Path (FilePath)
import Types (BranchName, GitHubOwner, GitHubProject, Package, PackageInfo)

data Command
  -- | Initializes the project structure
  = Init
  -- | Gets a local copy of the purs binary from GitHub
  | DownloadPurs (Maybe Version)
  -- | Clone all packages
  | CloneAll (Maybe GitHubOwner)
  -- | Runs all update actions across all repos
  | UpdateAll
  -- | Clone a repo locally with the option of making a fork
  | Clone (Either { owner :: GitHubOwner, repo :: GitHubProject, package :: Package } PackageInfo) (Maybe GitHubOwner)
  -- | Update bower.json file
  | Bower { package :: Package }
  -- | Update spago.dhall and packages.dhall files
  | Spago { package :: Package }
  -- | Compile the package
  | Compile { package :: Package, clearBowerCache :: Boolean }
  -- | Update package.json file
  | PackageJson { package :: Package }
  -- | Update eslintrc.json file
  | Eslint { package :: Package }
  -- | Update ci.yml file
  | CI { package :: Package }
  -- | Check for any deprecations
  | Check { package :: Package }
  -- | Create a PR
  | MakePr { package :: Package }
  | GenReleaseInfo
  | ReleaseOrder
  | MakeNextReleaseBatch { submitPr :: Boolean, branchName :: Maybe BranchName, deleteBranchIfExist :: Boolean, keepPrBody :: Boolean }
  | GetFile (Array FilePath)
  -- | Show examples
  | ShowExamples
