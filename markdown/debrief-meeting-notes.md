# Debrief Meeting

Release took 2 months
- (1x issue) wanted to get `purs publish` to work with `purs.json` file - delayed things a tiny bit
- (1x issue) CI had a few wrinkles due to building the Linux binary in the image
- (ongoing issue) - package sets depend on `easy-purescript-nix` which we don't control and can't update immediately
  - by not controlling that, we can't create a new package set for a new release immediately, which delays the Discourse announcement
- The first few breaking changes compiler PRs were delayed until these things were fixed
- The ES Modules PR got delayed because there were a few cleanups to do
  - AST/IIFE refinements PR
- (1x issue) Release questions: what do we call the alpha release?
  - this was resolved with the continuous deployment work Ryan did
- (1x issue) needing to update `setup-purescript` GH Action to work on prereleases
- merging more breaking changes compiler PRs (syntax)
  - issues weren't always clearly documented as to how to fix them correctly
- update the package set to use new prerelease
  - I think we were delayed again by `easy-purescript--nix`
- dropping `purs bundle` and other `language-javascript` PRs and their questions
  - took time to get feedback and couldn't do this beforehand because it wasn't clear exactly what would be affected until we ran into these issues
- (1x issue) migrating `pulp` to GH Actions and updating it to work on new FFI format
- updating the `purescript-ecosystem-update` scripts (peu) to work
- submitting first round of `core` library updates using `peu`
- commenting out all packages unrelated to `core`/`contrib`/`node`/`web` libraries and making a `prepare-0.15` package set
- (1x issue) migrating `spago` to work on new FFI format
  - this was a bit harder because of the usage of package sets



Summarized:
- the intended "quick release" of `0.15.0` would have been released quickly if not for the following:
  - 1x costs:
    - updating a no-longer-maintained build tool, `pulp`, to work on the new FFI format
    - updating `spago` to work on the new FFI format when the main maintainer was on vacation / busy with other life things
    - updating `purescript-ecosystem-update` scripts to work on new breaking changes
  - ongoing issues:
    - relying upon 3rd-party projects that we cannot update ourselves: `easy-purescript-nix`
    - last-minute compiler PRs delaying the release: whether to include them or not
      - these tend to occur every time and not much can be done about it outside of a clear roadmap
- the overall release cycle did go better than previous times
  - PR submission was done in correct order
  - PR release was straight-forward
  - package set still requires manual mangling, which can be annoying
  - `peu` scripts sometimes can be reused and other times require rewriting
- what would make it better?
  - not relying on `easy-purescript-nix` / having our own fork ready-to-go as a temporary solution
  - enabling those in the community to use `peu` to update their code as a sort of 'auto-migrate' solution
  - being clearer about when authors can update their packages
  - having a PS registry that supports monorepos and moving all of `core` into a single monorepo while still publishing multiple packages
    - or even having a few smaller monorepos if 1 monorepo was still too large

## Next Steps

- writing a release guide
- finishing the Try PureScript update
- updating the Cookbook?
- updating/dropping the Book?
- real question: how do we delegate more maintenance to others?

