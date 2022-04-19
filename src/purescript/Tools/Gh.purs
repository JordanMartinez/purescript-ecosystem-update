module Tools.Gh where

import Prelude

import Data.Array as Array
import Data.Maybe (Maybe, maybe)
import Data.Newtype (unwrap)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (liftEffect)
import Effect.Exception (Error, throw)
import Node.Path (FilePath)
import Types (GitHubOwner, GitHubProject)
import Utils (execAff)

-- | Ensures user is logged in via `gh` tool
checkLoggedIntoGh :: forall m. MonadAff m => m Unit
checkLoggedIntoGh = do
  authStatus <- liftAff $ execAff "gh auth status"
  when (authStatus.stdout == "You are not logged into any GitHub hosts.") do
    liftEffect $ throw $ Array.fold
      [ "You are not logged into any GitHub hosts. "
      , "Please run the following command to login to GitHub via `gh`:\n"
      , "    gh auth login --git-protocol ssh --with-token"
      ]

-- | Ensures `gh` tool is configured to use `ssh`
checkGhGitProtocol :: forall m. MonadAff m => m Unit
checkGhGitProtocol = do
  protocolStatus <- liftAff $ execAff "gh config get git_protocol"
  unless (protocolStatus.stdout == "ssh") do
    liftEffect $ throw $ Array.fold
      [ "You are not using the 'ssh' git protocol."
      , "Please run the following command to change it\n"
      , "    gh config set git_protocol ssh"
      ]

-- | Forks a GitHub repo to eithe rthe user or the specific GH organization
-- | optionally cloning it to a local directory. When cloned, the original
-- | repo will use the remote name `origin` whereas the fork will use `self`
ghRepoFork
  :: forall m
   . MonadAff m
  => { cloneLocallyTo :: Maybe FilePath
     , orgName :: Maybe GitHubOwner
     , owner :: GitHubOwner
     , repo :: GitHubProject
     }
  -> m
       { error :: Maybe Error
       , stderr :: String
       , stdout :: String
       }
ghRepoFork { owner, repo, orgName: mbOrgName, cloneLocallyTo: directory } = do
  liftAff $ execAff $ Array.fold
    -- --remote = add the fork's remote to git config
    -- --remote-name = call the fork's remote 'self' so that 'origin' refers to original
    [ "gh repo fork "
    , unwrap owner <> "/" <> unwrap repo
    -- by default, do fork for user, but if org is specified, do fork for org
    , maybe "" (append " --org " <<< unwrap) mbOrgName
    -- whether to clone the repo as well or just do the fork
    , maybe " --clone=false" (\dir -> " --clone -- " <> dir) directory
    ]
