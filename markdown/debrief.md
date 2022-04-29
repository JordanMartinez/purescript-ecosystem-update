# Debrief

`v0.14.7` was released on `Feb 26, 2021`. `v0.15.0` was released on `April 29, 2022`. Below summarizes the issues we experienced along the way and tries to provide an explanation for what happened, why, what we can fix, and what we can't.

## The Larger Context

Originally, the whole goal of the `0.15.0` release was to drop CJS modules and only support ES modules and merge the other breaking change PRs we knew of at the time. The hope was to release that `0.15.0` quickly and quicker than the `0.14.0` release.

## What went well

- We avoided a number of issues we experienced in the `0.14.0` ecosystem update
  - We had a relatively accurate dependency graph of all projects, so that we could submit PRs in the correct order
  - We avoided issues with the Bower solver, using the correct default branch name (e.g. `main` vs `master`) for a given dependency when making the initial round of breaking changes.
  - PRs were approved usually within 20 minutes to an hour unlike the 1-4 days in the `0.14.0` release
  - Finding issues was easy due to the backlinking to a single meta issue
  - All breaking changes were identified before the release cycle began, making it easy to know which issues/PRs to resolve before a library was "done"
- The weekly working group meeting provided a point of contact to reach consensus about some things faster.
- We added an 'ecosystem changelog' for easier perusal than checking each library's changelog
- Communication via flowcharts indicated that we were making progress and helped people see where in the release cycle we were.

## Specific issues

Ordering these in a chronological way, these are the issues we came across.

### Needing to update the `purescript-ecosystem-update` scripts

When Jordan worked on the `v0.14.0` ecosystem update, the scripts in this repo didn't exist and his bash knowledge wasn't exactly great. But he put something together that worked but was brittle.

For the `v0.15.0` update, these scripts were cleaned up and made more modular, making the workflow much easier than it was last time. However, the scripts used last time didn't always apply and some new ones needed to be written and tested. All of this took some time to update before any libraries could be updated.

### Updating `pulp` to work on `0.15.0` so `core` libraries tests would run

Before updates to `core` repos could be made, `pulp` needed to be updated to work on both `v0.14.0` and `v0.15.0`. Otherwise, running `pulp test` in CI would error because `pulp` would generate a CJS module, not an ES module for the file that was executed via `node test.j`. However, this tool is largely unmaintained and unfamiliar to current core team members now that Harry stepped down as a core team member.

Furthermore, `pulp`'s CI was stil on Travis CI and had to be migrated to GitHub Actions. Once migrated, we had to figure out how to get the Windows build to work, debugging that through CI. This took about a week and a half to finish.

### Updating `core` libraries

These libraries were generally updated without issue. It took about 1-2 days to merge all breaking changes.

### `spago` delayed by a bug and a release

Once `pulp` was updated and `core` repos were updated, the next blocker was `spago`. Before updates to `contrib` repos could be made, which further blocked `node` and `web` repos, `spago` needed to be updated to work on both `v0.14.0` and `v0.15.0`. Its usage of `nix` and the lack of familiarity of collaborators working on this part slowed things down. Moreover, a file whose parent directory included a space produced a bug that needed to be resolved before a new release could be made. That issue blocked a new `0.15.0`-compatible `spago` release, which further blocked `contrib` updates.

Fortunately, Thomas pointed out that we alo needed to run `pulp` in CI to verify that the `bower.json` files worked properly (so `pulp` users could still use those libraries). One side-effect of this need is that we could bypass the `spago` limitations by using `pulp test` in CI until `spago` got updated. Bypassing the `spago test` calls in CI with minimal effort was done by commenting out those lines.

### Updating `contrib`, `node`, and `web` libraries

These libraries were generally updated without issue. It took about 2-3 days to merge all breaking changes.

### Last Minute Compiler PR: optimizing lazy initialization of recursive bindings

At this point, we were thinking that a `0.15.0` release would happen soon. All we had to do was finish updating `spago` to work with the `0.15.0` `purs` binary, release a `0.15.0` version of `core`, `contrib`, `node`, and `web` libraries, and we'd be done. However, it was around this time that Ryan's PR was finished and ready for review. This PR was a breaking change that would allow us to merge a huge performance improvement PR later as a non-breaking change. Reviewing and merging this PR took about two weeks due to the complexity of it.

### More `spago` delays

