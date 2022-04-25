module Packages where

import Types (BranchName(..), GitCloneUrl(..), GitHubOwner(..), GitHubProject(..), Package(..), PackageInfo)

packages :: Array PackageInfo
packages =
  -- core libs
  [ { package: Package "arrays"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-arrays"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-arrays.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "assert"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-assert"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-assert.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "bifunctors"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-bifunctors"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-bifunctors.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "catenable-lists"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-catenable-lists"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-catenable-lists.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "console"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-console"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-console.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "const"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-const"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-const.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "contravariant"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-contravariant"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-contravariant.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "control"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-control"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-control.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "datetime"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-datetime"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-datetime.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "distributive"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-distributive"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-distributive.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "effect"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-effect"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-effect.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "either"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-either"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-either.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "enums"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-enums"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-enums.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "exceptions"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-exceptions"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-exceptions.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "exists"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-exists"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-exists.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "filterable"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-filterable"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-filterable.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "foldable-traversable"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-foldable-traversable"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-foldable-traversable.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "foreign"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-foreign"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-foreign.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "foreign-object"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-foreign-object"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-foreign-object.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "free"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-free"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-free.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "functions"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-functions"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-functions.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "functors"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-functors"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-functors.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "gen"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-gen"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-gen.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "graphs"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-graphs"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-graphs.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "identity"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-identity"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-identity.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "integers"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-integers"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-integers.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "invariant"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-invariant"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-invariant.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "lazy"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-lazy"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-lazy.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "lcg"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-lcg"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-lcg.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "lists"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-lists"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-lists.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "maybe"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-maybe"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-maybe.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "minibench"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-minibench"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-minibench.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "newtype"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-newtype"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-newtype.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "nonempty"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-nonempty"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-nonempty.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "numbers"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-numbers"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-numbers.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "ordered-collections"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-ordered-collections"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-ordered-collections.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "orders"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-orders"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-orders.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "parallel"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-parallel"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-parallel.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "partial"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-partial"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-partial.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "prelude"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-prelude"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-prelude.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "profunctor"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-profunctor"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-profunctor.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "psci-support"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-psci-support"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-psci-support.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "quickcheck"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-quickcheck"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-quickcheck.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "random"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-random"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-random.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "record"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-record"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-record.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "refs"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-refs"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-refs.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "safe-coerce"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-safe-coerce"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-safe-coerce.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "semirings"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-semirings"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-semirings.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "st"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-st"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-st.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "strings"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-strings"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-strings.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "tailrec"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-tailrec"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-tailrec.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "transformers"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-transformers"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-transformers.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "tuples"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-tuples"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-tuples.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "type-equality"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-type-equality"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-type-equality.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "typelevel-prelude"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-typelevel-prelude"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-typelevel-prelude.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "unfoldable"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-unfoldable"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-unfoldable.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "unsafe-coerce"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-unsafe-coerce"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-unsafe-coerce.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "validation"
    , owner: GitHubOwner "purescript"
    , repo: GitHubProject "purescript-validation"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-validation.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  -- contrib libs
  , { package: Package "ace"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-ace"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-ace.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "aff-bus"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-aff-bus"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-aff-bus.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "aff-coroutines"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-aff-coroutines"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-aff-coroutines.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "aff"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-aff"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-aff.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "affjax"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-affjax"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-affjax.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "affjax-web"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-affjax-web"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-affjax-web.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: false
    }
  , { package: Package "affjax-node"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-affjax-node"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-affjax-node.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: false
    }
  , { package: Package "argonaut-codecs"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-argonaut-codecs"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-argonaut-codecs.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "argonaut-core"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-argonaut-core"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-argonaut-core.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "argonaut-generic"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-argonaut-generic"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-argonaut-generic.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "argonaut"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-argonaut"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-argonaut.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "argonaut-traversals"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-argonaut-traversals"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-argonaut-traversals.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "arraybuffer"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-arraybuffer"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-arraybuffer.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "arraybuffer-types"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-arraybuffer-types"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-arraybuffer-types.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "avar"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-avar"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-avar.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "colors"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-colors"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-colors.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "concurrent-queues"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-concurrent-queues"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-concurrent-queues.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "coroutines"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-coroutines"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-coroutines.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "css"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-css"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-css.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "fixed-points"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-fixed-points"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-fixed-points.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "float32"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-float32"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-float32.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "fork"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-fork"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-fork.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "formatters"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-formatters"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-formatters.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "form-urlencoded"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-form-urlencoded"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-form-urlencoded.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "freet"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-freet"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-freet.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "http-methods"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-http-methods"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-http-methods.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "js-date"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-js-date"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-js-date.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "js-timers"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-js-timers"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-js-timers.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "js-uri"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-js-uri"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-js-uri.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: false
    }
  , { package: Package "machines"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-machines"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-machines.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "matryoshka"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-matryoshka"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-matryoshka.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "media-types"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-media-types"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-media-types.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "now"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-now"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-now.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "nullable"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-nullable"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-nullable.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "options"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-options"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-options.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "parsing"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-parsing"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-parsing.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "pathy"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-pathy"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-pathy.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "precise"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-precise"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-precise.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "profunctor-lenses"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-profunctor-lenses"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-profunctor-lenses.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "quickcheck-laws"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-quickcheck-laws"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-quickcheck-laws.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "react-dom"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-react-dom"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-react-dom.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "react"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-react"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-react.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "routing"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-routing"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-routing.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "string-parsers"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-string-parsers"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-string-parsers.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "strings-extra"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-strings-extra"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-strings-extra.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "these"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-these"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-these.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "uint"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-uint"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-uint.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "unicode"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-unicode"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-unicode.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "unsafe-reference"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-unsafe-reference"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-unsafe-reference.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { package: Package "uri"
    , owner: GitHubOwner "purescript-contrib"
    , repo: GitHubProject "purescript-uri"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-uri.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  -- web libs
  , { package: Package "canvas"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-canvas"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-canvas.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-clipboard"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-clipboard"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-clipboard.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-cssom"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-cssom"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-cssom.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-dom"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-dom"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-dom.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-dom-parser"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-dom-parser"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-dom-parser.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-dom-xpath"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-dom-xpath"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-dom-xpath.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-encoding"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-encoding"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-encoding.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: false
    }
  , { package: Package "web-events"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-events"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-events.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-fetch"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-fetch"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-fetch.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: false
    }
  , { package: Package "web-file"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-file"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-file.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-html"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-html"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-html.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-promise"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-promise"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-promise.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: false
    }
  , { package: Package "web-socket"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-socket"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-socket.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-storage"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-storage"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-storage.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-streams"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-streams"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-streams.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: false
    }
  , { package: Package "web-touchevents"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-touchevents"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-touchevents.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-uievents"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-uievents"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-uievents.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "web-xhr"
    , owner: GitHubOwner "purescript-web"
    , repo: GitHubProject "purescript-web-xhr"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-xhr.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  -- node libs
  , { package: Package "node-buffer"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-node-buffer"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-buffer.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "node-child-process"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-node-child-process"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-child-process.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "node-fs-aff"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-node-fs-aff"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-fs-aff.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "node-fs"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-node-fs"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-fs.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "node-http"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-node-http"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-http.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "node-net"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-node-net"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-net.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "node-path"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-node-path"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-path.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "node-process"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-node-process"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-process.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "node-readline"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-node-readline"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-readline.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "node-streams"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-node-streams"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-streams.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "node-url"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-node-url"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-url.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { package: Package "posix-types"
    , owner: GitHubOwner "purescript-node"
    , repo: GitHubProject "purescript-posix-types"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-posix-types.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  -- other libs
  , { package: Package "aff-promise"
    , owner: GitHubOwner "nwolverson"
    , repo: GitHubProject "purescript-aff-promise"
    , gitUrl: GitCloneUrl "git@github.com:nwolverson/purescript-aff-promise.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  ]
