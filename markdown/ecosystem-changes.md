# Ecosystem Changes

## Tooling

- `purescript-psa` does not need to be updated
- `spago` does not need to be updated
- Use the `prepare-0.15` `package-sets` branch for `v0.15.0`-compatible libraries

## Summary of `v0.14.0` changes

## Breaking Changes Made in Core Libraries

### Changes affecting multiple libraries

- Removed all kind-specific Proxy types (e.g. `SProxy`, `RLProxy`, etc.)
- Removed `MonadZero` type class and all of its deprecated instances

### `purescript-foreign-object`'s `Semigroup` instance was changed

This section has yet to be written. Including here because it relates to the Map discussion below.

### `purescript-ordered-collections`: update on `Map`'s `Semigroup` instance

This section has yet to be written. Below is what was written in the v0.14.x guide.

- Changes we will be making in future releases:
    - v0.14.0
        - `Data.Map.Unbiased` - added
        - `Data.Map`'s `Semigroup` instance unchanged but a deprecation notice is added, warning of future change
    - v0.15.0
      - `Data.Map.Unbiased` - deprecated
      - `Data.Map`'s `Semigroup` instance is changed to `Data.Map.Unbiased` implementation. A deprecation notice is still shown, warning of the change.
    - v0.16.0
      - `Data.Map.Unbiased` - removed
      - `Data.Map` - warning on `Semigroup` instance is removed

See [Unbiasing the Semigroup instance for Map](https://discourse.purescript.org/t/unbiasing-the-semigroup-instance-for-map/1935) and [purescript/purescript-ordered-collections#38](https://github.com/purescript/purescript-ordered-collections/pull/38) for more context.

## Breaking Changes in the `purescript-contrib` libraries

This section has yet to be written

## Breaking Changes in the `purescript-node` libraries

This section has yet to be written

## Breaking Changes in the `purescript-web` libraries

This section has yet to be written
