## `purescript` Libraries

### purescript-arrays

Breaking changes:
- Drop deprecated `group'` and `empty` (#219 by @JordanMartinez)

Other improvements:
- Fixed minor documention issue with `find` (#216 by @JamieBallingall)

### purescript-console

New features:
- Added `debug` (#36)

### purescript-control

Breaking changes:
- Make `<|>` right associative (#80 by @JordanMartinez)

### purescript-foldable-traversable

Breaking changes:
- Drop deprecated `foldMap1Default` (#147 by @JordanMartinez)

Other improvements:
- Narrow down unnecessarily imprecise type of `mapWithIndexArray` (#145)

### purescript-foreign

Other improvements:
- Replace all usages of `F` and `FT` with `Except`/`ExceptT (NonEmptyList ForeignError)` (#87 by @JordanMartinez)

  Often times, the `F` and `FT` aliases did more to hinder usage of this library than help. These aliases
  haven't been deprecated, but usage of them is now discouraged. All code in the library now uses
  the full type that is aliased by `F` and `FT`.

### purescript-foreign-object

Breaking changes:
- Migrate FFI to ES modules (#27 by @JordanMartinez)

### purescript-free

Breaking changes:
- Drop deprecated `unfoldCofree`; use `buildCofree` instead (#124 by @JordanMartinez)

### purescript-graphs

New features:
- Added `Foldable` and `Traversable` instances for `Graph` (#16 by @MaybeJustJames)

### purescript-integers

Breaking changes:
- Migrate `trunc` from `math` package (#51 by @JordanMartinez)

Other improvements:
- Drop dependency on deprecated `math` package (#51 by @JordanMartinez)

### purescript-lists

Breaking changes:
- Drop deprecated `group'` and `mapWithIndex` (#206 by @JordanMartinez)
- Change `groupAllBy` to use a comparison function (#191)

### purescript-math

Breaking changes:
- `purescript-math` was deprecated

  Update dependencies to use `purescript-numbers` and/or `purescript-integers`
  and update imports to use `Data.Number` and/or `Data.Integer`.

### purescript-maybe

New features:
- Added `Semiring` instance (#59)

### purescript-newtype

New features:
- Added `modify` (#19 by @dwhitney)

### purescript-numbers

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

Other improvements:
- Removed dependency on `purescript-math`

### purescript-ordered-collections

New features:
- Exported `Data.Map.Internal` data constructors (#52 by @natefaubion)
- Add unbiased `Semigroup`/`Monoid` instances to `Map` with `Warn` (#54 by @JordanMartinez)

### purescript-prelude

Breaking changes:
- Change Generic Rep's `NoConstructors` to newtype `Void` (#282 by @JordanMartinez)
- Fix `signum zero` to return `zero` (#280 by @JordanMartinez)
- Fix `Show` instance on records with duplicate labels by adding `Nub` constraint (#269 by @JordanMartinez)

New features:
- Added the `Data.Reflectable` module for type reflection (#289 by @PureFunctor)

Other improvements:
- Changed `unit`'s FFI representation from `{}` to `undefined` (#267 by @JordanMartinez)
- Added clearer docs for Prelude module (#270 by @JordanMartinez)
- Clarify docs for `flip` (#271 by @JordanMartinez)
- Add comment that `Number` is not a fully law abiding instance of `Ord` (#277 by @JamieBallingall)
- The internal FFI function `join` in `Data.Show` has been renamed to `intercalate` to
  match the same function in `Data.Show.Generic` (#274 by @cdepillabout)

### purescript-quickcheck

Breaking changes:
- Make `frequency` use `NonEmptyArray` (#131 by @JordanMartinez)

  Now `oneOf` and `frequency` both use `NonEmptyArray` rather than `NonEmptyList`.

Bugfixes:
- `quickCheckPure` and `quickCheckPure'` stack safety (#127)

### purescript-strings

Breaking changes:
- In `slice`, drop bounds checking and `Maybe` return type (#145 by Quelklef)

Other improvements:
- Surround code with backticks in documentation (#148)

### purescript-transformers

New features:
- Add `Foldable`, `FoldableWithIndex`, and `Traversable` instances for `EnvT` (#113 by @abaco)

### purescript-typelevel-prelude

New features:
- Added `#` infix operator for `FLIP` (e.g. `Int # Maybe` == `Maybe Int`) (#73 by @JordanMartinez)

### purescript-unfoldable

New features:
- Add `iterateN` function (#20 by @matthewleon and @JordanMartinez)

### purescript-validation

Breaking changes:
- Drop deprecated `unV`; use `validation` instead (#38 by @JordanMartinez)

## `purescript-contrib` Libraries

### purescript-aff

Breaking changes:
- Restrict the signature of `launchAff_` to only work on `Aff Unit` (#203 by @i-am-the-slime)

### purescript-affjax

Breaking changes:

TODO

New features:

Bugfixes:

### purescript-argonaut-core

Other improvements:
* Fixed readme bug where `jsonParser` was imported from `Data.Argonaut.Core` instead of `Data.Argonaut.Parser` (#50 by @flip111)

### purescript-argonaut-traversals

Other improvements:
- Updated `README.md` to make the Quick start example runnable (#37 by @dk949)

### purescript-arraybuffer-types

Other improvements:
- Miscellaneous CI updates (#26 by @JordanMartinez)

### purescript-colors

Breaking changes:
- TODO: mention schema drop?

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

Other improvements:
- Added `purs-tidy` formatter (#138 by @thomashoneyman)
- Remove ending space in css output (e.g. `padding: 1 2 3 4 `) (#135 by @chexxor and @JordanMartinez)

### purescript-now

Other improvements:
- Added quick start (#22 by @maxdeviant)

### purescript-parsing

Breaking changes:
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

### purescript-profunctor-lenses

New features:
- Add `coerced` (#140 by @ozkutuk)
- Add `sans` and `both` (#97 by @xgrommx)

Bugfixes:
- Fix broken `reindex` for v0.15 due to [Purescript PR #4033](https://github.com/purescript/purescript/pull/4033)

Other improvements:
- Improve documentation for `united` (#134 by @neppord)
- Add guide on impredicativity explaining difference between `Lens` vs `ALens` (#136 by @i-am-tom and @JordanMartinez)

### purescript-quickcheck-laws

Breaking changes:
- Drop `Proxy2`/`Proxy3` usage in favor of just `Proxy` (#59 by @JordanMartinez)

New features:
- Provide `Arbitrary`-less law checks (#36 by @matthewleon, #57 by @JordanMartinez)

Other improvements:
- Fix integer overflow error in test for Ints (#58 by @JordanMartinez)

### purescript-routing

Other improvements:
- Update readme to show how to use newtypes (#57 by @brodeuralexis and @JordanMartinez)

### purescript-string-parsers

Breaking changes:
- Change precedence of `withError` operator to accommodate associativity changes in `Control.Alt` (#92 by @thomashoneyman)

### purescript-uri

Bugfixes:
- Made all parsers stack safe on long input (#63 by @garyb)
- Exceptions are no longer thrown when using e.g. `valueFromString` with lone surrogates (#68 by @ysangkok)

Other improvements:
- Update README.md rfc link (#67 @codingedgar)

## `purescript-web` Libraries

### purescript-canvas

Breaking changes:
- Support arcs that are drawn counter-clockwise (#58, #83 by @karljs and @JordanMartinez)

New features:
- Added `createImageDataWith` (#81)

### purescript-web-cssom

Breaking changes:
- Update `CSSStyleDeclaration` functions to take `style` arg last (#12 by @theqp)

  This follows the convention of "the thing being operated on" occurs
  last in function that take multiple arguments.

### purescript-web-dom

Breaking changes:
- Unwrap returned `Effect` for `doctype` (#52 by @JordanMartinez)
- Port `getBoundingClientRect` from `web-html`; set arg to `Element` (#53 by @JordanMartinez)

### purescript-web-events

New features:
- Add FFI for `CustomEvent` constructor (#25 by @JordanMartinez)
- Add `addEventListenerWithOptions` to expose more options (#25 by @JordanMartinez)

### purescript-web-html

Breaking changes:
- Move `getBoundingClientRect` to `purescript-web-dom` (#73 by @JordanMartinez)

  Update your imports

  ```diff
  - import Web.HTML.HTMLElement (getBoundingClientRect)
  + import Web.DOM.Element (getBoundingClientRect)
  ```

  And update the arg from an `HTMLElement` type to `Element` type

- Drop duplicated `set/getClassName` and `classList` (#74 by @JordanMartinez)

  These three entities are already defined in `purescript-web-dom`

## `purescript-node` Libraries

### purescript-node-fs-aff

Breaking changes:
- Update `mkdir'` to take options arg (#34 by @JordanMartinez)

  To get back the old behavior of `mkdir'`, you would call `mkdir' { recursive: false, mode: mkPerms all all all }`

### purescript-node-fs

Breaking changes:
- Update `mkdir` to take an options record arg, exposing `recursive` option (#53, #55, #58 by @JordanMartinez)

  To get back the old behavior of `mkdir'`, you would call `mkdir' { recursive: false, mode: mkPerms all all all }`

### purescript-node-streams

Other improvements:
- Fix `Gzip` example (#17, #36 by @matthewleon and @JordanMartinez)
