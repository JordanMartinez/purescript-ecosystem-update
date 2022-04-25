module Types where

import Prelude

import Data.Argonaut.Decode (class DecodeJson)
import Data.Argonaut.Encode (class EncodeJson)
import Data.Hashable (class Hashable)
import Data.Maybe (Maybe)
import Data.Newtype (class Newtype)

newtype Package = Package String
derive newtype instance Eq Package
derive newtype instance Ord Package
derive instance Newtype Package _
derive newtype instance Show Package
derive newtype instance Hashable Package
derive newtype instance EncodeJson Package
derive newtype instance DecodeJson Package

newtype GitHubOwner = GitHubOwner String
derive instance Eq GitHubOwner
derive instance Ord GitHubOwner
derive instance Newtype GitHubOwner _
derive newtype instance Show GitHubOwner
derive newtype instance EncodeJson GitHubOwner
derive newtype instance DecodeJson GitHubOwner

newtype GitHubProject = GitHubProject String
derive instance Eq GitHubProject
derive instance Ord GitHubProject
derive instance Newtype GitHubProject _
derive newtype instance Show GitHubProject
derive newtype instance EncodeJson GitHubProject
derive newtype instance DecodeJson GitHubProject

newtype GitCloneUrl = GitCloneUrl String
derive instance Eq GitCloneUrl
derive instance Ord GitCloneUrl
derive instance Newtype GitCloneUrl _
derive newtype instance Show GitCloneUrl
derive newtype instance EncodeJson GitCloneUrl
derive newtype instance DecodeJson GitCloneUrl

newtype BranchName = BranchName String
derive instance Eq BranchName
derive instance Ord BranchName
derive instance Newtype BranchName _
derive newtype instance Show BranchName
derive newtype instance EncodeJson BranchName
derive newtype instance DecodeJson BranchName

type PackageInfo =
  { name :: Package
  , owner :: GitHubOwner
  , project :: GitHubProject
  , gitUrl :: GitCloneUrl
  , defaultBranch :: BranchName
  , inBowerRegistry :: Boolean
  }

type ReleaseInfo version =
  { pkg :: Package
  , lastVersion :: Maybe version
  , nextVersion :: version
  , hasBowerJsonFile :: Boolean
  , bowerDependencies :: Array Package
  , bowerDevDependencies :: Array Package
  , hasSpagoDhallFile :: Boolean
  , spagoDependencies :: Array Package
  , hasTestDhallFile :: Boolean
  , spagoTestDependencies :: Array Package
  }