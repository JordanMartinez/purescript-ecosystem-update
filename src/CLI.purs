module CLI where

import Prelude

import ArgParse.Basic (ArgError, fromRecord, optional)
import ArgParse.Basic as Arg
import ArgParse.Basic as ArgParse
import Command (Command(..), DependencyStage(..))
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
import Types (BranchName(..), GitHubOwner(..), GitHubRepo(..), Package(..))

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
      , downloadPursCmd
      , cloneCmd
      , bowerCmd
      , spagoCmd
      , packageJsonCmd
      , ciCmd
      , compileCmd
      , checkCmd
      , makePrCmd
      , makeNextReleaseBatchCmd
      , updateOrderCmd
      , releaseOrderCmd
      , spagoOrderCmd
      , genReleaseInfoCmd
      , getFileCmd
      , genEcosystemChangelogCmd
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

  downloadPursCmd = ArgParse.command [ "downloadPurs" ] description do
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

  cloneCmd = ArgParse.command [ "clone" ] description do
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
          s
            | Just r <- Array.findMap (\rec -> if s == unwrap rec.package then Just rec else Nothing) packages -> Right r
            | otherwise -> Left $ "'" <> s <> "' is not a core, contrib, node, or web package"

    parseIrregularPackage = ArgParse.argument [ "--repo" ] "One of the core, contrib, node, or web packages (e.g. node-fs)"
      # ArgParse.unformat "OWNER/REPO" case _ of
          s
            | [ owner, repo ] <- String.split (Pattern "/") s ->
                case String.stripPrefix (Pattern "purescript-") repo of
                  Nothing -> Left "Repo does not start with 'purescript-', so cannot identify package name."
                  Just pkg -> Right
                    { owner: GitHubOwner owner
                    , repo: GitHubRepo repo
                    , package: Package pkg
                    }
            | otherwise -> Left $ "Splitting '" <> s <> "' by the first `/` did not produce `OWNER/REPO`."

  bowerCmd = ArgParse.command [ "bower" ] description do
    Bower
      <$> fromRecord
        { package: Arg.anyNotFlag "PACKAGE" "The name of the package to compile"
            # Arg.unformat
                "PACKAGE"
                ( \s -> note "Must be a valid package name in core, contrib, node, or web libraries"
                    $ Array.findMap (\pkg@{ package } -> if unwrap package == s then Just pkg else Nothing) packages
                )
        }
      <* ArgParse.flagHelp
    where
    description = "Updates a single package's `bower.json` dependencies to their default branches."

  spagoCmd = ArgParse.command [ "spago" ] description do
    Spago
      <$> fromRecord
        { package: Arg.anyNotFlag "PACKAGE" "The name of the package to compile"
            # Arg.unformat
                "PACKAGE"
                ( \s -> note "Must be a valid package name in core, contrib, node, or web libraries"
                    $ Array.findMap (\pkg@{ package } -> if unwrap package == s then Just pkg else Nothing) packages
                )
        }
      <* ArgParse.flagHelp
    where
    description = "Updates a single package's `spago.dhall` and `packages.dhall` files."

  compileCmd = ArgParse.command [ "compile" ] description do
    Compile
      <$> fromRecord
        { package: Arg.anyNotFlag "PACKAGE" "The name of the package to compile"
            # Arg.unformat
                "PACKAGE"
                ( \s -> note "Must be a valid package name in core, contrib, node, or web libraries"
                    $ Array.findMap (\pkg@{ package } -> if unwrap package == s then Just pkg else Nothing) packages
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

  packageJsonCmd = ArgParse.command [ "packageJson" ] description do
    PackageJson
      <$> fromRecord
        { package: Arg.anyNotFlag "PACKAGE" "The name of the package to compile"
            # Arg.unformat
                "PACKAGE"
                ( \s -> note "Must be a valid package name in core, contrib, node, or web libraries"
                    $ Array.findMap (\pkg@{ package } -> if unwrap package == s then Just pkg else Nothing) packages
                )
        }
      <* ArgParse.flagHelp
    where
    description = "Run `package.json`-related operations on a single package"

  ciCmd = ArgParse.command [ "ci" ] description do
    CI
      <$> fromRecord
        { package: Arg.anyNotFlag "PACKAGE" "The name of the package to compile"
            # Arg.unformat
                "PACKAGE"
                ( \s -> note "Must be a valid package name in core, contrib, node, or web libraries"
                    $ Array.findMap (\pkg@{ package } -> if unwrap package == s then Just pkg else Nothing) packages
                )
        }
      <* ArgParse.flagHelp
    where
    description = "Run `.github/workflows/ci.yml`-related operations on a single package"

  checkCmd = ArgParse.command [ "check" ] description do
    CheckForDeprecated
      <$> fromRecord
        { package: Arg.anyNotFlag "PACKAGE" "The name of the package to compile"
            # Arg.unformat
                "PACKAGE"
                ( \s -> note "Must be a valid package name in core, contrib, node, or web libraries"
                    $ Array.findMap (\pkg@{ package } -> if unwrap package == s then Just pkg else Nothing) packages
                )
        }
      <* ArgParse.flagHelp
    where
    description = "Search for deprecations and other old code. Warn or fail depending on the type found."

  makePrCmd = ArgParse.command [ "pr" ] description do
    MakePr
      <$> fromRecord
        { package: Arg.anyNotFlag "PACKAGE" "The name of the package to compile"
            # Arg.unformat
                "PACKAGE"
                ( \s -> note "Must be a valid package name in core, contrib, node, or web libraries"
                    $ Array.findMap (\pkg@{ package } -> if unwrap package == s then Just pkg else Nothing) packages
                )
        }
      <* ArgParse.flagHelp
    where
    description = "Create a PR for a single package"

  makeNextReleaseBatchCmd = ArgParse.command [ "release" ] description do
    MakeNextReleaseBatch
      <$> fromRecord
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

  updateOrderCmd = ArgParse.command [ "updateOrder" ] description do
    LibOrder UpdateOrder <$ ArgParse.flagHelp
    where
    description = "When updating libraries initially, see which libraries to update next."

  releaseOrderCmd = ArgParse.command [ "releaseOrder" ] description do
    LibOrder ReleaseOrder <$ ArgParse.flagHelp
    where
    description = "When releasing libraries after all are updated and compiler is frozen, see which libraries to release next."

  spagoOrderCmd = ArgParse.command [ "spagoOrder" ] description do
    LibOrder SpagoOrder <$ ArgParse.flagHelp
    where
    description = "When libraries are released and package set is being refilled, see which libraries are unblocked next."

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

  parseCloneToGhOrg = ArgParse.argument [ "--gh-org" ] "When specified, creates a fork of the repo under the given GitHub organization"
    # ArgParse.unformat "GITHUB_ORG" case _ of
        "" -> Left $ "GitHub organization name was empty"
        s -> Right $ GitHubOwner s
