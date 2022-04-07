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

pursJsonFile :: String
pursJsonFile = "purs.json"

gitIgnoreFile :: String
gitIgnoreFile = ".gitignore"

purescriptTarGzFile :: String
purescriptTarGzFile = "purescript.tar.gz"

gitRemoteNameOriginal :: String
gitRemoteNameOriginal = "origin"

gitRemoteNameFork :: String
gitRemoteNameFork = "self"
