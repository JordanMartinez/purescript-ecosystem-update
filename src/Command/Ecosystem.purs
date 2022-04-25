module Command.Ecosystem where

import Prelude

import Constants (changelogFiles, libDir, repoFiles)
import Data.Array (groupBy)
import Data.Array as Array
import Data.Array.NonEmpty as NEA
import Data.Either (Either(..))
import Data.Filterable (partitionMap)
import Data.Maybe (Maybe(..), isJust)
import Data.Newtype (unwrap)
import Data.String (Pattern(..), Replacement(..))
import Data.String as String
import Data.String.Regex (regex, test)
import Data.String.Regex.Flags (global, multiline)
import Data.Traversable (traverse)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Class.Console (log)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (readTextFile, writeTextFile)
import Node.FS.Sync (exists)
import Node.Path (FilePath)
import Node.Path as Path
import Packages (packages)
import Safe.Coerce (coerce)
import Types (GitHubOwner, Package(..), PackageInfo)
import Utils (execAff', justOrCrash, replaceAll, rightOrCrash, splitLines, throwIfExecErrored)

generateEcosystemChangelog :: Aff Unit
generateEcosystemChangelog = do
  fileInfo <- traverse getChangelogLines packages
  let
    { left: pkgsWithNoFile, right: pkgsWithFile } = partitionMap identity fileInfo
    { left: noInterestingChanges, right: interestingChanges } = partitionMap identity pkgsWithFile
    groups = groupBy (\l r -> l.owner == r.owner) interestingChanges
    groupLines = groups <#> \pkgArr ->
      [ "## `" <> unwrap (NEA.head pkgArr).owner <> "` libraries"
      , ""
      ]
        <>
          ( join $ NEA.toArray $ pkgArr <#> \p ->
              [ "### `" <> p.pkg <> "`"
              , ""
              ]
                <> p.lines
                <>
                  [ ""
                  ]
          )
    releaseNotes = Array.intercalate "\n" $ preface <> join groupLines

    asSortedPkgFileContent =
      Array.sort
        >>> (coerce :: _ Package -> _ String)
        >>> Array.intercalate "\n"

  writeTextFile UTF8 changelogFiles.nextReleaseNotes releaseNotes
  unless (Array.null pkgsWithNoFile) do
    writeTextFile UTF8 changelogFiles.nextReleaseMissing $ asSortedPkgFileContent pkgsWithNoFile
  unless (Array.null noInterestingChanges) do
    writeTextFile UTF8 changelogFiles.nextReleaseUninteresting $ asSortedPkgFileContent noInterestingChanges
  where
  preface :: Array String
  preface =
    [ "## Global changes"
    , ""
    , "The following changes are not listed below because they appear multiple times:"
    , "- Migrate FFI to ES modules"
    , "- Update project and dependencies to v0.15.0 PureScript"
    , "- Added purs-tidy formatter"
    , "- Dropped deprecated MonadZero instances"
    , "- Dropped deprecated math dependency; updated imports"
    , "- Miscellaneous CI fixes that aren't relevant to end-users"
    , ""
    , "If a library's changes consisted only of the above entries, it was removed from this list."
    , ""
    ]

  linesToDelete =
    [ withRegex "^- Update project and deps to PureScript v0.15.0"
    , withRegex "^- Update project and dependencies to v0.15.0 PureScript"
    , withRegex "^- Migrate FFI to ES Modules"
    , withRegex "^- Migrate FFI to ES modules"
    , withRegex "^- Migrated FFI to ES Modules"
    , withRegex "^- Migrated FFI to ES modules"
    , withRegex "^- Drop deprecated `MonadZero` instance"
    , withRegex "^- Drop `math` dependency; update imports"
    , withRegex "^- Removed dependency on `purescript-math`"
    , withRegex "^- Drop dependency on `math`"
    , withRegex "^- Drop deprecated `math` dependency; update imports"
    , withRegex "^- Added `purs-tidy` formatter"
    ]

  deleteEmptySections =
    [ withRegex "Breaking changes:[^\n]*\n\n"
    , withRegex "New features:[^\n]*\n\n"
    , withRegex "Bugfixes:[^\n]*\n\n"
    , withRegex "Other improvements:[^\n]*\n\n"
    -- Also delete sections in reverse order if they're the last one
    , withRegex "Other improvements:[^\n]*\n$"
    , withRegex "Bugfixes:[^\n]*\n$"
    , withRegex "New features:[^\n]*\n$"
    , withRegex "Breaking changes:[^\n]*\n$"
    ]

  withRegex r = rightOrCrash ("Invalid regex: " <> r) $ regex r $ multiline <> global

  getChangelogLines
    :: PackageInfo
    -> Aff (Either Package (Either Package { pkg :: String, owner :: GitHubOwner, lines :: Array String }))
  getChangelogLines info = do
    log $ "Getting CHANGELOG.md file for '" <> pkg' <> "'"
    throwIfExecErrored =<< execAff' "git fetch upstream" inRepoDir
    throwIfExecErrored =<< execAff' "git reset --hard HEAD" inRepoDir
    throwIfExecErrored =<< execAff' ("git checkout upstream/" <> defaultBranch') inRepoDir
    fileExists <- liftEffect $ exists filePathFromPeu
    if fileExists then do
      originalLines <- splitLines <$> readTextFile UTF8 filePathFromPeu
      let
        getNextSection lines = do
          let
            isHeaderLine = isJust <<< String.stripPrefix (Pattern "## ")
          firstHdrIdx <- Array.findIndex isHeaderLine lines
          let
            { after: sectionAndOthers } = Array.splitAt (firstHdrIdx + 1) lines
          case Array.findIndex isHeaderLine sectionAndOthers of
            Nothing ->
              pure sectionAndOthers
            Just nextHdrIdx ->
              pure $ Array.slice 0 nextHdrIdx sectionAndOthers

        finalLines = originalLines
          # getNextSection
          # justOrCrash ("Could not find next section for " <> pkg')
          # (\l -> Array.foldl (\acc rgx -> Array.filter (not <<< test rgx) acc) l linesToDelete)
          # Array.intercalate "\n"
          # (\s -> Array.foldl (\acc rgx -> replaceAll rgx "" acc) s deleteEmptySections)
          # linkPrNumsToRepo
          # loopUntilNoChange (String.trim >>> dropExtraBlankLines)
          # linesOrEmptyIfJustWhitespace

      pure $ case finalLines of
        [] -> Right $ Left info.package
        _ -> Right $ Right { pkg: pkg', owner: info.owner, lines: finalLines }
    else do
      pure $ Left info.package
    where
    filePathFromPeu = Path.concat [ repoDir, repoFiles.changelogFile ]
    pkg' = unwrap info.package
    owner' = unwrap info.owner
    repo' = unwrap info.repo
    defaultBranch' = unwrap info.defaultBranch
    repoDir = Path.concat [ libDir, pkg' ]

    inRepoDir :: forall r. { cwd :: Maybe FilePath | r } -> { cwd :: Maybe FilePath | r }
    inRepoDir r = r { cwd = Just repoDir }

    linkPrNumsToRepo =
      replaceAll
        (withRegex "#([0-9]+)")
        ("[#$1](https://github.com/" <> owner' <> "/" <> repo' <> "/pull/$1)")

    loopUntilNoChange :: (String -> String) -> String -> String
    loopUntilNoChange f s = go s (f s)
      where
      go original new = if original == new then original else go new (f new)

    dropExtraBlankLines = String.replaceAll (Pattern "\n\n\n") (Replacement "\n\n")

    linesOrEmptyIfJustWhitespace s =
      if s == "" || test (withRegex "^[ \n\t]+$") s then []
      else splitLines s
