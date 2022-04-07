module Command.Clone where

import Prelude

import Data.Either (Either, either)
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
import Node.Path (FilePath)
import Packages (packages)
import Tools.Gh (ghRepoFork)
import Types (GitHubOwner, GitHubProject, Package, PackageInfo)

cloneAll
  :: forall m
   . MonadAff m
  => Maybe GitHubOwner
  -> m Unit
cloneAll orgName = do
  traverse_ (flip cloneRegular orgName) packages
  log $ "`git clone`d all core, contrib, node, and web libraries"

clone
  :: forall m
   . MonadAff m
  => Either
      { owner :: GitHubOwner, repo :: GitHubProject, package :: Package, directory :: FilePath }
      PackageInfo
  -> Maybe GitHubOwner
  -> m Unit
clone = either cloneIrregular cloneRegular

cloneIrregular
  :: forall m
   . MonadAff m
  => { owner :: GitHubOwner, repo :: GitHubProject, package :: Package, directory :: FilePath }
  -> Maybe GitHubOwner
  -> m Unit
cloneIrregular { owner, repo, directory } orgName = do
  void $ ghRepoFork { owner, repo, orgName, cloneLocallyTo: Just $ "../" <> directory }
  emitSuccessfulCloneMsg owner repo directory

cloneRegular
  :: forall m
   . MonadAff m
  => PackageInfo
  -> Maybe GitHubOwner
  -> m Unit
cloneRegular { owner, project, name } orgName = do
  void $ ghRepoFork { owner, repo: project, orgName, cloneLocallyTo: Just $ "../" <> unwrap name }
  emitSuccessfulCloneMsg owner project (unwrap name)

emitSuccessfulCloneMsg :: forall m. MonadAff m => GitHubOwner -> GitHubProject -> FilePath -> m Unit
emitSuccessfulCloneMsg owner repo directory = do
  log $ "`git clone`d '" <> unwrap owner <> "/" <> unwrap repo <> " to ../" <> directory
