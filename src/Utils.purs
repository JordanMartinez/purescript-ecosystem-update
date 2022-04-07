module Utils where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe)
import Data.Posix.Signal (Signal(..))
import Data.String as String
import Effect (Effect)
import Effect.Aff (Aff, Error, effectCanceler, makeAff)
import Effect.Class (liftEffect)
import Node.Buffer as Buffer
import Node.ChildProcess as CP
import Node.Encoding (Encoding(..))

-- | Per Node docs...
-- | "Calling `process.exit()` will force the process to exit
-- | as quickly as possible even if there are still asynchronous
-- | operations pending that have not yet completed fully,
-- | including I/O operations to `process.stdout` and `process.stderr`.
-- |
-- | In most situations, it is not actually necessary to call
-- | `process.exit()` explicitly. The Node.js process will exit on its
-- | own if there is no additional work pending in the event loop.
-- | The `process.exitCode` property can be set to tell the process
-- | which exit code to use when the process exits gracefully.
-- |
-- | The reason [calling `process.exit(1)`] is problematic is because writes to
-- | `process.stdout` in Node.js are sometimes asynchronous and
-- | may occur over multiple ticks of the Node.js event loop.
-- | Calling `process.exit()`, however, forces the process
-- | to exit before those additional writes to stdout can be performed.
-- |
-- | Rather than calling `process.exit()` directly, the code should
-- | set the `process.exitCode` and allow the process to exit
-- | naturally by avoiding scheduling any additional work for the event loop:
foreign import setProcessExitCode :: Int -> Effect Unit

execAff :: String -> Aff { stdout :: String, stderr :: String, error :: Maybe Error }
execAff cmd = do
  result@{ error } <- makeAff \cb -> do
    subProcess <- CP.exec cmd CP.defaultExecOptions (cb <<< Right)
    pure $ effectCanceler do
      CP.kill SIGABRT subProcess
  { stdout, stderr } <- liftEffect do
    stdout <- String.trim <$> Buffer.toString UTF8 result.stdout
    stderr <- String.trim <$> Buffer.toString UTF8 result.stderr
    pure { stdout, stderr }
  pure { error, stdout, stderr }
