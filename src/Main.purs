module Main where

import Prelude

import ArgParse.Basic as Arg
import CLI (parseCliArgs)
import Command (Command(..))
import Command.Bower as BowerCmd
import Command.CheckForDeprecated as CheckForDeprecatedCmd
import Command.Clone as CloneCmd
import Command.Compile as CompileCmd
import Command.DownloadPurs as DownloadPursCmd
import Command.Ecosystem as EcosystemCmd
import Command.GetFile as GetFileCmd
import Command.Init as InitCmd
import Command.LibOrder as LibOrderCmd
import Command.Release as ReleaseCmd
import Command.ReleaseInfo as RelaseInfoCmd
import Command.Spago as SpagoCmd
import Command.UpdatePr as MakeUpdatePrCmd
import Data.Array as Array
import Data.Either (Either(..), either)
import Effect (Effect)
import Effect.Aff (runAff_)
import Effect.Class (liftEffect)
import Effect.Console as Console
import Effect.Exception (throwException)
import Node.Process (argv)
import Utils (setProcessExitCode)

main :: Effect Unit
main = do
  args <- Array.drop 2 <$> argv
  case parseCliArgs args of
    Left err -> do
      Console.log $ Arg.printArgError err
      case err of
        Arg.ArgError _ Arg.ShowHelp ->
          setProcessExitCode 0
        Arg.ArgError _ (Arg.ShowInfo _) ->
          setProcessExitCode 0
        _ ->
          setProcessExitCode 1
    Right cmd -> runAff_ (either throwException $ const $ pure unit) do
      case cmd of
        Init -> do
          InitCmd.init
        DownloadPurs mbVersion -> do
          DownloadPursCmd.downloadPursBinary mbVersion
        Clone info org -> do
          CloneCmd.clone info org
        CloneAll org ->
          CloneCmd.cloneAll org
        Bower opts -> do
          BowerCmd.updatePackageDepsToBranchVersion opts
        Spago opts -> do
          SpagoCmd.updatePackageSet opts
        Compile opts -> do
          CompileCmd.compile opts
        CheckForDeprecated opts -> do
          CheckForDeprecatedCmd.checkForDeprecated opts
        MakeUpdatePr opts ->
          MakeUpdatePrCmd.createPrForUpdate opts
        LibOrder depStage ->
          LibOrderCmd.generateLibOrder depStage
        MakeNextReleaseBatch opts ->
          ReleaseCmd.createPrForNextReleaseBatch opts
        GenReleaseInfo ->
          RelaseInfoCmd.generateReleaseInfo
        GetFile outputType filePaths ->
          GetFileCmd.getFile outputType filePaths
        EcosystemChangelog ->
          EcosystemCmd.generateEcosystemChangelog
        GenPackageSetInfo ->
          RelaseInfoCmd.generatePackageSetInfo
        _ -> do
          liftEffect $ Console.log "Command not yet implemented"
