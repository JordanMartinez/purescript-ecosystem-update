module Command.CheckForDeprecated where

import Prelude

import Data.Array (catMaybes, fold)
import Data.Array as Array
import Data.FoldableWithIndex (forWithIndex_)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.String.Regex (Regex, regex, source, test)
import Data.String.Regex.Flags (global, multiline)
import Data.String.Utils (lines)
import Data.Traversable (for, traverse)
import Data.TraversableWithIndex (forWithIndex)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile)
import Types (PackageInfo)
import Utils (getFilesIn, rightOrCrash)

initCmd :: Aff Unit
initCmd = do
  pure unit

checkForDeprecated :: { package :: PackageInfo } -> Aff Unit
checkForDeprecated { package: info } = do
  srcFiles <- getFilesIn info.package "src" >>= traverse printOrErrorIfPatternFound
  testFiles <- getFilesIn info.package "test" >>= traverse printOrErrorIfPatternFound
  unless (Array.null $ srcFiles <> testFiles) do
    liftEffect $ throw $ "One or more files in " <> unwrap info.package <> " needs to be updated"
  where
  printOrErrorIfPatternFound filePath = do
    lns <- lines <$> readTextFile UTF8 filePath
    map join $ for lns \l -> do
      forWithIndex_ printIfFound \i r -> do
        when (test r l) do
          log $ fold
            [ "/" <> source r <> "/ : Found match in "
            , filePath
            , ", line " <> show i
            , "\n"
            , l
            ]
          log ""
      map catMaybes $ forWithIndex failIfFound \i r -> do
        if test r l then do
          log $ fold
            [ "/" <> source r <> "/ : Found match in "
            , filePath
            , ", line " <> show i
            , "\n"
            , l
            ]
          log ""
          pure $ Just filePath
        else do
          pure Nothing

  printIfFound = map withRegex
    [ "[pP]roxy"
    , "[dD]eprecat"
    ]

  failIfFound = map withRegex
    [ "import Math"
    ]

withRegex :: String -> Regex
withRegex r = rightOrCrash ("Invalid regex: " <> r) $ regex r (multiline <> global)
