module Main where

import Prelude

import ArgParse.Basic as Arg
import CLI (parseCliArgs)
import Command (Command(..))
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
        Init -> runAff_ (either throwException $ const $ pure unit) InitCmd.init
        _ -> Console.log "Command not yet implemented"
