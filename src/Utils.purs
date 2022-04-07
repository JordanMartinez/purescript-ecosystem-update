module Utils where

import Prelude

import Data.Either (Either(..))
import Data.Function.Uncurried (Fn2, Fn3, runFn2, runFn3)
import Data.Maybe (Maybe(..))
import Data.Nullable (Nullable)
import Data.Posix.Signal (Signal(..))
import Data.String as String
import Effect (Effect)
import Effect.Aff (Aff, Error, effectCanceler, makeAff, nonCanceler)
import Effect.Class (liftEffect)
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Node.Buffer (Buffer)
import Node.Buffer as Buffer
import Node.ChildProcess (ChildProcess, ExecOptions, Exit(..), SpawnOptions, defaultSpawnOptions)
import Node.ChildProcess as CP
import Node.Encoding (Encoding(..))
import Node.FS (FileDescriptor)
import Node.FS.Async (Callback)
import Node.FS.Internal (mkEffect)
import Node.FS.Stats (Stats(..), StatsObj)
import Node.Stream (Readable)
import Node.Stream as Stream

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
execAff cmd = execAff' cmd identity

execAff' :: String -> (ExecOptions -> ExecOptions) -> Aff { stdout :: String, stderr :: String, error :: Maybe Error }
execAff' cmd modifyOptions  = do
  result@{ error } <- makeAff \cb -> do
    subProcess <- CP.exec cmd (modifyOptions CP.defaultExecOptions) (cb <<< Right)
    pure $ effectCanceler do
      CP.kill SIGABRT subProcess
  { stdout, stderr } <- liftEffect do
    stdout <- String.trim <$> Buffer.toString UTF8 result.stdout
    stderr <- String.trim <$> Buffer.toString UTF8 result.stderr
    pure { stdout, stderr }
  pure { error, stdout, stderr }

-- | Indicates whether an error was thrown
-- | because Node failed to spawn the process
-- | or because some other error was thrown
-- | during the process' run
data SpawnError
  = FailedToSpawn CP.Error
  | Errored CP.Error

instance Show SpawnError where
  show = case _ of
    FailedToSpawn e -> "Failed to spawn. " <> show e
    Errored e -> "Error after spawning. " <> show e

-- | Indicates whether the process exited normally
-- | or was killed
data SpawnExit
  = Exited Int
  | Killed Signal

derive instance Eq SpawnExit
instance Show SpawnExit where
  show = case _ of
    Exited i -> "Exited with code: " <> show i
    Killed s -> "Killed with signal: " <> show s

-- | All information regarding the result of `spawn`
-- | in an easily-consumable format
type SpawnResult a =
  { error :: Maybe SpawnError
  , exit :: SpawnExit
  , stdout :: a
  , stderr :: a
  }

-- | Spawn a command with its args with no concern for its options
spawnAff :: String -> Array String -> Aff ChildProcess
spawnAff cmd args = spawnAff' cmd args identity

-- | Spawn a command with its args, modifying the `defaultSpawnOptions` record
spawnAff' :: String -> Array String -> (SpawnOptions -> SpawnOptions) -> Aff ChildProcess
spawnAff' cmd args modifyOptions = liftEffect do
  CP.spawn cmd args (modifyOptions defaultSpawnOptions)

withSpawnResult :: ChildProcess -> Aff (SpawnResult String)
withSpawnResult subProcess = do
  rec@{ error, exit } <- withSpawnResult' subProcess
  stdout <- liftEffect $ Buffer.toString UTF8 rec.stdout
  stderr <- liftEffect $ Buffer.toString UTF8 rec.stderr
  pure { error, exit, stdout, stderr }

withSpawnResult' :: ChildProcess -> Aff (SpawnResult Buffer)
withSpawnResult' subProcess = makeAff \cb -> do
  stdOutRef <- streamToRef $ CP.stdout subProcess
  stdErrRef <- streamToRef $ CP.stderr subProcess

  ctorRef <- Ref.new FailedToSpawn
  errorResult <- Ref.new Nothing
  onSpawn subProcess do
    Ref.write Errored ctorRef
  CP.onError subProcess \e -> do
    ctor <- Ref.read ctorRef
    Ref.write (Just $ ctor e) errorResult
  CP.onClose subProcess \e -> do
    finalError <- Ref.read errorResult
    stdout <- Ref.read stdOutRef
    stderr <- Ref.read stdErrRef
    cb $ Right
      { error: finalError
      , exit: case e of
          Normally i -> Exited i
          BySignal sig -> Killed sig
      , stdout
      , stderr
      }
  pure nonCanceler

streamToRef :: forall x. Readable x -> Effect (Ref Buffer)
streamToRef stream = do
  buffs <- Ref.new []
  finalRef <- Ref.new =<< Buffer.create 0
  Stream.onData stream \buf -> do
    Ref.modify_ (_ <> [ buf ]) buffs
  Stream.onEnd stream do
    finalBuf <- Ref.read buffs >>= Buffer.concat
    Ref.write finalBuf finalRef
  pure finalRef

foreign import onSpawn :: ChildProcess -> Effect Unit -> Effect Unit

type JSCallback a = Fn2 (Nullable Error) a Unit

foreign import handleCallbackImpl ::
  forall a. Fn3 (Error -> Either Error a)
                (a -> Either Error a)
                (Callback a)
                (JSCallback a)

handleCallback :: forall a. (Callback a) -> JSCallback a
handleCallback cb = runFn3 handleCallbackImpl Left Right cb

fdStat
  :: FileDescriptor
  -> Callback Stats
  -> Effect Unit
fdStat fd cb = mkEffect $ \_ -> runFn2
  fdStatImpl fd (handleCallback $ cb <<< (<$>) Stats)

fdStatAff
  :: FileDescriptor
  -> Aff Stats
fdStatAff fd = makeAff \cb -> do
  fdStat fd cb
  pure nonCanceler

foreign import fdStatImpl :: Fn2 FileDescriptor (JSCallback StatsObj) Unit
