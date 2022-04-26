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

newtype GitHubRepo = GitHubRepo String

derive instance Eq GitHubRepo
derive instance Ord GitHubRepo
derive instance Newtype GitHubRepo _
derive newtype instance Show GitHubRepo
derive newtype instance EncodeJson GitHubRepo
derive newtype instance DecodeJson GitHubRepo

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

type PackageInfoRows r =
  ( package :: Package
  , owner :: GitHubOwner
  , repo :: GitHubRepo
  , gitUrl :: GitCloneUrl
  , defaultBranch :: BranchName
  , inBowerRegistry :: Boolean
  | r
  )
type PackageInfo = { | PackageInfoRows () }

type ReleaseInfoRows lastVersion nextVersion r =
  ( lastVersion :: Maybe lastVersion
  , nextVersion :: nextVersion
  , hasBowerJsonFile :: Boolean
  , bowerDependencies :: Array Package
  , bowerDevDependencies :: Array Package
  , hasSpagoDhallFile :: Boolean
  , spagoDependencies :: Array Package
  , hasTestDhallFile :: Boolean
  , spagoTestDependencies :: Array Package
  | r
  )
type ReleaseInfo lastVersion nextVersion =
  { | ReleaseInfoRows lastVersion nextVersion (PackageInfoRows ()) }
