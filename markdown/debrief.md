# Debrief

`v0.14.7` was released on `Feb 26, 2021`. `v0.15.0` was released on `???, 2022`. Below summarizes the issues we experienced along the way and tries to provide an explanation for what happened, why, what we can fix, and what we can't.

## The Larger Context


## Specific issues

Ordering these in a chronological way, these are the issues we came across.

### Needing to update the `purescript-ecosystem-update` scripts

When Jordan worked on the `v0.14.0` ecosystem update, the scripts in this repo didn't exist and his bash knowledge wasn't exactly great. But he put something together that worked but was brittle.

For the `v0.15.0` update, these scripts were cleaned up and made more modular, making the workflow much easier than it was last time. However, the scripts used last time didn't always apply and some new ones needed to be written and tested.

### Needing to update build tools

Before updates to core repos could be made, `pulp` needed to be updated to work on both `v0.14.0` and `v0.15.0`. Otherwise, CI on a PR made to a core repo (e.g. `prelude`) would not pass. However, this tool is largely unmaintained and unfamiliar to current core team members now that Harry stepped down as a core team member.

Moreover, before support for `v0.15.0` could be added, CI needed to migrated from Travis CI to GitHub Actions and then get the Windows build to work. This technical debt slowed that update down.

Similarly, before updates to `contrib` repos could be made, which further blocked `node` and `web` repos, `spago` needed to be updated to work on both `v0.14.0` and `v0.15.0`. Its usage of `nix` and the lack of familiarity of collaborators working on this part slowed things down as well. Moreover, a file whose parent directory included a space produced a bug that needed to be resolved before a new release could be made. This again slowed down `contrib` updates significantly.

### Issue Name