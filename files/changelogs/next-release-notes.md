## `purescript` Libraries

### purescript-arrays

Breaking changes:
- Migrate FFI to ES modules (#218 by @kl0tl and @JordanMartinez)
- Drop deprecated `group'` and `empty` (#219 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Fixed minor documention issue with `find` (#216 by @JamieBallingall)

### purescript-assert

Breaking changes:
- Migrate FFI to ES Modules (#22 by @sigma-andex and @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-bifunctors

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#25 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-catenable-lists

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#48 by @JordanMartinez)
- Drop deprecated `MonadZero` instance (#49 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-console

Breaking changes:
- Migrated FFI to ES modules (#39 by @kl0tl and @JordanMartinez)

New features:

- Added `debug` (#36)

Bugfixes:

Other improvements:

### purescript-const

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#21 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-contravariant

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#33 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-control

Breaking changes:
- Migrate FFI to ES modules (#78 by @kl0tl and @JordanMartinez)
- Drop deprecated `MonadZero` instance (#76 by @JordanMartinez)
- Make `<|>` right associative (#80 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-datetime

Breaking changes:
- Migrate FFI to ES modules (#93 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-distributive

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#19 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-effect

Breaking changes:
- Migrate FFI to ES modules (#29 by @kl0tl and @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-either

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#66 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-enums

Breaking changes:
- Migrate FFI to ES modules (#51 by @sigma-andex and @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-exceptions

Breaking changes:
- Migrate FFI to ES modules (#41 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-exists

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#17 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-filterable

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#23 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-foldable-traversable

Breaking changes:
- Migrate FFI to ES modules (#146 by @kl0tl and @JordanMartinez)
- Drop deprecated `foldMap1Default` (#147 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Narrow down unnecessarily imprecise type of `mapWithIndexArray` (#145)

### purescript-foreign

Breaking changes:
- Migrate FFI to ES modules (#86 by @kl0tl and @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Replace all usages of `F` and `FT` with `Except`/`ExceptT (NonEmptyList ForeignError)` (#87 by @JordanMartinez)

  Often times, the `F` and `FT` aliases did more to hinder usage of this library than help. These aliases
  haven't been deprecated, but usage of them is now discouraged. All code in the library now uses
  the full type that is aliased by `F` and `FT`.

### purescript-foreign-object

Breaking changes:
- Migrate FFI to ES modules (#27 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-free

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#123 by @JordanMartinez)
- Drop deprecated `MonadZero` instance (#122 by @JordanMartinez)
- Drop deprecated `unfoldCofree`; use `buildCofree` instead (#124 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-functions

Breaking changes:
- Migrated FFI to ES modules (#19 by @kl0tl and @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-functors

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#36 by @JordanMartinez)
- Drop deprecated `MonadZero` instance (#35 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-gen

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#35 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-graphs

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#19 by @JordanMartinez)

New features:
- Added `Foldable` and `Traversable` instances for `Graph` (#16 by @MaybeJustJames)

Bugfixes:

Other improvements:

### purescript-identity

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#29 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-integers

Breaking changes:
- Migrate FFI to ES modules (#50 by @kl0tl and @JordanMartinez)
- Migrate `trunc` from `math` package (#51 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Drop dependency on deprecated `math` package (#51 by @JordanMartinez)

### purescript-invariant

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#15 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-lazy

Breaking changes:
- Migrate FFI to ES modules (#39 by @kl0tl and @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-lcg

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#15 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-lists

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#203 by @JordanMartinez)
- Drop deprecated `MonadZero` instance (#205 by @JordanMartinez)
- Drop deprecated `group'` and `mapWithIndex` (#206 by @JordanMartinez)
- Change `groupAllBy` to use a comparison function (#191)

New features:

Bugfixes:

Other improvements:

### purescript-math

Breaking changes:
- Migrate FFI to ES modules (#33 by @kl0tl and @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-maybe

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#60 by @JordanMartinez)
- Drop deprecated `MonadZero` instance (#61 by @JordanMartinez)

New features:
- Added `Semiring` instance (#59)

Bugfixes:

Other improvements:

### purescript-minibench

Breaking changes:
- Migrate FFI to ES modules (#22 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-newtype

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#30 by @JordanMartinez)

New features:
- Added `modify` (#19 by @dwhitney)

Bugfixes:

Other improvements:

### purescript-nonempty

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#51 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-numbers

Breaking changes:

New features:
- Ported various functions & constants from `purescript-math` (#18 by @JamieBallingall)

  Specifically...
  - `abs`, `sign`
  - `max`, `min` (which work differently than `Number`'s `Ord` instance)
  - `ceil`, `floor`, `trunc`, `remainder`/`%`, `round`
  - `log`
  - `exp`, `pow`, `sqrt`
  - `acos`, `asin`, `atan`, `atan2`, `cos`, `sin`, `tan`
  - Numeric constants: `e`, `ln2`, `ln10`, `log10e`, `log2e`, `pi`, `sqrt1_2`,
  `sqrt2`, and `tau`

Bugfixes:

Other improvements:
- Removed dependency on `purescript-math`

### purescript-ordered-collections

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#53 by @JordanMartinez)

New features:
- Exported `Data.Map.Internal` data constructors (#52 by @natefaubion)
- Add unbiased `Semigroup`/`Monoid` instances to `Map` with `Warn` (#54 by @JordanMartinez)

Bugfixes:

### purescript-orders

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#15 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-parallel

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#41 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-partial

Breaking changes:
- Migrate FFI to ES modules (#24 by @kl0tl and @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-prelude

Breaking changes:
- Migrated FFI to ES Modules (#287 by @kl0tl and @JordanMartinez)
- Change Generic Rep's `NoConstructors` to newtype `Void` (#282 by @JordanMartinez)
- Replaced polymorphic proxies with monomorphic `Proxy` (#281, #288 by @JordanMartinez)
- Fix `signum zero` to return `zero` (#280 by @JordanMartinez)
- Fix `Show` instance on records with duplicate labels by adding `Nub` constraint (#269 by @JordanMartinez)

New features:
- Added the `Data.Reflectable` module for type reflection (#289 by @PureFunctor)

Bugfixes:

Other improvements:
- Changed `unit`'s FFI representation from `{}` to `undefined` (#267 by @JordanMartinez)
- Added clearer docs for Prelude module (#270 by @JordanMartinez)
- Clarify docs for `flip` (#271 by @JordanMartinez)
- Add comment that `Number` is not a fully law abiding instance of `Ord` (#277 by @JamieBallingall)
- The internal FFI function `join` in `Data.Show` has been renamed to `intercalate` to
  match the same function in `Data.Show.Generic` (#274 by @cdepillabout)

### purescript-profunctor

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#44 by @JordanMartinez)
- Drop deprecated `MonadZero` instance (#43 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-psci-support

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#25 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-quickcheck

Breaking changes:
- Migrate FFI to ES modules (#130 by @kl0tl and @JordanMartinez)
- Replaced polymorphic proxies with monomorphic `Proxy` (#132 by @JordanMartinez)
- Make `frequency` use `NonEmptyArray` (#131 by @JordanMartinez)

  Now `oneOf` and `frequency` both use `NonEmptyArray` rather than `NonEmptyList`.

New features:

Bugfixes:
- `quickCheckPure` and `quickCheckPure'` stack safety (#127)

Other improvements:

### purescript-random

Breaking changes:
- Migrate FFI to ES modules (#29 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-record

Breaking changes:
- Migrate FFI to ES modules (#81 by @kl0tl and @JordanMartinez)
- Replaced polymorphic proxies with monomorphic `Proxy` (#81 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-refs

Breaking changes:
- Migrate FFI to ES modules (#39 by @kl0tl and @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-safe-coerce

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#12 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-semirings

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#21 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-st

Breaking changes:
- Migrate FFI to ES modules (#47 by @kl0tl and @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-strings

Breaking changes:
- Migrate FFI to ES modules (#158 by @kl0tl and @JordanMartinez)
- Replaced polymorphic proxies with monomorphic `Proxy` (#158 by @JordanMartinez)
- In `slice`, drop bounds checking and `Maybe` return type (#145 by Quelklef)

New features:

Bugfixes:

Other improvements:
- Surround code with backticks in documentation (#148)

### purescript-tailrec

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#38 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-transformers

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#142 by @JordanMartinez)
- Drop deprecated `MonadZero` instance (#141 by @JordanMartinez)

New features:
- Add `Foldable`, `FoldableWithIndex`, and `Traversable` instances for `EnvT` (#113 by @abaco)

Bugfixes:

Other improvements:

### purescript-tuples

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#50 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-type-equality

Breaking changes:
- Update project and dependencies to v0.15.0 PureScript (#18 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-typelevel-prelude

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#72 by @JordanMartinez)
- Replaced polymorphic proxies with monomorphic `Proxy` (#72 by @JordanMartinez)

New features:
- Added `#` infix operator for `FLIP` (e.g. `Int # Maybe` == `Maybe Int`) (#73 by @JordanMartinez)

Bugfixes:

Other improvements:

### purescript-unfoldable

Breaking changes:
- Migrate FFI to ES modules (#37 by @kl0tl and @JordanMartinez)

New features:
- Add `iterateN` function (#20 by @matthewleon and @JordanMartinez)

Bugfixes:

Other improvements:

### purescript-unsafe-coerce

Breaking changes:
- Migrate FFI to ES modules (#18 by @kl0tl and @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-validation

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#37 by @JordanMartinez)
- Drop deprecated `unV`; use `validation` instead (#38 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

## `purescript-contrib` Libraries

### purescript-ace

Breaking changes:
- Migrate FFI to ES modules (#48 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#46 by @thomashoneyman)

### purescript-aff-bus

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#31 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#30 by @thomashoneyman)

### purescript-aff-coroutines

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#32 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#26 by @thomashoneyman)

### purescript-aff

Breaking changes:
- Restrict the signature of `launchAff_` to only work on `Aff Unit` (#203 by @i-am-the-slime)
- Migrate FFI to ES modules (#209 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#207 by @thomashoneyman)
- Ensure all directly-imported packages are included in the `spago.dhall` file (#205 by @ptrfrncsmrph)

### purescript-affjax

Breaking changes:

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#167 by @thomashoneyman)

### purescript-argonaut-codecs

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#106 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#104 by @thomashoneyman)

### purescript-argonaut-core

Breaking changes:
- Migrate FFI to ES modules (#57 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#53 by @thomashoneyman)
* Fixed readme bug where `jsonParser` was imported from `Data.Argonaut.Core` instead of `Data.Argonaut.Parser` (#50 by @flip111)

### purescript-argonaut-generic

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#39 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#38 by @thomashoneyman)

### purescript-argonaut

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#58 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#6 by @thomashoneyman)

### purescript-argonaut-traversals

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#38 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Updated `README.md` to make the Quick start example runnable (#37 by @dk949)
- Added `purs-tidy` formatter (#36 by @thomashoneyman)

### purescript-arraybuffer

Breaking Changes:
- Migrate FFI to ES modules (#41 by @JordanMartinez)
- Replaced polymorphic proxies with monomorphic `Proxy` (#41 by @JordanMartinez)

### purescript-arraybuffer-types

Breaking changes:

New features:

Bugfixes:

Other improvements:
- Miscellaneous CI updates (#26 by @JordanMartinez)
- Added `purs-tidy` formatter (#25 by @thomashoneyman)

### purescript-avar

Breaking changes:
- Migrate FFI to ES modules (#29 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#27 by @thomashoneyman)

### purescript-colors

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#51 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-concurrent-queues

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#14 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#13 by @thomashoneyman)

### purescript-coroutines

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#39 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#38 by @thomashoneyman)

### purescript-css

Breaking changes:
- Add support for `calc` expressions (#140 by @nsaunders)
- Add table selector (#141 by @plurip-software)
- Update the box-shadow implementation (#88 by @vyorkin)
- Update project and deps to PureScript v0.15.0 (#156 by @JordanMartinez)
- Dropped almost all named colors (#156 by @JordanMartinez)

  These colors were originally defined in `purescript-colors` (i.e.
  one module per schema) because each schema should be defined as its
  own library. This change was propagated to this release.

New features:
- Add smart constructors for generic font families (#68, #136 by @Unisay and @JordanMartinez)
- Add support for `text-direction` (#83, #137 by @vyorkin and @JordanMartinez)
- Add outline and constituent properties (#145 by @nsaunders)
- Add support for `visibility` property (#148 by @nsaunders)

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#138 by @thomashoneyman)
- Remove ending space in css output (e.g. `padding: 1 2 3 4 `) (#135 by @chexxor and @JordanMartinez)

### purescript-fixed-points

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#22 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#21 by @thomashoneyman)

### purescript-float32

Breaking changes:
- Migrate FFI to ES modules (#8 by @JordanMartinez)

### purescript-fork

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#19 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#18 by @thomashoneyman)
- Ensure all imported packages are in the spago.dhall file (#17 by @artemisSystem)

### purescript-formatters

Breaking changes:
- Migrate FFI to ES modules (#79 by @i-am-the-slime and @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#77 by @thomashoneyman)

### purescript-form-urlencoded

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#27 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#26 by @thomashoneyman)

### purescript-freet

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#35 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#34 by @thomashoneyman)

### purescript-http-methods

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#16 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#15 by @thomashoneyman)

### purescript-js-date

Breaking changes:
- Migrate FFI to ES modules (#36 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#34 by @thomashoneyman)

### purescript-js-timers

Breaking changes:
- Migrate FFI to ES modules (#27 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#25 by @thomashoneyman)

### purescript-js-uri

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#11 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#7 by @thomashoneyman)

### purescript-machines

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#53 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#51 by @thomashoneyman)

### purescript-matryoshka

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#26 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#25 by @thomashoneyman)
- Updated dependencies to clear build errors related to unlisted dependencies (#24 by @flounders)

### purescript-media-types

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#18 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#17 by @thomashoneyman)

### purescript-now

Breaking changes:
- Migrate FFI to ES modules (#25 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#23 by @thomashoneyman)
- Added tests (#20 by @ntwilson)
- Added quick start (#22 by @maxdeviant)

### purescript-nullable

Breaking changes:
- Migrate FFI to ES modules (#44 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#42 by @thomashoneyman)

### purescript-options

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#47 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#45 by @thomashoneyman)

### purescript-parsing

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#160 by @JordanMartinez)
- Drop deprecated `MonadZero` instance (#160 by @JordanMartinez)
- New optimized internals. `ParserT` now has a more efficient representation,
  resulting in (up to) 20x performance improvement. In addition to the performance,
  all parser execution is always stack-safe, even monadically, obviating the need
  to run parsers with `Trampoline` as the base Monad or to explicitly use `MonadRec`.

  Code that was parametric over the underlying Monad no longer needs to propagate a
  Monad constraint.

  Code that constructs parsers via the underlying representation will need to be updated,
  but otherwise the interface is unchanged and parsers should just enjoy the speed boost.

  (#154 by @natefaubion)
- Make `<??>` right-associative (#164 by @JordanMartinez)
- Drop `<?>` and `<~?>` prec from 3 to 4 (#163, #164 by @JordanMartinez)

  `<|>` was made right associative. Decreasing these two operators
  prevents a compiler error (i.e. `MixedAssociativityError`)
  without causing issues with `<$>`.

New features:

Bugfixes:

Other improvements:

### purescript-pathy

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#50 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#49 by @thomashoneyman)

### purescript-precise

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#29 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#12 by @thomashoneyman)

### purescript-profunctor-lenses

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#141 by @JordanMartinez)
- Replaced polymorphic proxies with monomorphic `Proxy` (#141 by @JordanMartinez)

New features:
- Add `coerced` (#140 by @ozkutuk)
- Add `sans` and `both` (#97 by @xgrommx)

Bugfixes:
- Fix broken `reindex` for v0.15 due to [Purescript PR #4033](https://github.com/purescript/purescript/pull/4033)

Other improvements:
- Added `purs-tidy` formatter (#138 by @thomashoneyman)
  - Replace manual tests with automated tests using `assert` (#135 by @neppord)
  - Improve documentation for `united` (#134 by @neppord)
  - Add guide on impredicativity explaining difference between `Lens` vs `ALens` (#136 by @i-am-tom and @JordanMartinez)

### purescript-quickcheck-laws

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#59 by @JordanMartinez)
- Drop deprecated `MonadZero` instance (#59 by @JordanMartinez)
- Drop `Proxy2`/`Proxy3` usage in favor of just `Proxy` (#59 by @JordanMartinez)

New features:
- Provide `Arbitrary`-less law checks (#36 by @matthewleon, #57 by @JordanMartinez)

Bugfixes:

Other improvements:
- Fix integer overflow error in test for Ints (#58 by @JordanMartinez)

### purescript-react-dom

Breaking changes:
- Migrate FFI to ES modules (#28 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#26 by @thomashoneyman)

### purescript-react

Breaking changes:
- Migrate FFI to ES modules (#185 by @JordanMartinez)
- Replaced polymorphic proxies with monomorphic `Proxy` (#185 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#182 by @thomashoneyman)

### purescript-routing

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#86 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#85 by @thomashoneyman)
- Update readme to show how to use newtypes (#57 by @brodeuralexis and @JordanMartinez)

### purescript-string-parsers

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#90 by @JordanMartinez)
- Drop deprecated `MonadZero` instance (#90 by @JordanMartinez)
- Change precedence of `withError` operator to accommodate associativity changes in `Control.Alt` (#92 by @thomashoneyman)

New features:

Bugfixes:

Other improvements:

### purescript-strings-extra

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#22 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#20 by @thomashoneyman)

### purescript-these

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#41 by @JordanMartinez)
- Replaced polymorphic proxies with monomorphic `Proxy` (#41 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#40 by @thomashoneyman)

### purescript-uint

Breaking Changes:
- Migrate FFI to ES modules (#20 by @JordanMartinez)

### purescript-unicode

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#40 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#38 by @thomashoneyman)

### purescript-unsafe-reference

Breaking changes:
- Migrate FFI to ES modules (#19 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:
- Added `purs-tidy` formatter (#17 by @thomashoneyman)

### purescript-uri

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#70 by @JordanMartinez)

New features:

Bugfixes:
- Made all parsers stack safe on long input (#63 by @garyb)
- Exceptions are no longer thrown when using e.g. `valueFromString` with lone surrogates (#68 by @ysangkok)

Other improvements:
- Added `purs-tidy` formatter (#66 by @thomashoneyman)
- Update README.md rfc link (#67 @codingedgar)

## `purescript-web` Libraries

### purescript-canvas

Breaking changes:
- Migrate FFI to ES modules (#85 by @JordanMartinez)
- Support arcs that are drawn counter-clockwise (#58, #83 by @karljs and @JordanMartinez)

New features:
- Added `createImageDataWith` (#81)

Bugfixes:

Other improvements:
- Added ESLint config and fixed the resulting linter issues (#82)

### purescript-web-clipboard

Breaking changes:
- Migrate FFI to ES modules (#9 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-cssom

Breaking changes:
- Migrate FFI to ES modules (#14 by @JordanMartinez)
- Update `CSSStyleDeclaration` functions to take `style` arg last (#12 by @theqp)

  This follows the convention of "the thing being operated on" occurs
  last in function that take multiple arguments.

New features:

Bugfixes:

Other improvements:

### purescript-web-dom

Breaking changes:
- Migrate FFI to ES modules (#51 by @JordanMartinez)
- Unwrap returned `Effect` for `doctype` (#52 by @JordanMartinez)
- Port `getBoundingClientRect` from `web-html`; set arg to `Element` (#53 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-dom-parser

Breaking changes:
- Migrate FFI to ES modules (#14 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-dom-xpath

Breaking changes:
- Migrate FFI to ES modules (#15 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-encoding

Breaking changes:
- Migrate FFI to ES modules (#7 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-events

Breaking changes:
- Migrate FFI to ES modules (#24 by @JordanMartinez)

New features:
- Add FFI for `CustomEvent` constructor (#25 by @JordanMartinez)
- Add `addEventListenerWithOptions` to expose more options (#25 by @JordanMartinez)

Bugfixes:

Other improvements:

### purescript-web-fetch

Breaking changes:
- Migrate FFI to ES modules (#8 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-file

Breaking changes:
- Migrate FFI to ES modules (#19 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-html

Breaking changes:
- Move `getBoundingClientRect` to `purescript-web-dom` (#73 by @JordanMartinez)
- Drop duplicated `set/getClassName` and `classList` (#74 by @JordanMartinez)

  These three entities are already defined in `purescript-web-dom`

New features:

Bugfixes:

Other improvements:

### purescript-web-promise

Breaking changes:
- Migrate FFI to ES modules (#14 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-socket

Breaking changes:
- Migrate FFI to ES modules (#12 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-storage

Breaking changes:
- Migrate FFI to ES modules (#17 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-streams

Breaking changes:
- Migrate FFI to ES modules (#7 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-touchevents

Breaking changes:
- Migrate FFI to ES modules (#9 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-uievents

Breaking changes:
- Migrate FFI to ES modules (#17 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-web-xhr

Breaking changes:
- Migrate FFI to ES modules (#21 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

## `purescript-node` Libraries

### purescript-node-buffer

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#22 by @nwolverson, @JordanMartinez, @sigma-andex)

New features:

Bugfixes:

Other improvements:

### purescript-node-child-process

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#31 by @JordanMartinez, @thomashoneyman, @sigma-andex)

New features:

Bugfixes:

Other improvements:

### purescript-node-fs-aff

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#33 by @JordanMartinez, @thomashoneyman, @sigma-andex)
- Update `mkdir'` to take options arg (#34 by @JordanMartinez)

New features:

Bugfixes:

Other improvements:

### purescript-node-fs

Breaking changes:
- Update `mkdir` to take an options record arg, exposing `recursive` option (#53, #55, #58 by @JordanMartinez)

  To get back the old behavior of `mkdir'`, you would call `mkdir' { recursive: false, mode: mkPerms all all all }`

New features:
- Update project and deps to PureScript v0.15.0 (#59 by @JordanMartinez, @thomashoneyman, @sigma-andex)

Bugfixes:

Other improvements:

### purescript-node-http

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#41 by @JordanMartinez, @sigma-andex)

New features:

Bugfixes:

Other improvements:

### purescript-node-net

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#11 by @JordanMartinez, @thomashoneyman, @sigma-andex)

New features:

Bugfixes:

Other improvements:

### purescript-node-path

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#22 by @nwolverson, @JordanMartinez, @sigma-andex)

New features:

Bugfixes:

Other improvements:

### purescript-node-process

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#34 by @nwolverson, @JordanMartinez, @sigma-andex)

New features:

Bugfixes:

Other improvements:

### purescript-node-readline

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#28 by @JordanMartinez, @sigma-andex)

New features:

Bugfixes:

Other improvements:

### purescript-node-streams

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#39 by @nwolverson, @JordanMartinez, @sigma-andex)

New features:

Bugfixes:

Other improvements:
- Fix `Gzip` example (#17, #36 by @matthewleon and @JordanMartinez)

### purescript-node-url

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#16 by @nwolverson, @JordanMartinez, @sigma-andex)

New features:

Bugfixes:

Other improvements:

### purescript-posix-types

Breaking changes:
- Update project and deps to PureScript v0.15.0 (#12 by @JordanMartinez, @sigma-andex)

New features:

Bugfixes:

Other improvements:

