module Command where

import Prelude

import Data.Maybe (Maybe)
import Data.Version (Version)
import Types (GitHubOwner, Package)

data Command
  -- | Initializes the project structure
  = Init
  -- | Gets a local copy of the purs binary from GitHub
  | DownloadPurs (Maybe Version)
  -- | Clone all packages
  | CloneAll { makeFork :: Maybe GitHubOwner }
  -- | Runs all update actions across all repos
  | UpdateAll
  -- | Clone a repo locally with the option of making a fork
  | Clone { package :: Package, makeFork :: Maybe GitHubOwner }
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
  -- | Show examples
  | ShowExamples
