module Packages where

import Types (BranchName(..), GitCloneUrl(..), GitHubOwner(..), GitHubProject(..), Package(..), PackageInfo)

packages :: Array PackageInfo
packages =
  -- core libs
  [ { name: Package "arrays"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-arrays"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-arrays.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "assert"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-assert"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-assert.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "bifunctors"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-bifunctors"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-bifunctors.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "catenable-lists"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-catenable-lists"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-catenable-lists.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "console"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-console"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-console.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "const"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-const"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-const.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "contravariant"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-contravariant"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-contravariant.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "control"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-control"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-control.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "datetime"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-datetime"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-datetime.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "distributive"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-distributive"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-distributive.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "effect"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-effect"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-effect.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "either"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-either"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-either.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "enums"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-enums"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-enums.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "exceptions"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-exceptions"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-exceptions.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "exists"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-exists"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-exists.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "filterable"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-filterable"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-filterable.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "foldable-traversable"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-foldable-traversable"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-foldable-traversable.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "foreign"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-foreign"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-foreign.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "foreign-object"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-foreign-object"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-foreign-object.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "free"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-free"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-free.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "functions"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-functions"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-functions.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "functors"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-functors"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-functors.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "gen"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-gen"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-gen.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "graphs"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-graphs"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-graphs.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "identity"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-identity"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-identity.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "integers"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-integers"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-integers.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "invariant"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-invariant"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-invariant.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "lazy"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-lazy"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-lazy.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "lcg"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-lcg"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-lcg.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "lists"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-lists"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-lists.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "maybe"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-maybe"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-maybe.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "minibench"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-minibench"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-minibench.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "newtype"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-newtype"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-newtype.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "nonempty"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-nonempty"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-nonempty.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "numbers"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-numbers"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-numbers.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "ordered-collections"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-ordered-collections"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-ordered-collections.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "orders"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-orders"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-orders.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "parallel"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-parallel"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-parallel.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "partial"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-partial"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-partial.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "prelude"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-prelude"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-prelude.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "profunctor"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-profunctor"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-profunctor.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "psci-support"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-psci-support"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-psci-support.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "quickcheck"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-quickcheck"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-quickcheck.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "random"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-random"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-random.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "record"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-record"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-record.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "refs"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-refs"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-refs.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "safe-coerce"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-safe-coerce"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-safe-coerce.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "semirings"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-semirings"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-semirings.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "st"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-st"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-st.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "strings"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-strings"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-strings.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "tailrec"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-tailrec"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-tailrec.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "transformers"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-transformers"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-transformers.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "tuples"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-tuples"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-tuples.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "type-equality"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-type-equality"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-type-equality.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "typelevel-prelude"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-typelevel-prelude"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-typelevel-prelude.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "unfoldable"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-unfoldable"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-unfoldable.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "unsafe-coerce"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-unsafe-coerce"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-unsafe-coerce.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "validation"
    , owner: GitHubOwner "purescript"
    , project: GitHubProject "purescript-validation"
    , gitUrl: GitCloneUrl "git@github.com:purescript/purescript-validation.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  -- contrib libs
  , { name: Package "ace"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-ace"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-ace.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "aff-bus"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-aff-bus"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-aff-bus.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "aff-coroutines"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-aff-coroutines"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-aff-coroutines.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "aff"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-aff"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-aff.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "affjax"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-affjax"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-affjax.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "affjax-web"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-affjax-web"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-affjax-web.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: false
    }
  , { name: Package "affjax-node"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-affjax-node"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-affjax-node.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: false
    }
  , { name: Package "argonaut-codecs"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-argonaut-codecs"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-argonaut-codecs.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "argonaut-core"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-argonaut-core"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-argonaut-core.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "argonaut-generic"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-argonaut-generic"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-argonaut-generic.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "argonaut"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-argonaut"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-argonaut.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "argonaut-traversals"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-argonaut-traversals"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-argonaut-traversals.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "arraybuffer"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-arraybuffer"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-arraybuffer.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "arraybuffer-types"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-arraybuffer-types"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-arraybuffer-types.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "avar"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-avar"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-avar.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "colors"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-colors"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-colors.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "concurrent-queues"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-concurrent-queues"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-concurrent-queues.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "coroutines"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-coroutines"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-coroutines.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "css"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-css"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-css.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "fixed-points"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-fixed-points"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-fixed-points.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "float32"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-float32"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-float32.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "fork"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-fork"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-fork.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "formatters"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-formatters"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-formatters.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "form-urlencoded"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-form-urlencoded"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-form-urlencoded.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "freet"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-freet"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-freet.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "http-methods"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-http-methods"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-http-methods.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "js-date"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-js-date"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-js-date.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "js-timers"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-js-timers"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-js-timers.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "js-uri"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-js-uri"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-js-uri.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: false
    }
  , { name: Package "machines"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-machines"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-machines.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "matryoshka"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-matryoshka"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-matryoshka.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "media-types"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-media-types"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-media-types.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "now"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-now"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-now.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "nullable"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-nullable"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-nullable.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "options"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-options"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-options.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "parsing"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-parsing"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-parsing.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "pathy"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-pathy"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-pathy.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "precise"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-precise"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-precise.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "profunctor-lenses"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-profunctor-lenses"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-profunctor-lenses.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "quickcheck-laws"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-quickcheck-laws"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-quickcheck-laws.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "react-dom"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-react-dom"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-react-dom.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "react"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-react"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-react.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "routing"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-routing"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-routing.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "string-parsers"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-string-parsers"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-string-parsers.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "strings-extra"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-strings-extra"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-strings-extra.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "these"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-these"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-these.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "uint"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-uint"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-uint.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "unicode"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-unicode"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-unicode.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "unsafe-reference"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-unsafe-reference"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-unsafe-reference.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  , { name: Package "uri"
    , owner: GitHubOwner "purescript-contrib"
    , project: GitHubProject "purescript-uri"
    , gitUrl: GitCloneUrl "git@github.com:purescript-contrib/purescript-uri.git"
    , defaultBranch: BranchName "main"
    , inBowerRegistry: true
    }
  -- web libs
  , { name: Package "canvas"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-canvas"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-canvas.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-clipboard"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-clipboard"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-clipboard.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-cssom"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-cssom"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-cssom.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-dom"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-dom"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-dom.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-dom-parser"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-dom-parser"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-dom-parser.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-dom-xpath"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-dom-xpath"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-dom-xpath.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-encoding"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-encoding"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-encoding.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: false
    }
  , { name: Package "web-events"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-events"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-events.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-fetch"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-fetch"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-fetch.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: false
    }
  , { name: Package "web-file"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-file"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-file.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-html"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-html"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-html.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-promise"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-promise"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-promise.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: false
    }
  , { name: Package "web-socket"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-socket"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-socket.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-storage"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-storage"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-storage.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-streams"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-streams"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-streams.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: false
    }
  , { name: Package "web-touchevents"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-touchevents"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-touchevents.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-uievents"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-uievents"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-uievents.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "web-xhr"
    , owner: GitHubOwner "purescript-web"
    , project: GitHubProject "purescript-web-xhr"
    , gitUrl: GitCloneUrl "git@github.com:purescript-web/purescript-web-xhr.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  -- node libs
  , { name: Package "node-buffer"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-node-buffer"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-buffer.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "node-child-process"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-node-child-process"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-child-process.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "node-fs-aff"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-node-fs-aff"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-fs-aff.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "node-fs"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-node-fs"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-fs.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "node-http"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-node-http"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-http.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "node-net"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-node-net"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-net.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "node-path"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-node-path"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-path.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "node-process"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-node-process"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-process.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "node-readline"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-node-readline"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-readline.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "node-streams"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-node-streams"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-streams.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "node-url"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-node-url"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-node-url.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  , { name: Package "posix-types"
    , owner: GitHubOwner "purescript-node"
    , project: GitHubProject "purescript-posix-types"
    , gitUrl: GitCloneUrl "git@github.com:purescript-node/purescript-posix-types.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  -- other libs
  , { name: Package "aff-promise"
    , owner: GitHubOwner "nwolverson"
    , project: GitHubProject "purescript-aff-promise"
    , gitUrl: GitCloneUrl "git@github.com:nwolverson/purescript-aff-promise.git"
    , defaultBranch: BranchName "master"
    , inBowerRegistry: true
    }
  ]