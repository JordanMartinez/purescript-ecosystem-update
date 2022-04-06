{ name = "ecosystem-update"
, dependencies =
  [ "console", "effect", "node-fs-aff", "node-process", "prelude" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs" ]
}
