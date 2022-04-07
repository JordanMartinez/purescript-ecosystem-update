module Tools.Gh where

import Prelude

import Data.Array as Array
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (liftEffect)
import Effect.Exception (throw)
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
