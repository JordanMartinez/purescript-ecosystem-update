module Main where

import Prelude

import Effect (Effect)
import Effect.Aff (launchAff_)

main :: Effect Unit
main = launchAff_ $ void do
  pure unit
