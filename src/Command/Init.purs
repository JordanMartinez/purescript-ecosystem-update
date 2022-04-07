module Command.Init where

import Prelude

import Affjax as Affjax
import Affjax.ResponseFormat as RF
import Affjax.StatusCode (StatusCode(..))
import Data.Array as Array
import Data.Either (Either(..))
import Data.Enum (enumFromTo)
import Data.Filterable (partitionMap)
import Data.Foldable (for_)
import Data.List (List(..), (:))
import Data.Maybe (Maybe(..))
import Data.String (codePointFromChar)
import Data.String as String
import Data.Traversable (sequence)
import Data.Version (numeric, parseVersion, showVersion, version)
import Effect.Aff (Aff, message)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Node.Buffer (fromArrayBuffer)
import Node.FS.Aff (unlink, writeFile)
import Node.Platform (Platform(..))
import Node.Process as Process
import Utils (execAff)

init :: Aff Unit
init = do
  verifyToolConstraints
  loginToGh
  downloadLatestPursBinary

-- | Verifies that a given tool with the minimum version is installed
-- | and throws an error otherwise.
verifyToolConstraints :: forall m. MonadAff m => m Unit
verifyToolConstraints = do
  { left, right } <- partitionMap identity <$> sequence tools
  liftEffect do
    for_ right \msg -> do
      log msg
    for_ left \msg -> do
      log msg
    unless (Array.null left) do
      throw $ Array.fold
        [ "One or more tools either are not installed or need to be updated "
        , "to a higher version. Please see above error message(s)."
        ]
  where
  checkTool { toolName, fullCommand, minVersion, trimStrToVersionStr } = do
    { error, stdout } <- liftAff $ execAff fullCommand
    case error of
      Just err ->
        pure $ Left $ Array.fold
            [ "Error when attempting to get version for '"
            , toolName
            , "':\n"
            , message err
            ]
      Nothing -> do
        let
          versionStr = stdout
            # trimStrToVersionStr
            # dropWhileCharsNotDigits
            # String.trim
        case parseVersion versionStr of
          Left err -> do
            pure $ Left $ Array.fold
              [ "Could not parse version for "
              , toolName
              , ". Got error, "
              , show err
              , ", when parsing '"
              , versionStr
              , "'"
              ]
          Right v
            | v >= minVersion -> pure $ Right $ Array.fold
                [ "`" <> toolName <> "@v" <> showVersion v
                , "` is usable and is >= mininum version: "
                , showVersion minVersion
                ]
            | otherwise -> pure $ Left $ String.joinWith "\n"
              [ "`" <> toolName <> "` version is lower than minimum version required: "
              , "Expected: " <> showVersion minVersion
              , "Actual:   " <> showVersion v
              ]

  dropWhileCharsNotDigits = String.dropWhile (\cp -> Array.all (\digitCp -> cp /= digitCp) digitsCodePoints)
    where
    digitsCodePoints = codePointFromChar <$> enumFromTo '0' '9'

  tools =
    [ checkTool
        { toolName: "pulp"
        , fullCommand: "pulp --version"
        , minVersion: version 16 0 0 (numeric 0 : Nil) Nil
        , trimStrToVersionStr: String.takeWhile ((/=) (codePointFromChar '\n'))
        }
    , checkTool
        { toolName: "bower"
        , fullCommand: "bower --version"
        , minVersion: version 1 8 13 Nil Nil
        , trimStrToVersionStr: identity
        }
    , checkTool
        { toolName: "psa"
        , fullCommand: "psa --version"
        , minVersion: version 0 8 2 Nil Nil
        , trimStrToVersionStr: identity
        }
    , checkTool
        { toolName: "spago"
        , fullCommand: "spago --version"
        , minVersion: version 0 20 7 Nil Nil
        , trimStrToVersionStr: identity
        }
    , checkTool
        { toolName: "esbuild"
        , fullCommand: "esbuild --version"
        , minVersion: version 0 14 23 Nil Nil
        , trimStrToVersionStr: identity
        }
    , checkTool
        { toolName: "lebab"
        , fullCommand: "lebab --version"
        , minVersion: version 3 1 1 Nil Nil
        , trimStrToVersionStr: identity
        }
    , checkTool
        { toolName: "eslint"
        , fullCommand: "eslint --version"
        , minVersion: version 8 10 0 Nil Nil
        , trimStrToVersionStr: identity
        }
    , checkTool
        { toolName: "gh"
        , fullCommand: "gh --version"
        , minVersion: version 2 7 0 Nil Nil
        , trimStrToVersionStr: String.takeWhile ((/=) (codePointFromChar '('))
        }
    , checkTool
        { toolName: "jq"
        , fullCommand: "jq --version"
        -- JQ doesn't abide by semver:
        -- `jq --version` produces `jq-1.6`
        -- So, this hack adds a '.0' to the end of the string
        , minVersion: version 1 6 0 Nil Nil
        , trimStrToVersionStr: \s -> s <> ".0"
        }
    ]

-- | Ensures user is logged in via `gh` tool and
-- | has `git_protocol` configured to use `ssh`
loginToGh :: forall m. MonadAff m => m Unit
loginToGh = do
  authStatus <- liftAff $ execAff "gh auth status"
  when (authStatus.stdout == "You are not logged into any GitHub hosts.") do
    liftEffect $ throw $ Array.fold
      [ "You are not logged into any GitHub hosts. "
      , "Please run the following command to login to GitHub via `gh`:\n"
      , "    gh auth login --git-protocol ssh --with-token"
      ]

  protocolStatus <- liftAff $ execAff "gh config get git_protocol"
  unless (protocolStatus.stdout == "ssh") do
    liftEffect $ throw $ Array.fold
      [ "You are not using the 'ssh' git protocol."
      , "Please run the following command to change it\n"
      , "    gh config set git_protocol ssh"
      ]

downloadLatestPursBinary :: forall m. MonadAff m => m Unit
downloadLatestPursBinary = do
  { platformStr, pursFile } <- case Process.platform of
    Just Linux -> pure { platformStr: "linux64", pursFile: "purs" }
    Just Darwin -> pure { platformStr: "macos", pursFile: "purs" }
    Just Win32 -> pure { platformStr: "win64", pursFile: "purs.exe" }
    x -> liftEffect $ throw $ "Unsupported platform: " <> show x
  let
    pursDownloadFile = "purescript.tar.gz"
    jqScript = Array.fold
      [ "'map(select(.prerelease == true)) | .[0].assets | map(select(.name == \""
      , platformStr
      , ".tar.gz\")) | .[0].browser_download_url'"
      ]
  { stdout: downloadUrl } <- liftAff $ execAff $
    "gh api repos/purescript/purescript/releases --jq " <> jqScript
  res <- liftAff $ Affjax.get RF.arrayBuffer downloadUrl
  case res of
    Left err -> liftEffect $ throw $ Affjax.printError err
    Right { status, statusText, body }
      | status /= StatusCode 200 ->
          liftEffect $ throw $ Array.fold
            [ "Downloading `purs` binary resulted in non-200 HTTP status: "
            , show status
            , ": "
            , statusText
            ]
      | otherwise -> do
          buf <- liftEffect $ fromArrayBuffer body
          liftAff $ writeFile pursDownloadFile buf
          void $ liftAff $ execAff $ Array.fold
            [ "tar -xvzf "
            , pursDownloadFile
            , " --strip-components 1 'purescript/"
            , pursFile
            , "'"
            ]
          liftAff $ unlink pursDownloadFile