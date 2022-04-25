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
  -- | Clone a repo locally with the option of making a fork
  | Clone (Either { owner :: GitHubOwner, repo :: GitHubProject, package :: Package } PackageInfo) (Maybe GitHubOwner)
  -- | Clone all packages
  | CloneAll (Maybe GitHubOwner)
  -- | Runs all update actions across all repos
  | Bower { package :: PackageInfo }
  -- -- | Update spago.dhall and packages.dhall files
  | Spago { package :: PackageInfo }
  -- | Update package.json file
  | PackageJson { package :: PackageInfo }
  -- | Update ci.yml file
  | CI { package :: PackageInfo }
  -- | Check for any deprecations
  | Check { package :: PackageInfo }
  -- | Install dependencies, compile package, test it, and run lints
  | Compile
      { clearBowerCache :: Boolean
      , package :: PackageInfo
      , skipBowerInstall :: Boolean
      , skipEslint :: Boolean
      , skipFormat :: Boolean
      , skipPulp :: Boolean
      , skipSpago :: Boolean
      , skipSpagoInstall :: Boolean
      , skipTests :: Boolean
      }
  -- | Create a PR
  | MakePr { package :: PackageInfo }
  | GenReleaseInfo
  | ReleaseOrder
  | MakeNextReleaseBatch { submitPr :: Boolean, branchName :: Maybe BranchName, deleteBranchIfExist :: Boolean, keepPrBody :: Boolean }
  | EcosystemChangelog
  | GetFile (Array FilePath)
  -- | Show examples
  | ShowExamples
