module Command where

import Data.Either (Either)
import Data.Maybe (Maybe)
import Data.Version (Version)
import Node.Path (FilePath)
import Types (BranchName, GitHubOwner, GitHubProject, Package, PackageInfo)

data Command
  = Init
  | DownloadPurs (Maybe Version)
  | Clone (Either { owner :: GitHubOwner, repo :: GitHubProject, package :: Package } PackageInfo) (Maybe GitHubOwner)
  | CloneAll (Maybe GitHubOwner)
  | Bower { package :: PackageInfo }
  | Spago { package :: PackageInfo }
  | PackageJson { package :: PackageInfo }
  | CI { package :: PackageInfo }
  | CheckForDeprecated { package :: PackageInfo }
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
  | MakePr { package :: PackageInfo }
  | GenReleaseInfo
  | ReleaseOrder
  | MakeNextReleaseBatch { submitPr :: Boolean, branchName :: Maybe BranchName, deleteBranchIfExist :: Boolean, keepPrBody :: Boolean }
  | EcosystemChangelog
  | GetFile (Array FilePath)
