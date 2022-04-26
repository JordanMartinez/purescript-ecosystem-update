{ name = "ecosystem-update"
, dependencies =
  [ "aff"
  , "argonaut-codecs"
  , "argonaut-core"
  , "argparse-basic"
  , "arrays"
  , "bifunctors"
  , "console"
  , "debug"
  , "effect"
  , "either"
  , "enums"
  , "exceptions"
  , "filterable"
  , "foldable-traversable"
  , "foreign"
  , "foreign-object"
  , "formatters"
  , "functions"
  , "lists"
  , "maybe"
  , "newtype"
  , "node-buffer"
  , "node-child-process"
  , "node-fs"
  , "node-fs-aff"
  , "node-path"
  , "node-process"
  , "node-streams"
  , "now"
  , "nullable"
  , "partial"
  , "posix-types"
  , "prelude"
  , "record"
  , "refs"
  , "safe-coerce"
  , "strings"
  , "stringutils"
  , "tailrec"
  , "transformers"
  , "tuples"
  , "typelevel-prelude"
  , "unordered-collections"
  , "versions"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
