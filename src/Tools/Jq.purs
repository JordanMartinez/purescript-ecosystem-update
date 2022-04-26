module Tools.Jq where

import Prelude

import Constants (jqScripts)
import Data.Array as Array
import Data.Foldable (foldl)
import Data.Newtype (unwrap)
import Data.Version as Version
import Effect.Aff (Aff)
import Foreign.Object (Object)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (writeTextFile)
import Types (GitHubOwner, GitHubRepo, ReleaseInfo)
import Utils (rightOrCrash)

regenerateJqBowerUpdateScripts
  :: Object (ReleaseInfo String String)
  -> Aff Unit
regenerateJqBowerUpdateScripts nextReleaseInfo = do
  let
    branchVersion = nextReleaseInfo # map \{ inBowerRegistry, owner, repo, defaultBranch } -> do
      { inBowerRegistry, owner, repo, version: unwrap defaultBranch }

    releaseVersion = nextReleaseInfo # map \{ inBowerRegistry, owner, repo, nextVersion } -> do
      { inBowerRegistry
      , owner
      , repo
      , version: append "^" $ Version.showVersion
          -- santiy check
          $ rightOrCrash "Invalid version" $ Version.parseVersion nextVersion
      }

  writeTextFile UTF8 jqScripts.updateBowerDepsToBranchNameVersion
    $ updateBowerDepsJqScript branchVersion
  writeTextFile UTF8 jqScripts.updateBowerDepsToReleaseVersion
    $ updateBowerDepsJqScript releaseVersion

updateBowerDepsJqScript
  :: Object { inBowerRegistry :: Boolean, owner :: GitHubOwner, repo :: GitHubRepo, version :: String }
  -> String
updateBowerDepsJqScript obj = do
  let
    updates = obj # flip foldl [] \acc info -> do
      -- if in registry
      --  "if has("purescript-node-fs") then ."purescript-node-fs" |= "^4.2.0" else . end |"
      -- if not:
      --  "if has("purescript-web-streams") then ."purescript-web-streams" |= "https://github.com/purescript-web/purescript-web-streams.git#^4.2.0" else . end |"
      let
        repo = unwrap info.repo
        owner = unwrap info.owner
      Array.snoc acc $ Array.fold
        [ "  if has(\""
        , repo
        , "\") then .\""
        , repo
        , "\" |= \""
        , if info.inBowerRegistry then info.version
          else "https://github.com/" <> owner <> "/" <> repo <> ".git#" <> info.version
        , "\" else . end |"
        ]
  Array.intercalate "\n"
    $ [ "if has(\"dependencies\") then .dependencies |= (" ]
        <> updates
        <>
          [ "  ."
          , ") else . end |"
          , "if has (\"devDependencies\") then .devDependencies |= ("
          ]
        <> updates
        <>
          [ "  ."
          , ") else . end"
          ]