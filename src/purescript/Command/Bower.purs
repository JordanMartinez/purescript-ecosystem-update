module Command.Bower where

-- import Prelude

-- import Data.Array (foldMap)
-- import Data.Array as Array
-- import Data.Int (floor)
-- import Data.Maybe (Maybe(..))
-- import Data.Newtype (unwrap)
-- import Effect.Aff (bracket)
-- import Effect.Aff.Class (class MonadAff, liftAff)
-- import Effect.Class (liftEffect)
-- import Effect.Class.Console (log)
-- import Effect.Ref as Ref
-- import Node.Buffer as Buffer
-- import Node.ChildProcess as CP
-- import Node.FS (FileFlags(..))
-- import Node.FS.Aff (fdClose, fdNext, fdOpen, fdWrite)
-- import Node.FS.Stats (Stats(..))
-- import Node.Path as Path
-- import Node.Stream as Stream
-- import Packages (packages)
-- import Types (Package)
-- import Utils (fdStatAff, spawnAff', withSpawnResult')

-- updateDependenciesToMain :: forall m. MonadAff m => Package -> m Unit
-- updateDependenciesToMain pkg = do
--   fileExistsRef <- liftEffect $ Ref.new false
--   liftAff $ bracket (fdOpen bowerJsonFile W_PLUS Nothing) fdClose \fd -> do
--     liftEffect $ Ref.write true fileExistsRef
--     fileByteSize <- liftAff $ (\(Stats s) -> floor s.size) <$> fdStatAff fd
--     buf <- liftEffect $ Buffer.create fileByteSize
--     void $ liftAff $ fdNext fd buf
--     let
--       inPkgDir opt = opt { cwd = Just $ Path.concat [ "..", unwrap pkg ] }
--     jqProcess <- liftAff $ spawnAff' "jq" [ jqScriptUpdateDepsToMain ] inPkgDir

--     -- We're losing possible debug info here:
--     --   - whether `write` returned true/false
--     --   - whether the callback was evoked with an error or not
--     -- but I'm going with this for the time being...
--     liftEffect $ void $ Stream.write (CP.stdin jqProcess) buf (pure unit)
--     { stdout: newFileContentBuf } <- liftAff $ withSpawnResult' jqProcess
--     len <- liftEffect $ Buffer.size newFileContentBuf
--     void $ liftAff $ fdWrite fd newFileContentBuf 0 len Nothing

--     -- we could just run these commands trust that they work...
--     -- ... or we could parse their output and verify that the file
--     -- is the only one added, and only run `git commit` if so.
--     -- void $ execAff "git add " <> bowerJsonFile
--     -- void $ execAff "git commit -m " <> message

--   fileExisted <- liftEffect $ Ref.read fileExistsRef
--   unless fileExisted do
--     log $ "Cannot update " <> bowerJsonFile <> " since file does not exist."

-- jqScriptUpdateDepsToMain :: String
-- jqScriptUpdateDepsToMain = wrapS "'" $ packages # foldMap \p -> do
--   Array.fold
--     [ "if has"
--     , wrapParens $ wrapQuotes $ unwrap p.project
--     , " then ."
--     , wrapQuotes $ unwrap p.project
--     , " |= "
--     , wrapQuotes $ unwrap p.defaultBranch
--     , " else . end |\n"
--     ]
--   where
--   wrapQuotes = wrapS "\""
--   wrapS bound = wrap bound bound
--   wrapParens = wrap "(" ")"
--   wrap l r s = l <> s <> r