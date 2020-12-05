# Ecosystem Changes

## Tooling

- `purescript-psa` needs to be updated to `v0.8.0`
- `spago` does not need to be updated
- Use the `prepare-0.14` `package-sets` branch for `v0.14.0`-compatible libraries
- A new command was added to the `purs` binary: `purs graph`.

## Summary of `v0.14.0` changes

- `# Type` is now `Row Type`
- `RowList` is now `RowList Type`
- Some usages of `unsafeCoerce` should be updated to use `coerce` from [`safe-coerce`](https://github.com/purescript/purescript-safe-coerce).
- Defining kinds is now changed. `kind` is no longer needed and must be removed from imports/exports/declarations

```purescript
-- before
module Foo.Bar (kind Foo, Constructor1, Constructor2)

import Data.Module (kind KindName)

foreign import kind Foo
foreign import data Constructor1 :: Foo
foreign import data Constructor2 :: Foo

-- after
module Foo.Bar (Foo, Constructor1, Constructor2)

import Data.Module (KindName)

foreign import data Foo
foreign import data Constructor1 :: Foo
foreign import data Constructor2 :: Foo
```

- Data, types, newtypes, and classes now have explicit kind signatures:

```purescript
-- data, type, and newtype do not need a kind signature
-- if all type parameters are fixed to something concrete
-- on the right-hand side
data Foo a b c d = AllUsedHere a b c d

-- A kind signature is suggested (and sometimes needed) if
-- at least one type parameter is NOT otherwise fixed to something
-- concrete. on the right-side.
-- In such a case, the kind signature will end in 'Type'
-- and one will use 'forall' syntax for kinds
data TypeName :: forall k. k -> Type
data TypeName k = TypeConstructorName

-- type classes' kind signature ends in 'Constraint'
class TypeClass :: forall k. k -> Type -> Symbol -> Constraint
class TypeClass anyKind aType aSymbol
```

- type class instances can now be written for type aliases as long as the desugaring of those aliases provides an instance that does not overlap with other instances.
- in preparation for ES modules in future breaking changes, primes are no longer allowed in FFI
```javascript
// before
exports["functionName'"] = function (a) { return a; };
//
// after
exports.functionNameImpl = function (a) { return a; }
// or
exports._functionName = function (a) { return a; }
```

## Breaking Changes Made in Core Libraries

### `purescript-proxy` has been deprecated; its code was moved into `prelude`

**Summary**:
- Update all kind-specific Proxy types (e.g. `SProxy`, `RLProxy`, etc.) to use kind-generic `Data.Proxy` type.

Before polykinds, we needed to use a kind-specific proxy type for each kind one would define (e.g. `SProxy`, `RProxy`, `RLProxy`, etc.). Now that we have polykinds, we can use a single proxy type (i.e. `Data.Proxy (Proxy(..))`) for any kind. Since `SProxy` was defined in `prelude`, we needed to move the `purescript-proxy` library's code into `purescript-prelude`. `purescript-proxy` also defined two other types (i.e. `Proxy2` and `Proxy3`). These will be removed in a future breaking change in `prelude`.

To help reduce breaking changes, we used the `forall proxyName` workaround:
```purescript
-- Before
foo :: forall s. IsSymbol s => SProxy s -> --
foo _ = --

foo (SProxy :: SProxy "a") -- compiles

-- After
foo :: forall sproxy s. IsSymbol s => sproxy s -> --
foo _ = --

foo (SProxy :: SProxy "a") -- still compiles, but won't in future
foo (Proxy :: Proxy "a") -- compiles and correct way to use this now
```

## `purescript-globals` has been deprecated; `sharkdp/purescript-numbers` was moved into core libraries; some but not all `globals` code was ported to `purescript-numbers`

**Summary:**
- Remove `globals`/`purescript-globals` from your repos' dependencies
- Update any usage of these modules to their new names
    - `Global (isNan, nan, isFinite, infinity)` -> `Data.Number (isNan, nan, isFinite, infinity)`
    - `Global (toFixed, toPrecision, toExponential)` -> `Data.Number.Format (toStringWith, fixed, precision, exponential)`
- If use used `readInt`, use `purescript-integers`' `readStringAs (Radix base) string` instead.
- If you use any of the `Number`-related code above, add a dependency on `purescript-numbers`
- If you used any of the encode/decode URI code above, add a dependency on `purescript-js-uri` (a repo that hasn't yet been created as of this writing).
- If you used `unsafeStringify`, either use `purescript-debug` or work with others to publish the code as a new library

`purescript-globals` had code for 6 things:
1. [4 functions] - `Number`-related code (i.e. `nan`, `isNan`, `infinity`, and `isFinite`)
1. [2 function] - parsing a `String` into base-specific `Int`s (i.e. `readInt`) and possibly invalid `Number`s (i.e. `readFloat`)
1. [3 functions] - safe `Number`-formatting code (i.e. `toFixed`, `toPrecision`, `toExponential`)
1. [3 functions] - unsafe, JavaScript-specific `Number`-formatting code, (i.e. `unsafeToFixed`, `unsafeToPrecision`, `unsafeToExponential`)
1. [1 function] - `unsafeStringify`, which converts anything into a `String`
1. [8 functions] - safe and unsafe `URI`-related code (e.g. `encodeURI`/`decodeURI`, `encodeURIComponent`/`decodeURIComponent`, and unsafe variants)

It seems that all of this code was originally stored in this repo because of the influence of the JavaScript backend. Since all/most of this code could be accessed via the global object, why not store it in a repo that is similarly named?

Upon further reflection, we agreed that this was not a wise decision. Since this repo consists mostly of the `Number`-related code, why is it stored in a repo called `purescript-globals`? Moreover, `sharkdp` wrote the `purescript-numbers` repo, which wrapped `purescript-globals` and provided additional functionality for the `Number` type (e.g. safe `String`-to-`Number` parser, etc.). So, why isn't the `Number`-related code stored there?

After discussing this with `sharkdp`, `sharkdp` agreed to move `purescript-numbers` to the core repos. We then ported some of the `Number`-related code from `purescript-globals` to `purescript-numbers`, and dropped pretty much everything else.

Thus, the following module names have been changed:
- `Global` -> `Data.Number`
- `Global.Unsafe` -> (dropped)

**[4 functions] - `Number`-related code (i.e. `nan`, `isNan`, `infinity`, and `isFinite`)**

These were ported to `purescript-numbers` and are now found under the `Data.Number` module name.

**[2 function] - parsing a `String` into base-specific `Int`s (i.e. `readInt`) and possibly invalid `Number`s (i.e. `readFloat`)**

These were dropped:
- `readFloat` could return `Infinity`, which is a valid `Number`, but often not what you want. `purescript-numbers` already has the safer `fromString :: String -> Maybe Number`, so we thought `readFloat` was superfluous.
- `readInt` was a direct FFI to JavaScript's `readInt`. When porting it over to `purescript-integers`, we realized that `fromStringAs` already implements the same functionality but in a safer way than JavaScript's `readInt` function.

**[3 functions] - safe `Number`-formatting code (i.e. `toFixed`, `toPrecision`, `toExponential`)**

These were dropped because `purescript-numbers` already provides such formatting code via the `Data.Number.Format` module. Below shows the `globals` -> `numbers` migration. `intArg` is an `Int` argument:

| `purescript-globals` | `purescript-numbers` |
| - | - |
| `toFixed intArg 4.0` | `toStringWith (fixed intArg) 4.0` |
| `toPrecision intArg 4.0` | `toStringWith (precision intArg) 4.0` |
| `toExponential intArg 4.0` | `toStringWith (exponential intArg) 4.0` |

**[3 functions] - unsafe, JavaScript-specific `Number`-formatting code, (i.e. `unsafeToFixed`, `unsafeToPrecision`, `unsafeToExponential`)**

These were dropped because they were too heavily dependent on the JavaScript backend, specifically, how it handles errors. Core libraries ought to be backend-independent as much as possible.

**[1 function] - `unsafeStringify`, which converts anything into a `String`**

We decided not to move `unsafeStringify` into another repo. We believed that this function would be used in debugging. Since `purescript-debug` already allows one to print any value to the console, this seemed unneecessary.

**[8 functions] - safe and unsafe `URI`-related code (e.g. `encodeURI`/`decodeURI`, `encodeURIComponent`/`decodeURIComponent`, and unsafe variants)**

This left the `URI`-related code. We didn't think they warranted a place in `purescript-strings` since they are more specific to `URI` things rather than `String` things. We also thought it should no longer be in a core repo. So we decided on a quick-and-dirty fix: move it outside of the core repos and into its own repo in the `purescript-contrib` organization. We called it `purescript-uri-components` because `purescript-uri` was already taken. This change will reduce breaking changes in downstram libraries as the code will still be available.

However, the ecosystem as a whole still needs a better library to work with URIs. `purescript-uri` is accurate but too heavy. The URI functions from `purescript-uri-components` are light, but don't solve the problem well.

## `Foldable1` added `foldl1` and `foldr1` as members

**Summary**:
- Data types that have a `Foldable1` instance need to implement `foldl1` and `foldr1`. Consider using the default implementations: `foldl1Default` and `foldr1Default`.

`Foldable` defines three ways to fold:
- from the left via `foldl`
- from the right via `foldr`
- direction doesn't matter via `foldMap`

However, `Foldable1` only defined two ways to fold and both don't specify direction:
- `fold1`
- `foldMap1`

`Foldable` now includes the direction-specific folds that can help fold non-empty contexts more efficiently:
- `foldl1`
- `foldr1`

This counts as a breaking change because data types that implemented `Foldable1` now need to update their instances to implement these two new functions as well. If you want to implement these quickly, consider using the default implementations: `foldl1Default` and `foldr1Default`.

## `purescript-lcg`'s `lcgPerturb` changed its `Number` argument to a safer `Int` argument

**Summary**:
- Type signature was changed
    - Before: `lcgPerturb :: Number -> Seed -> Seed`
    - After: `lcgPerturb :: Int -> Seed -> Seed`
- You might need to update your `Coarbitrary` instances if you use `purescript-quickcheck` to test your code

One could pass a `Number` value that isn't a valid 32-bit integer, which might cause a runtime error to occur. The implementation of this function needs a `Number` value so that truncation doesn't occur. To support both goals, the implementation now converts the `Int` argument to a `Number` before it gets used internally.
