module Command.Clone where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
import Node.Path (FilePath)
import Tools.Gh (ghRepoFork)
import Types (GitHubOwner, GitHubProject, Package, PackageInfo)

clone
  :: forall m
   . MonadAff m
  => Either
      { owner :: GitHubOwner, repo :: GitHubProject, package :: Package, directory :: FilePath }
      PackageInfo
  -> Maybe GitHubOwner
  -> m Unit
clone info orgName = case info of
  Left { owner, repo, directory } -> do
    void $ ghRepoFork { owner, repo, orgName, cloneLocallyTo: Just $ "../" <> directory }
    log $ "`git clone`d '" <> unwrap owner <> "/" <> unwrap repo <> " to ../" <> directory
  Right { owner, project, name } -> do
    void $ ghRepoFork { owner, repo: project, orgName, cloneLocallyTo: Just $ "../" <> unwrap name }
    log $ "`git clone`d '" <> unwrap owner <> "/" <> unwrap project <> " to ../" <> unwrap name
