module Command.Init where

import Prelude

import Command.DownloadPurs (downloadPursBinary)
import Constants (getFileDir)
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
import Node.Path as Path
import Tools.Gh (checkGhGitProtocol, checkLoggedIntoGh)
import Utils (execAff, mkdir)

init :: Aff Unit
init = do
  verifyToolConstraints
  checkLoggedIntoGh
  checkGhGitProtocol
  downloadPursBinary Nothing
  mkInitialDirectories

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
  checkTool { toolName, fullCommand, minVersion, fixupVersionStr } = do
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
            # fixupVersionStr
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
        , fixupVersionStr: String.takeWhile ((/=) (codePointFromChar '\n'))
        }
    , checkTool
        { toolName: "bower"
        , fullCommand: "bower --version"
        , minVersion: version 1 8 13 Nil Nil
        , fixupVersionStr: identity
        }
    , checkTool
        { toolName: "psa"
        , fullCommand: "psa --version"
        , minVersion: version 0 8 2 Nil Nil
        , fixupVersionStr: identity
        }
    , checkTool
        { toolName: "spago"
        , fullCommand: "spago --version"
        , minVersion: version 0 20 7 Nil Nil
        , fixupVersionStr: identity
        }
    , checkTool
        { toolName: "esbuild"
        , fullCommand: "esbuild --version"
        , minVersion: version 0 14 23 Nil Nil
        , fixupVersionStr: identity
        }
    , checkTool
        { toolName: "lebab"
        , fullCommand: "lebab --version"
        , minVersion: version 3 1 1 Nil Nil
        , fixupVersionStr: identity
        }
    , checkTool
        { toolName: "eslint"
        , fullCommand: "eslint --version"
        , minVersion: version 8 10 0 Nil Nil
        , fixupVersionStr: identity
        }
    , checkTool
        { toolName: "purs-tidy"
        , fullCommand: "purs-tidy --version"
        , minVersion: version 0 7 1 Nil Nil
        , fixupVersionStr: identity
        }
    , checkTool
        { toolName: "git"
        , fullCommand: "git --version"
        , minVersion: version 2 25 1 Nil Nil
        , fixupVersionStr: identity
        }
    , checkTool
        { toolName: "gh"
        , fullCommand: "gh --version"
        , minVersion: version 2 7 0 Nil Nil
        , fixupVersionStr: String.takeWhile ((/=) (codePointFromChar '('))
        }
    , checkTool
        { toolName: "jq"
        , fullCommand: "jq --version"
        -- JQ doesn't abide by semver:
        -- `jq --version` produces `jq-1.6`
        -- So, this hack adds a '.0' to the end of the string
        , minVersion: version 1 6 0 Nil Nil
        , fixupVersionStr: \s -> s <> ".0"
        }
    ]

mkInitialDirectories :: forall m. MonadAff m => m Unit
mkInitialDirectories = do
  let
    files = "files"
  liftAff $ mkdir (Path.concat [ files, "changelogs" ]) { recursive: true }
  liftAff $ mkdir (Path.concat [ files, "pr" ]) { recursive: true }
  liftAff $ mkdir (Path.concat [ files, "release" ]) { recursive: true }
  liftAff $ mkdir (Path.concat [ files, "spago" ]) { recursive: true }
  liftAff $ mkdir getFileDir { recursive: true }
  liftAff $ mkdir (Path.concat [ files, "purs-tidy" ]) { recursive: true }
  liftAff $ mkdir (Path.concat [ files, "package-graph" ]) { recursive: true }
