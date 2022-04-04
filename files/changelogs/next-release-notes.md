## `purescript` Libraries

### purescript-arrays

Breaking changes:
- Drop deprecated `group'` and `empty` ([#219](https://github.com/purescript/purescript-arrays/pull/219) by @JordanMartinez)

Other improvements:
- Fixed minor documentation issue with `find` ([#216](https://github.com/purescript/purescript-arrays/pull/216) by @JamieBallingall)

### purescript-console

New features:
- Added `debug` ([#36](https://github.com/purescript/purescript-console/pull/36))

### purescript-control

Breaking changes:
- Make `<|>` right associative ([#80](https://github.com/purescript/purescript-control/pull/80) by @JordanMartinez)

### purescript-foldable-traversable

Breaking changes:
- Drop deprecated `foldMap1Default` ([#147](https://github.com/purescript/purescript-foldable-traversable/pull/147) by @JordanMartinez)

Other improvements:
- Narrow down unnecessarily imprecise type of `mapWithIndexArray` ([#145](https://github.com/purescript/purescript-foldable-traversable/pull/145))

### purescript-foreign

Other improvements:
- Replace all usages of `F` and `FT` with `Except`/`ExceptT (NonEmptyList ForeignError)` ([#87](https://github.com/purescript/purescript-foreign/pull/87) by @JordanMartinez)

  Often times, the `F` and `FT` aliases did more to hinder usage of this library than help. These aliases
  haven't been deprecated, but usage of them is now discouraged. All code in the library now uses
  the full type that is aliased by `F` and `FT`.

### purescript-free

Breaking changes:
- Drop deprecated `unfoldCofree`; use `buildCofree` instead ([#124](https://github.com/purescript/purescript-free/pull/124) by @JordanMartinez)

### purescript-graphs

New features:
- Added `Foldable` and `Traversable` instances for `Graph` ([#16](https://github.com/purescript/purescript-graphs/pull/16) by @MaybeJustJames)

### purescript-integers

Breaking changes:
- Migrate `trunc` from `math` package ([#51](https://github.com/purescript/purescript-integers/pull/51) by @JordanMartinez)

Other improvements:
- Drop dependency on deprecated `math` package ([#51](https://github.com/purescript/purescript-integers/pull/51) by @JordanMartinez)

### purescript-lists

Breaking changes:
- Drop deprecated `group'` and `mapWithIndex` ([#206](https://github.com/purescript/purescript-lists/pull/206) by @JordanMartinez)
- Change `groupAllBy` to use a comparison function ([#191](https://github.com/purescript/purescript-lists/pull/191))

### purescript-maybe

New features:
- Added `Semiring` instance ([#59](https://github.com/purescript/purescript-maybe/pull/59))

### purescript-newtype

New features:
- Added `modify` ([#19](https://github.com/purescript/purescript-newtype/pull/19) by @dwhitney)

### purescript-nonempty

Other improvements:
- Drop deprecation warning on `fold1` ([#45](https://github.com/purescript/purescript-nonempty/pull/45) by @JordanMartinez)

### purescript-numbers

New features:
- Ported various functions & constants from `purescript-math` ([#18](https://github.com/purescript/purescript-numbers/pull/18) by @JamieBallingall)

  Specifically...
  - `abs`, `sign`
  - `max`, `min` (which work differently than `Number`'s `Ord` instance)
  - `ceil`, `floor`, `trunc`, `remainder`/`%`, `round`
  - `log`
  - `exp`, `pow`, `sqrt`
  - `acos`, `asin`, `atan`, `atan2`, `cos`, `sin`, `tan`
  - Numeric constants: `e`, `ln2`, `ln10`, `log10e`, `log2e`, `pi`, `sqrt1_2`,
  `sqrt2`, and `tau`

### purescript-ordered-collections

New features:
- Exported `Data.Map.Internal` data constructors ([#52](https://github.com/purescript/purescript-ordered-collections/pull/52) by @natefaubion)
- Add unbiased `Semigroup`/`Monoid` instances to `Map` with `Warn` ([#54](https://github.com/purescript/purescript-ordered-collections/pull/54) by @JordanMartinez)

### purescript-prelude

Breaking changes:
- Change Generic Rep's `NoConstructors` to newtype `Void` ([#282](https://github.com/purescript/purescript-prelude/pull/282) by @JordanMartinez)
- Replaced polymorphic proxies with monomorphic `Proxy` ([#281](https://github.com/purescript/purescript-prelude/pull/281), #288 by @JordanMartinez)
- Fix `signum zero` to return `zero` ([#280](https://github.com/purescript/purescript-prelude/pull/280) by @JordanMartinez)
- Fix `Show` instance on records with duplicate labels by adding `Nub` constraint ([#269](https://github.com/purescript/purescript-prelude/pull/269) by @JordanMartinez)

New features:
- Added the `Data.Reflectable` module for type reflection ([#289](https://github.com/purescript/purescript-prelude/pull/289) by @PureFunctor)

Other improvements:
- Changed `unit`'s FFI representation from `{}` to `undefined` ([#267](https://github.com/purescript/purescript-prelude/pull/267) by @JordanMartinez)
- Added clearer docs for Prelude module ([#270](https://github.com/purescript/purescript-prelude/pull/270) by @JordanMartinez)
- Clarify docs for `flip` ([#271](https://github.com/purescript/purescript-prelude/pull/271) by @JordanMartinez)
- Add comment that `Number` is not a fully law abiding instance of `Ord` ([#277](https://github.com/purescript/purescript-prelude/pull/277) by @JamieBallingall)
- The internal FFI function `join` in `Data.Show` has been renamed to `intercalate` to
  match the same function in `Data.Show.Generic` ([#274](https://github.com/purescript/purescript-prelude/pull/274) by @cdepillabout)

### purescript-quickcheck

Breaking changes:
- Replaced polymorphic proxies with monomorphic `Proxy` ([#132](https://github.com/purescript/purescript-quickcheck/pull/132) by @JordanMartinez)
- Make `frequency` use `NonEmptyArray` ([#131](https://github.com/purescript/purescript-quickcheck/pull/131) by @JordanMartinez)

  Now `oneOf` and `frequency` both use `NonEmptyArray` rather than `NonEmptyList`.

Bugfixes:
- `quickCheckPure` and `quickCheckPure'` stack safety ([#127](https://github.com/purescript/purescript-quickcheck/pull/127))

### purescript-record

Breaking changes:
- Replaced polymorphic proxies with monomorphic `Proxy` ([#81](https://github.com/purescript/purescript-record/pull/81) by @JordanMartinez)

### purescript-strings

Breaking changes:
- Replaced polymorphic proxies with monomorphic `Proxy` ([#158](https://github.com/purescript/purescript-strings/pull/158) by @JordanMartinez)
- In `slice`, drop bounds checking and `Maybe` return type ([#145](https://github.com/purescript/purescript-strings/pull/145) by Quelklef)

Other improvements:
- Surround code with backticks in documentation ([#148](https://github.com/purescript/purescript-strings/pull/148))

### purescript-transformers

New features:
- Add `Foldable`, `FoldableWithIndex`, and `Traversable` instances for `EnvT` ([#113](https://github.com/purescript/purescript-transformers/pull/113) by @abaco)

### purescript-typelevel-prelude

Breaking changes:
- Replaced polymorphic proxies with monomorphic `Proxy` ([#72](https://github.com/purescript/purescript-typelevel-prelude/pull/72) by @JordanMartinez)

New features:
- Added `#` infix operator for `FLIP` (e.g. `Int # Maybe` == `Maybe Int`) ([#73](https://github.com/purescript/purescript-typelevel-prelude/pull/73) by @JordanMartinez)

### purescript-unfoldable

New features:
- Add `iterateN` function ([#20](https://github.com/purescript/purescript-unfoldable/pull/20) by @matthewleon and @JordanMartinez)

### purescript-validation

Breaking changes:
- Drop deprecated `unV`; use `validation` instead ([#38](https://github.com/purescript/purescript-validation/pull/38) by @JordanMartinez)

## `purescript-contrib` Libraries

### purescript-aff

Breaking changes:
- Restrict the signature of `launchAff_` to only work on `Aff Unit` ([#203](https://github.com/contrib/purescript-aff/pull/203) by @i-am-the-slime)

Other improvements:
- Ensure all directly-imported packages are included in the `spago.dhall` file ([#205](https://github.com/contrib/purescript-aff/pull/205) by @ptrfrncsmrph)

### purescript-affjax

Breaking changes:
- Update all request functions to take a driver arg ([#171](https://github.com/contrib/purescript-affjax/pull/171) by @JordanMartinez)

  Affjax works on the Node.js and browser environments by relying on a `require`
  statement within a function. Depending on the environment detected,
  either `XHR` or `XmlHttpRequest` is used. Since ES modules do not allow
  one to call `import` within a function in a _synchronous_ way,
  we cannot continue to use this approach.

  Rather, all request-related functions (e.g. `request`, `get`, etc.) now take
  as their first argument an `AffjaxDriver` value. Different environments
  will pass in their implementation for that driver and re-export
  the functionality defined in `affjax`.

  To fix your code, depend on the corresponding library below and update the imported
  module from `Affjax` to `Affjax.Node`/`Affjax.Web`:
  - If on Node.js, use [`purescript-affjax-node`](https://github.com/purescript-contrib/purescript-affjax-node/).
  - If on the brower, use [`purescript-affjax-web`](https://github.com/purescript-contrib/purescript-affjax-web/).

### purescript-argonaut-core

Other improvements:
* Fixed readme bug where `jsonParser` was imported from `Data.Argonaut.Core` instead of `Data.Argonaut.Parser` ([#50](https://github.com/contrib/purescript-argonaut-core/pull/50) by @flip111)

### purescript-argonaut-traversals

Other improvements:
- Updated `README.md` to make the Quick start example runnable ([#37](https://github.com/contrib/purescript-argonaut-traversals/pull/37) by @dk949)

### purescript-arraybuffer

Breaking Changes:
- Replaced polymorphic proxies with monomorphic `Proxy` ([#41](https://github.com/contrib/purescript-arraybuffer/pull/41) by @JordanMartinez)

### purescript-colors

New features:
- Support for alpha channel added to `toHexString` and `fromHexString` ([#56](https://github.com/contrib/purescript-colors/pull/56) by @nsaunders)

### purescript-css

Breaking changes:
- Add support for `calc` expressions ([#140](https://github.com/contrib/purescript-css/pull/140) by @nsaunders)
- Add table selector ([#141](https://github.com/contrib/purescript-css/pull/141) by @plurip-software)
- Update the box-shadow implementation ([#88](https://github.com/contrib/purescript-css/pull/88) by @vyorkin)
- Dropped almost all named colors ([#156](https://github.com/contrib/purescript-css/pull/156) by @JordanMartinez)

  These colors were originally defined in `purescript-colors` (i.e.
  one module per schema) because each schema should be defined as its
  own library. This change was propagated to this release.

New features:
- Add smart constructors for generic font families ([#68](https://github.com/contrib/purescript-css/pull/68), #136 by @Unisay and @JordanMartinez)
- Add support for `text-direction` ([#83](https://github.com/contrib/purescript-css/pull/83), #137 by @vyorkin and @JordanMartinez)
- Add outline and constituent properties ([#145](https://github.com/contrib/purescript-css/pull/145) by @nsaunders)
- Add support for `visibility` property ([#148](https://github.com/contrib/purescript-css/pull/148) by @nsaunders)

Other improvements:
- Remove ending space in css output (e.g. `padding: 1 2 3 4 `) ([#135](https://github.com/contrib/purescript-css/pull/135) by @chexxor and @JordanMartinez)

### purescript-fork

Other improvements:
- Ensure all imported packages are in the spago.dhall file ([#17](https://github.com/contrib/purescript-fork/pull/17) by @artemisSystem)

### purescript-now

Other improvements:
- Added tests ([#20](https://github.com/contrib/purescript-now/pull/20) by @ntwilson)
- Added quick start ([#22](https://github.com/contrib/purescript-now/pull/22) by @maxdeviant)

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

  ([#154](https://github.com/contrib/purescript-parsing/pull/154) by @natefaubion)
- Make `<??>` right-associative ([#164](https://github.com/contrib/purescript-parsing/pull/164) by @JordanMartinez)
- Drop `<?>` and `<~?>` prec from 3 to 4 ([#163](https://github.com/contrib/purescript-parsing/pull/163), #164 by @JordanMartinez)

  `<|>` was made right associative. Decreasing these two operators
  prevents a compiler error (i.e. `MixedAssociativityError`)
  without causing issues with `<$>`.
- Rename module prefix from `Text.Parsing.Parser` to `Parsing` ([#169](https://github.com/contrib/purescript-parsing/pull/169) by @jamesdbrock)

### purescript-profunctor-lenses

Breaking changes:
- Replaced polymorphic proxies with monomorphic `Proxy` ([#141](https://github.com/contrib/purescript-profunctor-lenses/pull/141) by @JordanMartinez)

New features:
- Add `coerced` ([#140](https://github.com/contrib/purescript-profunctor-lenses/pull/140) by @ozkutuk)
- Add `sans` and `both` ([#97](https://github.com/contrib/purescript-profunctor-lenses/pull/97) by @xgrommx)

Bugfixes:
- Fix broken `reindex` for v0.15 due to [Purescript PR [#4033](https://github.com/contrib/purescript-profunctor-lenses/pull/4033)](https://github.com/purescript/purescript/pull/4033)

Other improvements:
- Replace manual tests with automated tests using `assert` ([#135](https://github.com/contrib/purescript-profunctor-lenses/pull/135) by @neppord)
- Improve documentation for `united` ([#134](https://github.com/contrib/purescript-profunctor-lenses/pull/134) by @neppord)
- Add guide on impredicativity explaining difference between `Lens` vs `ALens` ([#136](https://github.com/contrib/purescript-profunctor-lenses/pull/136) by @i-am-tom and @JordanMartinez)

### purescript-quickcheck-laws

Breaking changes:
- Drop `Proxy2`/`Proxy3` usage in favor of just `Proxy` ([#59](https://github.com/contrib/purescript-quickcheck-laws/pull/59) by @JordanMartinez)

New features:
- Provide `Arbitrary`-less law checks ([#36](https://github.com/contrib/purescript-quickcheck-laws/pull/36) by @matthewleon, #57 by @JordanMartinez)

Other improvements:
- Fix integer overflow error in test for Ints ([#58](https://github.com/contrib/purescript-quickcheck-laws/pull/58) by @JordanMartinez)

### purescript-react

Breaking changes:
- Replaced polymorphic proxies with monomorphic `Proxy` ([#185](https://github.com/contrib/purescript-react/pull/185) by @JordanMartinez)

### purescript-routing

Other improvements:
- Update readme to show how to use newtypes ([#57](https://github.com/contrib/purescript-routing/pull/57) by @brodeuralexis and @JordanMartinez)

### purescript-string-parsers

Breaking changes:
- Change precedence of `withError` operator to accommodate associativity changes in `Control.Alt` ([#92](https://github.com/contrib/purescript-string-parsers/pull/92) by @thomashoneyman)

### purescript-these

Breaking changes:
- Replaced polymorphic proxies with monomorphic `Proxy` ([#41](https://github.com/contrib/purescript-these/pull/41) by @JordanMartinez)

### purescript-uri

Bugfixes:
- Made all parsers stack safe on long input ([#63](https://github.com/contrib/purescript-uri/pull/63) by @garyb)
- Exceptions are no longer thrown when using e.g. `valueFromString` with lone surrogates ([#68](https://github.com/contrib/purescript-uri/pull/68) by @ysangkok)

Other improvements:
- Update README.md rfc link ([#67](https://github.com/contrib/purescript-uri/pull/67) @codingedgar)

## `purescript-web` Libraries

### purescript-canvas

Breaking changes:
- Support arcs that are drawn counter-clockwise ([#58](https://github.com/web/purescript-canvas/pull/58), #83 by @karljs and @JordanMartinez)
- The `Transform` type now uses the field names `a`, `b`, `c`, `d`, `e` and `f`, instead of `m11`, `m12`, `m21`, `m22`, `m31` and `m32` ([#86](https://github.com/web/purescript-canvas/pull/86) by @artemisSystem)

New features:
- Added `createImageDataWith` ([#81](https://github.com/web/purescript-canvas/pull/81))

Other improvements:
- Added ESLint config and fixed the resulting linter issues ([#82](https://github.com/web/purescript-canvas/pull/82))

### purescript-web-cssom

Breaking changes:
- Update `CSSStyleDeclaration` functions to take `style` arg last ([#12](https://github.com/web/purescript-web-cssom/pull/12) by @theqp)

  This follows the convention of "the thing being operated on" occurs
  last in function that take multiple arguments.

### purescript-web-dom

Breaking changes:
- Unwrap returned `Effect` for `doctype` ([#52](https://github.com/web/purescript-web-dom/pull/52) by @JordanMartinez)
- Port `getBoundingClientRect` from `web-html`; set arg to `Element` ([#53](https://github.com/web/purescript-web-dom/pull/53) by @JordanMartinez)

### purescript-web-events

New features:
- Add FFI for `CustomEvent` constructor ([#25](https://github.com/web/purescript-web-events/pull/25) by @JordanMartinez)
- Add `addEventListenerWithOptions` to expose more options ([#25](https://github.com/web/purescript-web-events/pull/25) by @JordanMartinez)

### purescript-web-file

Other improvements:
- Update `Math` import to use `Data.Number` ([#20](https://github.com/web/purescript-web-file/pull/20) by @JordanMartinez)

### purescript-web-html

Breaking changes:
- Move `getBoundingClientRect` to `purescript-web-dom` ([#73](https://github.com/web/purescript-web-html/pull/73) by @JordanMartinez)
- Drop duplicated `set/getClassName` and `classList` ([#74](https://github.com/web/purescript-web-html/pull/74) by @JordanMartinez)

  These three entities are already defined in `purescript-web-dom`

## `purescript-node` Libraries

### purescript-node-fs-aff

Breaking changes:
- Update `mkdir'` to take options arg ([#34](https://github.com/node/purescript-node-fs-aff/pull/34) by @JordanMartinez)

### purescript-node-fs

Breaking changes:
- Update `mkdir` to take an options record arg, exposing `recursive` option ([#53](https://github.com/node/purescript-node-fs/pull/53), #55, #58 by @JordanMartinez)

  To get back the old behavior of `mkdir'`, you would call `mkdir' { recursive: false, mode: mkPerms all all all }`

### purescript-node-streams

Other improvements:
- Fix `Gzip` example ([#17](https://github.com/node/purescript-node-streams/pull/17), #36 by @matthewleon and @JordanMartinez)
