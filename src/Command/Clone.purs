module Command.Clone where

import Prelude

import Constants (libDir)
import Data.Either (Either(..))
import Data.Foldable (traverse_)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.Tuple (Tuple(..))
import Effect.Aff.Class (class MonadAff)
import Effect.Class.Console (log)
import Node.Path as Path
import Packages (packages)
import Tools.Gh (ghRepoFork)
import Types (GitHubOwner, GitHubRepo, Package, PackageInfo)

cloneAll
  :: forall m
   . MonadAff m
  => Maybe GitHubOwner
  -> m Unit
cloneAll orgName = do
  traverse_ (flip (clone <<< Right) orgName) packages
  log ""
  log $ "`git clone`d all core, contrib, node, and web libraries"

clone
  :: forall m
   . MonadAff m
  => Either
       { owner :: GitHubOwner, repo :: GitHubRepo, package :: Package }
       PackageInfo
  -> Maybe GitHubOwner
  -> m Unit
clone pkgInfo org = do
  let
    Tuple dir ghArgs@{ owner, repo } = case pkgInfo of
      Left { owner, repo, package } -> do
        let dir = Path.concat [ libDir, unwrap package ]
        Tuple dir { owner, repo, orgName: org, cloneLocallyTo: Just dir }
      Right { owner, repo, package } -> do
        let dir = Path.concat [ libDir, unwrap package ]
        Tuple dir { owner, repo, orgName: org, cloneLocallyTo: Just dir }
  void $ ghRepoFork ghArgs
  log $ "Cloned '" <> unwrap owner <> "/" <> unwrap repo <> "' to " <> dir
