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

## `purescript-globals` has been deprecated; some things were moved while others were not

**Summary:**
- Remove `globals`/`purescript-globals` from your repos' dependencies
- Update any usage of these modules to their new names
    - `Global` -> `Data.Number`
    - `Global.Unsafe` -> `Data.Number.Unsafe`
- If you used any of the `Number`-related code above, add a dependency on `purescript-numbers`
- If you used any of the URI code above, add a dependency on `purescript-uri-components`.
- If you used `unsafeStringify`, either use `purescript-debug` or work with others to publish the code as a new library

`purescript-globals` had code for 3 things:
- [majority of the repo] - `Number`-related code (e.g. `nan`, `isFinite`, `readFloat`, `toFixed`, etc.)
- [four functions] - `URI`-related code (e.g. `encodeURI`/`decodeURI`, `encodeURIComponent`/`decodeURIComponent`)
- [one function] - `unsafeStringify`, which converts anything into a `String`

It seems that all of this code was originally stored in this repo because of the influence of the JavaScript backend. Since all/most of this code could be accessed via the global object, why not store it in a repo that is similarly named?

Upon further reflection, we agreed that this was not a wise decision and moved all the `Number`-related code into `purescript-numbers`, which was brought into the core repos. Since this repo consists mostly of the `Number`-related code, why is it stored in a repo called `purescript-globals`? Moreover, `sharkdp` wrote the `purescript-numbers` repo, which wrapped `purescript-globals` and provided additional functionality for the `Number` type. After discussing this with `sharkdp`, `sharkdp` agreed to move `purescript-numbers` to the core repos. We then ported all the `Number`-related code from `purescript-globals` to `purescript-numbers`.

Thus, the following module names have been changed:
- `Global` -> `Data.Number`
- `Global.Unsafe` -> `Data.Number.Unsafe`

We decided not to move `unsafeStringify` into another repo. We believed that this function would be used in debugging. Since `purescript-debug` already allows one to print any value to the console, this seemed unneecessary.

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
