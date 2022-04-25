module Tools.Jq where

import Prelude

import Constants (jqScripts)
import Data.Array as Array
import Data.Foldable (foldl)
import Data.HashMap (HashMap)
import Data.Newtype (unwrap)
import DependencyGraph (DependenciesWithMeta, generateAllReleaseInfo, useBranchName)
import Effect.Aff (Aff)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (writeTextFile)
import Types (Package)

regenerateJqScriptBranchVersions :: Aff Unit
regenerateJqScriptBranchVersions = do
  { fullGraph } <- generateAllReleaseInfo useBranchName
  writeTextFile UTF8 jqScripts.updateBowerDepsToBranchNameVersion
    $ updateBowerDepsJqScript unwrap fullGraph

updateBowerDepsJqScript
  :: forall version
   . (version -> String)
  -> HashMap Package (DependenciesWithMeta version)
  -> String
updateBowerDepsJqScript showVersion fullGraph = do
  let
    updates = fullGraph # flip foldl [] \acc info -> do
      -- if in registry
      --  "if has("purescript-node-fs") then ."purescript-node-fs" |= "^4.2.0" else . end |"
      -- if not:
      --  "if has("purescript-web-streams") then ."purescript-web-streams" |= "https://github.com/purescript-web/purescript-web-streams.git#^4.2.0" else . end |"
      let
        repo = unwrap info.repo
        owner = unwrap info.owner
        -- versionStr = "^" <> Version.showVersion info.version
        versionStr = showVersion info.version
      Array.snoc acc $ Array.fold
        [ "  if has(\""
        , repo
        , "\") then .\""
        , repo
        , "\" |= \""
        , if info.inBowerRegistry then versionStr
          else "https://github.com/" <> owner <> "/" <> repo <> ".git#" <> versionStr
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