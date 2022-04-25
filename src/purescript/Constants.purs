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
  :: { nextReleaseInfo :: String
     , releaseOrderFile :: String
     , releasedPkgsFile :: String
     , releaseInfoPath :: String -> String
     }
releaseFiles = do
  { releaseOrderFile: Path.concat [ "files", "release", "library-release-order" ]
  , releasedPkgsFile: Path.concat [ "files", "release", "released-pkgs" ]
  , nextReleaseInfo: Path.concat [ "files", "release", "next-release-info_2022-04-15T13:28:12.552Z.json" ]
  , releaseInfoPath: \s -> Path.concat [ "files", "release", "next-release-info_" <> s <> ".json" ]
  }

pursTidyFiles
  :: { tidyRcNoOperatorsFile :: String
     , tidyRcWithOperatorsFile :: String
     }
pursTidyFiles =
  { tidyRcNoOperatorsFile: Path.concat [ "files", "purs-tidy", ".tidyrc-no-operators-file.json" ]
  , tidyRcWithOperatorsFile: Path.concat [ "files", "purs-tidy", ".tidyrc-with-operators-file.json" ]
  }

changelogFiles
  :: { nextReleaseNotes :: String
     , nextReleaseMissing :: String
     , nextReleaseUninteresting :: String
     }
changelogFiles =
  { nextReleaseNotes: Path.concat [ "files", "changelogs", "next-release-notes.md" ]
  , nextReleaseMissing: Path.concat [ "files", "changelogs", "next-release-missing.md" ]
  , nextReleaseUninteresting: Path.concat [ "files", "changelogs", "next-release-uninteresting.md" ]
  }

purescriptTarGzFile :: String
purescriptTarGzFile = "purescript.tar.gz"

jqScripts
  :: { updateBowerDepsToReleaseVersion :: String
     }
jqScripts =
  { updateBowerDepsToReleaseVersion: Path.concat [ "src", "jq", "update-bower-json-release-versions.txt" ]
  }

libDir :: String
libDir = Path.concat [ "..", "lib" ]
