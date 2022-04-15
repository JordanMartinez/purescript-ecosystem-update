-- | This file is a wrapper around the
-- | Command module with the same name
-- | because parts of `HashMap` get removed
-- | when `purs bundle` is used.
module Scripts.Release where

import Prelude

import Command.Release (createPrForNextReleaseBatch)
import Effect (Effect)
import Effect.Aff (launchAff_)

main :: Effect Unit
main = launchAff_ do
  createPrForNextReleaseBatch