As `contrib`, `node`, and `web` libraries were updated and the above PR reviewed, a PR that updated `spago` was being worked on. However, the PR that implemented the necessary fixes and updates was delayed by a number of issues, mostly related to CI.

Originally, `spago run`/`spago test` didn't work properly when a space existed in the parent directory (e.g. `/home/user/some parent/spagoProject`). This was "fixed" by changing how Spago calls the entry point into the compiled JavaScript from `node run.js` to `node --eval "import Main from 'output/Main/index.js'; main();"`. But the above fix broke CLI programs because `node --eval` doesn't pass arguments to the program in the same way that `node run.js` does, and thus needed to be reverted.

Reverting the incorrect fix and implementing a correct one was made in this PR. However, tests needed to be added to CI to verify that the fix worked.
- To make tests work, we needed a `0.15`-compatible package set, so we could only run a subset of `spago`'s tests on a `0.15.0` compiler
- Once a frozen package set was made and tests passed, the issue was that the PR's diff was too large and could be simplified.
- Once the diff was simplified, the issue was that the `0.15.0-alpha` release used in the test was being downloaded directly from GitHub rather than installed via `npm`. The question of whether we could publish and install a `purs` prerelease via npm was raised.

### Last Minute Compiler PR: Float Common Subexpressions

Is this a breaking change?
- If so, we should merge it now; otherwise, it likely won't get merged for a year.
- If not, we can merge it in a patch release (e.g. `0.15.1`).

Will it break people's code?
- If not, we can merge it in a patch release (e.g. `0.15.1`).
- If it does, we can't merge it in a patch release (e.g. `0.15.1`) as then it would be a breaking change.

### Release Questions

As we got closer to the end of the release cycle, the below questions arose:
- We're using `purs-tidy` to format source code in CI throughout the `contrib`, `node`, and `web` libraries.
  - Should it be used in `core` libraries' CI, too?
  - If not, can we at least format the code in each library?
  - If yes, then when?
    - During the PRs that make the `0.15.0` release for that library?
    - Or in a future round of maintenance PRs (69 PRs total)?
- Due to the `spago` update delay, should we uncomment the `spago test` lines in CI when making the release PRs for each library? Or should we wait until `spago` is updated?
- When should we "freeze" the compiler and not merge any more PRs?
  - Now?
  - After merging the Visible Type Applications PR, so that the type signature of `reflectType` is `value` rather than `Proxy typeLevelValue -> valueLevelValue`?
    - General consensus: No. It can be merged in a future patch release.
  - After the Float Common Subexpressions PR, so that we don't risk the chance of a `0.15.1` release breaking people's code?
    - General consensus: pending.
- When do we make the release PRs to `core`, `contrib`, `node` and `web` libraries?
  - Once the compiler is frozen?
  - When the compiles is frozen and after `spago` is updated, so that we can also uncomment the `spago test` lines in CI during these PRs and not need to a another round of maintenance PRs on core?

## Breaking changes with mistakes

Specifically, the breaking changes made to `node-streams`' `write` and `writeString` didn't implement the correct FFI signature. This needed to be resolved before a `0.15.0` release could be made and a new set of libraries released.

## Miscellaneous things not in a chronological order

- Dependencies on entities outside of Core Team members controls:
  - `easy-purescript-nix`:
    - `easy-purescript-nix` didn't add the `0.15.0` alpha releases when such PRs were submitted
    - as a result, `spago`, which depends on that for its tests, couldn't be updated until it used a fork of `easy-purescript-nix`
- dependencies before `0.15.0` PureScript release PR would build
  - updating tests to use the released version of libraries
  - referring to the first `0.15.0` package set

## General Takeaways

- Having a monorepo for (or a subset of some of the libraries in) `core`, `contrib`, `node`, and `web` libraries would speed up their releases:
  - Every breaking change release cycle needs 2 rounds of PRs. The first round updates the library to a new compiler AND makes breaking changes. The second round specifies the dependencies' versions and actually releases that library
  - If these were stored in a monorepo, the number of PRs to approve would significantly decrease and the ease of which we could make such releases would grealty increase.
  - Monorepo support won't be an option until the PureScript Registry goes live.
- Last-minute compiler PRs delay a release for two reasons:
  - because the time period for getting them in next is 1 year due to how much work it takes to update `core`, `contrib`, `node`, and `web` libraries. When the PR is signficant, it's tempting to give it more time to finish and be merged.
  - because a roadmap isn't defined, we make ad-hoc exceptions.
