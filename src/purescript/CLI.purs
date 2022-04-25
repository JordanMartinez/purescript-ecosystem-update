module CLI where

import Prelude

import ArgParse.Basic (ArgError, fromRecord, optional)
import ArgParse.Basic as Arg
import ArgParse.Basic as ArgParse
import Command (Command(..))
import Data.Array as Array
import Data.Bifunctor (lmap)
import Data.Either (Either(..), note)
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.String (Pattern(..), joinWith)
import Data.String as String
import Data.Version as Version
import Node.Path as Path
import Packages (packages)
import Types (BranchName(..), GitHubOwner(..), GitHubProject(..), Package(..))

parseCliArgs :: Array String -> Either ArgError Command
parseCliArgs =
  ArgParse.parseArgs
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
      , makeNextReleaseBatchCmd
      , releaseOrderCmd
      , genReleaseInfoCmd
      , getFileCmd
      , genEcosystemChangelogCmd
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
      <$> optional parseCloneToGhOrg
      <* ArgParse.flagHelp
    where
    description = "git clone all packages locally"

  updateAllCmd = ArgParse.command [ "updateAll" ] description do
    UpdateAll <$ ArgParse.flagHelp
    where
    description = "Run all available scripts across all repos."

  downloadPursCmd = ArgParse.command ["downloadPurs"] description do
    DownloadPurs
      <$> ArgParse.choose "version"
        [ Nothing <$ parseLatestFlag
        , Just <$> parseVersionFlag
        ]
    where
    description = "Download the specified version from GitHub and use it in future scripts"
    parseLatestFlag =
      ArgParse.flag [ "--latest" ] "Gets the latest prerelease PureScript"
        # ArgParse.boolean
    parseVersionFlag =
      ArgParse.argument [ "--version" ] "Download the specified version of PureScript"
        # ArgParse.unformat "VERSION" (lmap (append "Error when parsing version: " <<< show) <<< Version.parseVersion)

  cloneCmd = ArgParse.command ["clone"] description do
    Clone
      <$> ArgParse.choose "option"
        [ Right <$> parseRegularPackage
        , ado
          { owner, repo, package } <- parseIrregularPackage
          in Left { owner, repo, package }
        ]
      <*> optional parseCloneToGhOrg
      <* ArgParse.flagHelp
    where
    description = "git clone single package"
    parseRegularPackage = ArgParse.argument [ "--package" ] "One of the core, contrib, node, or web packages (e.g. node-fs)"
      # ArgParse.unformat "PACKAGE" case _ of
        s | Just r <- Array.findMap (\rec -> if s == unwrap rec.name then Just rec else Nothing) packages -> Right r
          | otherwise -> Left $ "'" <> s <> "' is not a core, contrib, node, or web package"

    parseIrregularPackage = ArgParse.argument [ "--repo" ] "One of the core, contrib, node, or web packages (e.g. node-fs)"
      # ArgParse.unformat "OWNER/REPO" case _ of
        s | [ owner, repo ] <- String.split (Pattern "/") s ->
              case String.stripPrefix (Pattern "purescript-") repo of
                Nothing -> Left "Repo does not start with 'purescript-', so cannot identify package name."
                Just pkg -> Right
                  { owner: GitHubOwner owner
                  , repo: GitHubProject repo
                  , package: Package pkg
                  }
          | otherwise -> Left $ "Splitting '" <> s <> "' by the first `/` did not produce `OWNER/REPO`."

  bowerCmd = ArgParse.command ["bower"] description do
    Bower
      <$> fromRecord
        { package: Arg.anyNotFlag "PACKAGE" "The name of the package to compile"
            # Arg.unformat
                "PACKAGE"
                (\s -> note "Must be a valid package name in core, contrib, node, or web libraries"
                  $ Array.findMap (\pkg@{ name } -> if unwrap name == s then Just pkg else Nothing) packages
                )
        }
      <* ArgParse.flagHelp
    where
    description = "Updates a single package's `bower.json` dependencies to their default branches."

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
        { package: Arg.anyNotFlag "PACKAGE" "The name of the package to compile"
            # Arg.unformat
                "PACKAGE"
                (\s -> note "Must be a valid package name in core, contrib, node, or web libraries"
                  $ Array.findMap (\pkg@{ name } -> if unwrap name == s then Just pkg else Nothing) packages
                )
        , skipPulp: Arg.flag [ "--skip-pulp" ] "Does not install, build, or run tests with bower/pulp" # Arg.boolean
        , clearBowerCache: Arg.flag [ "--clear-bower" ] "Clears bower's cache (if any)." # Arg.boolean
        , skipBowerInstall: Arg.flag [ "--skip-bower-install" ] "Does not install bower dependencies" # Arg.boolean
        , skipSpago: Arg.flag [ "--skip-spago" ] "Does not install, build, or run tests via spago" # Arg.boolean
        , skipSpagoInstall: Arg.flag [ "--skip-spago-install" ] "Does not install spago dependencies" # Arg.boolean
        , skipTests: Arg.flag [ "--skip-tests" ] "Does not run tests with either spago or pulp" # Arg.boolean
        , skipEslint: Arg.flag [ "--skip-eslint" ] "Skips `eslint` from running on `src`, `test`, `bench`, and `examples` dirs" # Arg.boolean
        , skipFormat: Arg.flag [ "--skip-format" ] "Skips `purs-tidy check src/ test/'" # Arg.boolean
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

  makeNextReleaseBatchCmd = ArgParse.command [ "release" ] description do
    MakeNextReleaseBatch <$> fromRecord
        { submitPr: parseSubmitPr
        , branchName: parseBranchName
        , deleteBranchIfExist: parseReplace
        , keepPrBody: parseKeepPrBody
        }
      <* ArgParse.flagHelp
    where
    description = "Make the next batch of release PRs."
    parseSubmitPr = ArgParse.flag [ "--submit-pr" ] flagDesc
      # ArgParse.boolean
      where
      flagDesc = "By default, no prepared PRs are submitted on GitHub unless this flag is set."
    parseBranchName = ArgParse.optional $ map BranchName $ ArgParse.argument [ "--branch-name" ] flagDesc
      where
      flagDesc = "The name of the branch in which to do the release changes."
    parseReplace = ArgParse.flag [ "--replace" ] flagDesc
      # ArgParse.boolean
      where
      flagDesc = "If the branch name already exists locally, this will delete it and reapply all the script's actions. Useful for testing the script."
    parseKeepPrBody = ArgParse.flag [ "--keep-pr-body" ] flagDesc
      # ArgParse.boolean
      where
      flagDesc = "If set, does not delete the `pr-body.txt` file used as the content for the PR's body."

  releaseOrderCmd = ArgParse.command [ "releaseOrder" ] description do
    ReleaseOrder <$ ArgParse.flagHelp
    where
    description = "Linearize the package dependency graph to see what to release next."

  genReleaseInfoCmd = ArgParse.command [ "releaseInfo" ] description do
    GenReleaseInfo <$ ArgParse.flagHelp
    where
    description = "Generates the information needed to produce the release order and make library releases."

  getFileCmd = ArgParse.command [ "getFile" ] description do
    GetFile
      <$> parseSingleFile
      <* ArgParse.flagHelp
    where
    description = "Generates the information needed to produce the release order and make library releases."
    parseSingleFile = (ArgParse.any "FILE" "The file to collect across all repos" Just)
      <#> (String.split (Pattern Path.sep) >>> Array.filter ((/=) ""))

  genEcosystemChangelogCmd = ArgParse.command [ "ecosystemChangelog" ] description do
    EcosystemChangelog <$ ArgParse.flagHelp
    where
    description = "Generates an ecosystem-wide changelog with repeated entries and empty sections removed."

  showExamplesCmd = ArgParse.command ["cli-examples"] description do
    ShowExamples <$ ArgParse.flagHelp
    where
    description = "Show examples of how to use this CLI correctly"

  parsePackage = ArgParse.anyNotFlag "PACKAGE" "The package to operate on (e.g. `prelude`)"
    # ArgParse.unformat "PACKAGE" case _ of
      "" -> Left "PACKAGE must not be empty"
      x -> Right $ Package x

  parseCloneToGhOrg = ArgParse.argument [ "--gh-org" ] "When specified, creates a fork of the repo under the given GitHub organization"
    # ArgParse.unformat "GITHUB_ORG" case _ of
      "" -> Left $ "GitHub organization name was empty"
      s -> Right $ GitHubOwner s

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
