{ name = "ecosystem-update"
, dependencies =
  [ "aff"
  , "argparse-basic"
  , "arrays"
  , "bifunctors"
  , "console"
  , "effect"
  , "either"
  , "foldable-traversable"
  , "integers"
  , "maybe"
  , "newtype"
  , "node-fs-aff"
  , "node-path"
  , "node-process"
  , "prelude"
  , "safe-coerce"
  , "strings"
  , "transformers"
  , "versions"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
