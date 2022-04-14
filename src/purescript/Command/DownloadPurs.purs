module Command.DownloadPurs where

import Prelude

import Constants (purescriptTarGzFile)
import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Data.Version (Version, parseVersion, showVersion)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Node.FS.Aff (unlink)
import Node.Platform (Platform(..))
import Node.Process as Process
import Utils (execAff)

downloadPursBinary :: forall m. MonadAff m => Maybe Version -> m Unit
downloadPursBinary mbVersion = do
  { platformStr, pursFile } <- case Process.platform of
    Just Linux -> pure { platformStr: "linux64", pursFile: "purs" }
    Just Darwin -> pure { platformStr: "macos", pursFile: "purs" }
    Just Win32 -> pure { platformStr: "win64", pursFile: "purs.exe" }
    x -> liftEffect $ throw $ "Unsupported platform: " <> show x
  let
    jqGetDownloadUrl = Array.fold
      [ ".assets | map(select(.name == \""
      , platformStr
      , ".tar.gz\")) | .[0].browser_download_url"
      ]
    jqGetLatestTag = Array.fold
      [ "map(select(.prerelease == true)) | .[0]"
      ]
  { stdout: downloadUrl } <- case mbVersion of
    Nothing -> do
      liftAff $ execAff $ Array.fold
        [ "gh api repos/purescript/purescript/releases --jq '"
        , jqGetLatestTag <> jqGetDownloadUrl
        , "'"
        ]
    Just v -> do
      liftAff $ execAff $ Array.fold
        [ "gh api repos/purescript/purescript/releases/tags/v"
        , showVersion v
        , " --jq '" <> jqGetDownloadUrl <> "'"
        ]

  void $ liftAff $ execAff $ Array.fold
    [ "curl -o "
    , purescriptTarGzFile
    , " -L \""
    , downloadUrl
    , "\""
    ]
  void $ liftAff $ execAff $ Array.fold
            [ "tar -xvzf "
            , purescriptTarGzFile
            , " --strip-components 1 'purescript/"
            , pursFile
            , "'"
            ]
  liftAff $ unlink purescriptTarGzFile
  { stdout } <- liftAff $ execAff $ "./" <> pursFile <> " --version"
  case parseVersion stdout of
    Left e
      | stdout == "" ->
          liftEffect $ throw $ "Failed to download binary"
      | otherwise ->
          liftEffect $ throw $ "Failed to parse version of download purs binary: " <> show e
    Right v ->
        log $ "Downloaded purs binary with version: " <> showVersion v
