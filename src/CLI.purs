module CLI where

import Prelude

import ArgParse.Basic (ArgError, fromRecord, parseArgs)
import ArgParse.Basic as ArgParse
import Command (Command(..))
import Data.Either (Either(..), hush)
import Data.String (joinWith)
import Data.Version as Version
import Types (GitHubOwner(..), Package(..))

parseCliArgs :: Array String -> Either ArgError Command
parseCliArgs =
  parseArgs
    "peu"
    ( joinWith "\n"
        [ "PureScript Ecosystem Update - A CLI for updating the ecosystem."
        , ""
        ]
    )
    parser
  where
  parser :: ArgParse.ArgParser Command
  parser =
    ArgParse.choose "COMMAND"
      [ initCmd
      , cloneAllCmd
      , updateAllCmd
      , downloadPursCmd
      , cloneCmd
      , bowerCmd
      , spagoCmd
      , compileCmd
      , packageJsonCmd
      , eslintCmd
      , ciCmd
      , checkCmd
      , makePrCmd
      , showExamplesCmd
      ]
    <* ArgParse.flagHelp

  initCmd :: ArgParse.ArgParser Command
  initCmd = ArgParse.command [ "init" ] description do
    Init <$ ArgParse.flagHelp
    where
    description = "Download needed tools and set up project structure"

  cloneAllCmd = ArgParse.command [ "cloneAll" ] description do
    CloneAll
      <$> fromRecord
        { makeFork: parseMakeForkOption }
      <* ArgParse.flagHelp
    where
    description = "git clone all packages locally"

  updateAllCmd = ArgParse.command [ "updateAll" ] description do
    UpdateAll <$ ArgParse.flagHelp
    where
    description = "Run all available scripts across all repos."

  downloadPursCmd = ArgParse.command ["downloadPurs"] description do
    DownloadPurs
      <$> ArgParse.any "VERSION" "The PureScript version" (hush <<< Version.parseVersion)
    where
    description = "Download the specified version from GitHub and use it in future scripts"

  cloneCmd = ArgParse.command ["clone"] description do
    Clone
      <$> fromRecord
        { package: parsePackage
        , makeFork: parseMakeForkOption
        }
      <* ArgParse.flagHelp
    where
    description = "git clone single package"

  bowerCmd = ArgParse.command ["bower"] description do
    Bower
      <$> fromRecord
        { package: parsePackage
        }
      <* ArgParse.flagHelp
    where
    description = "Run Bower-related operations on a single package"

  spagoCmd = ArgParse.command ["spago"] description do
    Spago
      <$> fromRecord
        { package: parsePackage
        }
      <* ArgParse.flagHelp
    where
    description = "Run Spago-related operations on a single package"

  compileCmd = ArgParse.command ["compile"] description do
    Compile
      <$> fromRecord
        { package: parsePackage
        , clearBowerCache: parseClearBowerCacheOption
        }
      <* ArgParse.flagHelp
    where
    description = "Compile a single package"

  packageJsonCmd = ArgParse.command ["packageJson"] description do
    PackageJson
      <$> fromRecord
        { package: parsePackage
        }
      <* ArgParse.flagHelp
    where
    description = "Run `package.json`-related operations on a single package"

  eslintCmd = ArgParse.command ["eslint"] description do
    Eslint
      <$> fromRecord
        { package: parsePackage
        }
      <* ArgParse.flagHelp
    where
    description = "Run `.eslintrc.json`-related operations on a single package"

  ciCmd = ArgParse.command ["ci"] description do
    CI
      <$> fromRecord
        { package: parsePackage
        }
      <* ArgParse.flagHelp
    where
    description = "Run `.github/workflows/ci.yml`-related operations on a single package"

  checkCmd = ArgParse.command ["check"] description do
    Check
      <$> fromRecord
        { package: parsePackage
        }
      <* ArgParse.flagHelp
    where
    description = "Search for deprecations and other old code and fail if any are found"

  makePrCmd = ArgParse.command ["pr"] description do
    MakePr
      <$> fromRecord
        { package: parsePackage
        }
      <* ArgParse.flagHelp
    where
    description = "Create a PR for a single package"

  showExamplesCmd = ArgParse.command ["cli-examples"] description do
    ShowExamples <$ ArgParse.flagHelp
    where
    description = "Show examples of how to use this CLI correctly"

  parsePackage = ArgParse.anyNotFlag "PACKAGE" "The package to operate on (e.g. `prelude`)"
    # ArgParse.unformat "PACKAGE" case _ of
      "" -> Left "PACKAGE must not be empty"
      x -> Right $ Package x

  parseClearBowerCacheOption = ArgParse.flag [ "--clear-cache" ] description
    # ArgParse.boolean
    where
    description = "If set, clears the repo's local bower cache"

  parseMakeForkOption = ArgParse.optional
    $ ArgParse.argument [ "--make-fork" ] description
    # ArgParse.unformat "GITHUB_ORG" (Right <<< GitHubOwner)
    where
    description = "TODO"

  -- labelPrefix =
  --   choose "Label prefix"
  --     [ Nothing <$ flag [ "--label-prefix-none", "-n" ] "Use '_foo' for the lens for a record '{ foo :: a }'"
  --     , argument [ "--label-prefix", "-l" ] "Use `_PREFIXFoo` for the lens for a record '{ foo :: a }'"
  --         # unformat "PREFIX" validatePrefix
  --     ]
  --     # default (NES.fromString "prop")
  --   where
  --   validatePrefix s = do
  --     case NES.fromString s of
  --       Nothing -> do
  --         throwError $ "Invalid label prefix. Prefix must not be empty"
  --       x@(Just nes) -> do
  --         unless (liftS (test alphaNumUnderscoreRegex) nes) do
  --           throwError $ "Invalid label prefix. '" <> s <> "' must pass the '^[a-zA-Z0-9_]+$' regex."
  --         pure x

  --     where
  --     alphaNumUnderscoreRegex = unsafeRegex "^[a-zA-Z0-9_]+$" noFlags

  -- genTypeAliasLens =
  --   flag
  --     [ "--gen-type-alias-isos", "-t" ]
  --     "Generate isos for type aliases"
  --     # boolean

  -- genGlobalPropFile =
  --   optional
  --     ( argument [ "--global-record-lens-module", "-m" ] description
  --         # unformat "MODULE_PATH" validateModulePath
  --     )
  --   where
  --   description = joinWith ""
  --     [ "The full module path to use for the single record label lenses file (e.g `Foo.Bar.Lens`). "
  --     , "The module will be outtputed to a file based on the module path (e.g. `Foo.Bar.Lens` "
  --     , "will be saved to `<outputDir>/Foo/Bar/Lens.purs`)."
  --     ]
  --   validateModulePath s = do
  --     when (s == "") do
  --       throwError "Invalid module path. Module path must not be an empty string"
  --     let
  --       segments = String.split (Pattern ".") s
  --       alphaNumUnderscoreCheck = segments # findWithIndex \_ next ->
  --         not $ test alphaNumUnderscoreRegex next
  --       firstCharCheck = segments # findWithIndex \_ -> not $ firstCharIsUppercase

  --     for_ alphaNumUnderscoreCheck \r ->
  --       throwError $ "Invalid module path. Segment at index " <> show r.index <> ", '" <> r.value <> "', does not pass `[a-zA-Z0-9_]+` regex check"

  --     for_ firstCharCheck \r ->
  --       throwError $ "Invalid module path. First character for segment at index " <> show r.index <> ", '" <> r.value <> "', is not uppercased"

  --     case Array.unsnoc segments of
  --       Nothing ->
  --         throwError "Invalid module path. Module path does not contain any segments."
  --       Just { init, last } ->
  --         pure { modulePath: s, filePath: Path.concat $ Array.snoc init $ last <> ".purs" }

  --   firstCharIsUppercase s = do
  --     let firstChar = String.take 1 s
  --     firstChar == "_" || firstChar == String.toUpper firstChar

  --   alphaNumUnderscoreRegex = unsafeRegex "^[a-zA-Z0-9_]+$" noFlags

  -- recordLabelStyle =
  --   choose "Record label style"
  --     [ ArgRecordLabels <$ flag [ "--label-style-arg", "-a" ]
  --         "Data constructors with 3+ args will use record labels of 'argN' (e.g. 'arg1', 'arg2', ..., 'argN')"
  --     , AlphabetRecordLabels <$ flag [ "--label-style-abc", "-b" ]
  --         "Data constructors with 3+ args will use record labels based on the alphabet (e.g. 'a', 'b', ..., 'z', 'aa', 'ab', ...)"
  --     ]
  --     # default ArgRecordLabels

  -- outputDir =
  --   argument [ "--output-dir", "-o" ] "The directory into which to write the generated files (defaults to `src`)."
  --     # default "src"

  -- pursGlobs =
  --   anyNotFlag globExample description
  --     # unformat globExample validate
  --     # unfolded1
  --   where
  --   description = joinWith ""
  --     [ "Globs for PureScript sources (e.g. `src` `test/**/*.purs`) "
  --     , "and the number of root directories to strip from each file path (defaults to 1) "
  --     , "that are separated by the OS-specific path delimiter (POSIX: ':', Windows: ';'), "
  --     ]
  --   delimit l r = l <> Path.delimiter <> r
  --   globExample = delimit "GLOB[" "DIR_STRIP_COUNT]"
  --   validate s = do
  --     case String.split (String.Pattern Path.delimiter) s of
  --       [ glob, dirStripCount ]
  --         | Just dirCount <- Int.fromString dirStripCount -> pure { glob, dirCount }
  --         | otherwise -> throwError $ fold
  --             [ "Invalid source glob. Expected directory strip count to be an integer "
  --             , "but was '"
  --             , s
  --             , "'"
  --             ]

  --       [ glob ] -> pure { glob, dirCount: 1 }
  --       _ -> throwError $ joinWith ""
  --         [ "Invalid source glob. Expected either a glob (e.g. `src`) "
  --         , "or a glob and the prefix to strip separated by a '"
  --         , Path.delimiter
  --         , "' character "
  --         , "(e.g. `"
  --         , delimit ".spago/*/*/src/**/*.purs" "4"
  --         , "`)"
  --         ]