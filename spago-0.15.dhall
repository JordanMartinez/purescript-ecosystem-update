{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies = [ "console", "effect", "psci-support" ]
, packages = ./packages-0.15.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}