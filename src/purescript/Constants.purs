module Constants where

import Node.Path as Path

ciYmlFile :: String
ciYmlFile = Path.concat [ ".github", "workflows", "ci.yml" ]

eslintFile :: String
eslintFile = ".eslintrc.json"

bowerJsonFile :: String
bowerJsonFile = "bower.json"

packagesJsonFile :: String
packagesJsonFile = "packages.json"

packagesDhallFile :: String
packagesDhallFile = "packages.dhall"

spagoDhallFile :: String
spagoDhallFile = "spago.dhall"

testDhallFile :: String
testDhallFile = "test.dhall"

pursJsonFile :: String
pursJsonFile = "purs.json"

gitIgnoreFile :: String
gitIgnoreFile = ".gitignore"

changelogFile :: String
changelogFile = "CHANGELOG.md"

purescriptTarGzFile :: String
purescriptTarGzFile = "purescript.tar.gz"

gitRemoteNameOriginal :: String
gitRemoteNameOriginal = "origin"

gitRemoteNameFork :: String
gitRemoteNameFork = "self"

libraryReleaseOrderFile :: String
libraryReleaseOrderFile = Path.concat [ filesReleaseDir, "library-release-order"]

filesReleaseDir :: String
filesReleaseDir = Path.concat [ "files", "release" ]

jqScriptsDir :: String
jqScriptsDir = Path.concat [ "src", "jq" ]

updateBowerJsonReleaseVersionsFile :: String
updateBowerJsonReleaseVersionsFile =
  Path.concat [ jqScriptsDir, "update-bower-json-release-versions.txt"]

bodyOfReleasePrFile :: String
bodyOfReleasePrFile = Path.concat [ "files", "pr", "body-of-release-pr.txt" ]

tidyRcJsonNoOperatorsFile :: String
tidyRcJsonNoOperatorsFile = Path.concat [ "files", "purs-tidy", ".tidyrc-no-operators-file.json" ]

tidyRcJsonWithOperatorsFile :: String
tidyRcJsonWithOperatorsFile = Path.concat [ "files", "purs-tidy", ".tidyrc-with-operators-file.json" ]

tidyRcJsonFile :: String
tidyRcJsonFile = ".tidyrc.json"

tidyOperatorsFile :: String
tidyOperatorsFile = ".tidyoperators"

spagoDir :: String
spagoDir = ".spago"

libDir :: String
libDir = Path.concat [ "..", "lib" ]
