module Main where

import Prelude

import ArgParse.Basic as Arg
import CLI (parseCliArgs)
import Command (Command(..))
import Command.Clone as CloneCmd
import Command.DownloadPurs as DownloadPursCmd
import Command.GetFile as GetFileCmd
import Command.Init as InitCmd
import Command.Release as ReleaseCmd
import Command.ReleaseInfo as RelaseInfoCmd
import Command.ReleaseOrder as ReleaseOrderCmd
import Data.Array as Array
import Data.Either (Either(..), either)
import Effect (Effect)
import Effect.Aff (runAff_)
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
    Right cmd ->
      case cmd of
        Init -> do
          runAff_ (either throwException $ const $ pure unit) do
            InitCmd.init
        DownloadPurs mbVersion -> do
          runAff_ (either throwException $ const $ pure unit) do
            DownloadPursCmd.downloadPursBinary mbVersion
        Clone info org -> do
          runAff_ (either throwException $ const $ pure unit) do
            CloneCmd.clone info org
        CloneAll org ->
          runAff_ (either throwException $ const $ pure unit) do
            CloneCmd.cloneAll org
        ReleaseOrder ->
          runAff_ (either throwException $ const $ pure unit) do
            ReleaseOrderCmd.generateReleaseOrder
        MakeNextReleaseBatch opts ->
          runAff_ (either throwException $ const $ pure unit) do
            ReleaseCmd.createPrForNextReleaseBatch opts
        GenReleaseInfo ->
          runAff_ (either throwException $ const $ pure unit) do
            RelaseInfoCmd.generateReleaseInfo
        GetFile filePaths ->
          runAff_ (either throwException $ const $ pure unit) do
            GetFileCmd.getFile filePaths
        _ -> Console.log "Command not yet implemented"
