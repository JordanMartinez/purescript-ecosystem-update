let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.14.7-20220404/packages.dhall
        sha256:75d0f0719f32456e6bdc3efd41cfc64785655d2b751e3d080bd849033ed053f2

in  upstream
    with versions.version = "v6.1.0"
    with dodo-printer =
        { dependencies =
          [ "ansi", "foldable-traversable", "lists", "maybe", "strings" ]
        , repo = "https://github.com/natefaubion/purescript-dodo-printer.git"
        , version = "v2.2.0"
        }
    with language-cst-parser =
        { dependencies =
          [ "arrays"
          , "const"
          , "effect"
          , "either"
          , "foldable-traversable"
          , "free"
          , "functors"
          , "maybe"
          , "numbers"
          , "ordered-collections"
          , "strings"
          , "transformers"
          , "tuples"
          , "typelevel-prelude"
          ]
        , repo =
            "https://github.com/natefaubion/purescript-language-cst-parser.git"
        , version = "v0.10.1"
        }
    with argparse-basic =
        { dependencies =
            [ "arrays"
            , "console"
            , "debug"
            , "effect"
            , "either"
            , "foldable-traversable"
            , "free"
            , "lists"
            , "maybe"
            , "node-process"
            , "record"
            , "strings"
            , "transformers"
            ]
        , repo = "https://github.com/natefaubion/purescript-argparse-basic.git"
        , version = "v1.0.0"
        }
    with node-glob-basic =
        { dependencies =
            [ "aff"
            , "console"
            , "effect"
            , "either"
            , "foldable-traversable"
            , "lists"
            , "maybe"
            , "node-fs"
            , "node-fs-aff"
            , "node-path"
            , "node-process"
            , "ordered-collections"
            , "parallel"
            , "prelude"
            , "refs"
            , "strings"
            , "tuples"
            ]
        , repo = "https://github.com/natefaubion/purescript-node-glob-basic.git"
        , version = "v1.2.2"
        }