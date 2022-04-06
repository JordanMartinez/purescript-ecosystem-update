module Main where

import Prelude

import ArgParse.Basic as Arg
import CLI (parseCliArgs)
import Data.Array as Array
import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Console as Console
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
        _ -> Console.log "Command not yet implemented"
