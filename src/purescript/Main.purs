module Main where

import Prelude

import ArgParse.Basic as Arg
import CLI (parseCliArgs)
import Command (Command(..))
import Command.Bower as BowerCmd
import Command.Clone as CloneCmd
import Command.DownloadPurs as DownloadPursCmd
import Command.Init as InitCmd
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
        Bower { package } ->
          runAff_ (either throwException $ const $ pure unit) do
            BowerCmd.updateDependenciesToMain package
        _ -> Console.log "Command not yet implemented"
