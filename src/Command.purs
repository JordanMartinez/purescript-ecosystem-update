module Command where

import Prelude

import Data.Either (Either)
import Data.Maybe (Maybe)
import Data.Version (Version)
import Node.Path (FilePath)
import Types (BranchName, GitHubOwner, GitHubRepo, Package, PackageInfo)

data Command
  = Init
  | DownloadPurs (Maybe Version)
  | Clone (Either { owner :: GitHubOwner, repo :: GitHubRepo, package :: Package } PackageInfo) (Maybe GitHubOwner)
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
  | MakeUpdatePr { package :: PackageInfo, openWeb :: Boolean }
  | GenReleaseInfo
  | LibOrder DependencyStage
  | MakeNextReleaseBatch { submitPr :: Boolean, branchName :: Maybe BranchName, deleteBranchIfExist :: Boolean, keepPrBody :: Boolean }
  | EcosystemChangelog
  | GetFile GetFileOutput (Array FilePath)
  | GenPackageSetInfo

data DependencyStage
  = UpdateOrder
  | ReleaseOrder
  | SpagoOrder

derive instance Eq DependencyStage
derive instance Ord DependencyStage

data GetFileOutput
  = AsSummaryFile
  | AsKeyedDirectory String Boolean

derive instance Eq GetFileOutput
derive instance Ord GetFileOutput
