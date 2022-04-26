-- | Constants for a given package's files/directories
-- | will always appear in `repoFiles`. Everything else
-- | refers to either files/directories in this repo
-- | or its given domain (e.g. `gitRemotes`).
module Constants where

import Prelude

import Node.Path as Path

repoFiles
  :: { benchDir :: String
     , bowerComponentsDir :: String
     , bowerJsonFile :: String
     , changelogFile :: String
     , ciYmlFile :: String
     , eslintFile :: String
     , examplesDir :: String
     , gitIgnoreFile :: String
     , packageJsonFile :: String
     , packagesDhallFile :: String
     , pursJsonFile :: String
     , spagoDhallFile :: String
     , spagoDir :: String
     , srcDir :: String
     , testDhallFile :: String
     , testDir :: String
     , tidyOperatorsFile :: String
     , tidyRcJsonFile :: String
     }
repoFiles =
  { ciYmlFile: Path.concat [ ".github", "workflows", "ci.yml" ]
  , eslintFile: ".eslintrc.json"
  , bowerJsonFile: "bower.json"
  , packageJsonFile: "package.json"
  , packagesDhallFile: "packages.dhall"
  , spagoDhallFile: "spago.dhall"
  , testDhallFile: "test.dhall"
  , pursJsonFile: "purs.json"
  , gitIgnoreFile: ".gitignore"
  , changelogFile: "CHANGELOG.md"
  , tidyRcJsonFile: ".tidyrc.json"
  , tidyOperatorsFile: ".tidyoperators"
  , spagoDir: ".spago"
  , bowerComponentsDir: "bower_components"
  , srcDir: "src"
  , testDir: "test"
  , examplesDir: "examples"
  , benchDir: "bench"
  }

gitRemotes
  :: { origin :: String
     , self :: String
     , upstream :: String
     }
gitRemotes =
  { origin: "origin"
  , upstream: "upstream"
  , self: "self"
  }

getFileDir :: String
getFileDir = Path.concat [ "files", "getFile" ]

releaseFiles
  :: { dir :: String
     , nextReleaseInfo :: String
     , releaseInfoPath :: String -> String
     , releaseOrderFile :: String
     , releasedPkgsFile :: String
     , updateOrderFile :: String
     , updatedPkgsFile :: String
     , spagoOrderFile :: String
     , deprecatedPkgsFile :: String
     }
releaseFiles = do
  { dir: Path.concat [ "files", "release" ]
  , releaseOrderFile: Path.concat [ "files", "release", "library-release-order" ]
  , releasedPkgsFile: Path.concat [ "files", "release", "released-pkgs" ]
  , updateOrderFile: Path.concat [ "files", "release", "library-update-order" ]
  , updatedPkgsFile: Path.concat [ "files", "release", "updated-pkgs" ]
  , nextReleaseInfo: Path.concat [ "files", "release", "next-release-info_2022-04-26.json" ]
  , spagoOrderFile: Path.concat [ "files", "release", "spago-update-order" ]
  , deprecatedPkgsFile: Path.concat [ "files", "release", "deprecated-pkgs" ]
  , releaseInfoPath: \s -> Path.concat [ "files", "release", "next-release-info_" <> s <> ".json" ]
  }

pursTidyFiles
  :: { dir :: String
     , tidyRcNoOperatorsFile :: String
     , tidyRcWithOperatorsFile :: String
     }
pursTidyFiles =
  { dir: Path.concat ["files", "purs-tidy" ]
  , tidyRcNoOperatorsFile: Path.concat [ "files", "purs-tidy", ".tidyrc-no-operators-file.json" ]
  , tidyRcWithOperatorsFile: Path.concat [ "files", "purs-tidy", ".tidyrc-with-operators-file.json" ]
  }

changelogFiles
  :: { dir :: String
     , nextReleaseNotes :: String
     , nextReleaseMissing :: String
     , nextReleaseUninteresting :: String
     }
changelogFiles =
  { dir: Path.concat[ "files", "changelogs" ]
  , nextReleaseNotes: Path.concat [ "files", "changelogs", "next-release-notes.md" ]
  , nextReleaseMissing: Path.concat [ "files", "changelogs", "next-release-missing.md" ]
  , nextReleaseUninteresting: Path.concat [ "files", "changelogs", "next-release-uninteresting.md" ]
  }

purescriptTarGzFile :: String
purescriptTarGzFile = "purescript.tar.gz"

jqScripts
  :: { dir :: String
     , updateBowerDepsToReleaseVersion :: String
     , updateBowerDepsToBranchNameVersion :: String
     }
jqScripts =
  { dir: Path.concat [ "files", "jq" ]
  , updateBowerDepsToReleaseVersion: Path.concat [ "files", "jq", "update-bower-json-release-versions.txt" ]
  , updateBowerDepsToBranchNameVersion: Path.concat [ "files", "jq", "update-bower-json-branch-name-versions.txt" ]
  }

spagoFiles
  :: { dir :: String
     , lastStablePackageSet :: String
     , preparePackageSetFile :: String
     }
spagoFiles =
  { dir: Path.concat [ "files", "spago" ]
  , preparePackageSetFile: Path.concat [ "files", "spago", "packages-prepare-set.dhall" ]
  , lastStablePackageSet: Path.concat [ "files", "spago", "packages-last-stable-set.dhall" ]
  }

libDir :: String
libDir = Path.concat [ "..", "lib" ]
