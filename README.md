# Workflow

## Context

These instructions work only on the `purescript` organization repos, which use `bower`. These instructions will change when we work on the `purescript-contrib` organization repos (because it uses `spago`) and will likely change slightly after that when people work on updating the non-`purescript*` repos.

This workflow makes heavy usage of GitHub's new CLI tool, `gh`, and bash scripts to speed up the manual process of cloning a repo, setting up the remote, making changes, and submitting a PR. You can submit a PR in less than 20 seconds when the library doesn't need to be updated.

This workflow assumes that you will use two terminal sessions/windows/tabs to update a library: one where the present working directory is this folder (i.e. `master`) and the other will be the library you rae updating (e.g. `purescript-prelude`). The `purs` binary is stored in this folder (i.e. `master`) (as opposed to the folder that stores a library, such as `purescript-prelude`), so that you don't need to deal with path mangling. Rather, you will run `./compile.sh <packageName>` to compile the package properly.

At this time, `package-query.js` isn't necessary as `libDeps.txt` provides the information we currently need at this stage of the update. It may be needed in the future, but I will likely just push a change to this repo that you can then fetch to get that new information.

## What needs to be updated?

### Things specific to the `purescript` organization repos:

These are all automated via the `./setupRemote.sh` file:
- `.travis.yml` file's `TAG` needs to be updated to `v0.14.0-rc3` or whatever the latest release candidate.
- all dependencies in the `bower.json` file need to be updated to `master`. **Note:** while this is automated, it might also incorrectly update unrelated version bounds to `master`.
- `package.json` file's `purescript-psa` version needs to be updated to `v0.8.0`.

### Things specific to `v0.14.0`

Any usage of a kind-specific proxy should be replaced with the "forall solution." This will reduce code breakage and give people time to update to the `Proxy` type.
```purescript
-- Before
foo :: forall s. IsSymbol s => SProxy s -> --
foo _ = --

-- After
foo :: forall sproxy s. IsSymbol s => sproxy s -> --
foo _ = --
```

Usages of `# Type` should be replaced with `Row Type`.

Usages of `RowList` will need to be replaced with `RowList Type`.

Usages of `unsafeCoerce` should be updated to use `coerce` from [`safe-coerce`](https://github.com/purescript/purescript-safe-coerce) when possible.

Kind signatures may need to be added to various types and type classes:
```purescript
-- data, type, newtype end in 'Type'
data TypeName :: forall k. k -> Type
data TypeName k = TypeConstructorName

-- type classes' kind signature ends in 'Constraint'
class TypeClass :: forall k. k -> Type -> Symbol -> Constraint
class TypeClass anyKind aType aSymbol
```

All other breaking changes, documentation, and other issues should be merged AFTER the PR that updates the library to `v0.14.0` is merged.

## Procedures

### Setup your environment

1. Create a new directory explicitly for this purpose so that any changes made in this directory will not affect any of your other projects

```bash
mkdir fourteen
```

2. `git clone` this repo while inside that new folder

```bash
cd fourteen
git clone https://github.com/JordanMartinez/updatePsLibs.git master
cd master
```

3. [Install GitHub's new CLI tool: `gh`](https://github.com/cli/cli#installation)

4. Run the `./init.sh` file (globally installs `pulp`, `bower`, and `purescript-psa`; logs you into GitHub via `gh`; downloads the `purs` binary)

```bash
./init.sh
```

5. Modify the `./setupRemote.sh` file
     - Change the `GH_USERNAME` variable to use your GitHub username
     - Change the `PS_TAG` variable to whatever is the latest.

### Contribute

1. Look at [`libDeps.txt`](./libDeps.txt) and see which `purescript` organization repo hasn't been claimed yet. Refer to these links as well:
    - [purescript repo's "update ecosystme to v0.14.0" issue](https://github.com/purescript/purescript/issues/3942)
    - [all unmerged PRs currently submitted to update a library to `v0.14.0`](https://github.com/search?q=org%3Apurescript+is%3Apr+state%3Aopen+Update+to+v0.14.0)
    - [all merged PRs submitted that already updated a library to `v0.14.0`](https://github.com/search?q=org%3Apurescript+is%3Apr+state%3Aclosed+Update+to+v0.14.0)

2. Claim the package on the [purescript repo's "update ecosystme to v0.14.0" issue](https://github.com/purescript/purescript/issues/3942)

3. Clone the repo, set up remotes, and automate the boilerplate updates (i.e. `.travis.yml`, `package.json`, `bower.json` files) by running the below bash script

```bash
# pwd = master folder
./setupRemote.sh <packageName>
# A folder called `../purescript-<packageName>` will now have been created
```

4. Look at the package's repo to see whether any issues/PRs should also be merged. For example, if someone has already added role annotations and whatnot, then merge their PR into yours rather than redoing the work they have done.

5. Test whether code compiles. If `bower` complains, select the `master` branch of each repository (usually an answer of `1` will be correct)

```bash
# pwd = master folder
./compile.sh <packageName>
# This will compile the code in `../purescript-<packagename>`
```

6. Navigate to the created directory

```bash
cd ../purescript-<packageName>
```

7. Create a PR via `gh` CLI tool

```bash
# pwd = purescript-<packageName> folder
gh pr create --title "Update to v0.14.0-rc3" --body "Backlinking to purescript/purescript#3942"
# 1st question: Choose the `purescript/purescript-<packageName>`
# 2nd question: Choose your repo
# 3rd Question: Choose 'Submit'
```

8. If the library needs any updating, has any other issues or PRs, work on those in a separate PR.

9. Loop

## Update the `prepare-0.14` branch in the `package-sets` repo

### Context

**When your "Update to v0.14.0" PR gets merged, submit a PR to the `package-sets` repo's `prepare-0.14` branch and update the repo's version to `master`.**

Note: This step verifies that future PureScript release candidates still build libraries that were updated using a prior release candidate. For example, I updated `purescript-prelude` using the `v0.14.0-rc2` release. The `v0.14.0-rc3` release was made after that. Does `purescript-prelude` still build fine on the `-rc3` release? By submitting a PR, I can verify that `prelude` will still compile fine via `spago` without needing to submit PRs that update the TAG in the `.travis.yml` file of the library's repo.

The `master` version will be changed to the released version once everything builds properly.

### Making the First PR

1. `git clone` the `package-sets` repo using

```bash
pwd # should be `fourteen/`, the folder containing `master` and other repos
gh repo fork purescript/package-sets --clone=true --remote=true
cd package-sets/
git checkout upstream/prepare-0.14
export PACKAGE_NAME="<package name>"
git switch -c "$PACKAGE_NAME-0.14"

# Add the library to the list of updated libraries
# and update its version field to `master`.
#
# For an example of the next two steps' work,
# see https://github.com/purescript/package-sets/pull/717

# Update the `src/updatedLibs.dhall` file
# so that the list of dependencies includes the name
# of the repo you updated
nano src/updatedLibs.dhall

# Update the `src/groups/purescript.dhall` file
# so that the version of that library now reads `master`.
#
# Tip: search for "<packageName> =" to quickly find that
# entry in the file
nano src/groups/purescript.dhall

git add src/updatedLibs.dhall
export MSG="Updated $PACKAGE_NAME to v0.14.0"
git commit -m $MSG
gh pr create --title MSG --body ""
# 1st question: Choose the `purescript/package-sets` repo
# 2nd question: Choose your repo
# 3rd Question: Choose 'Submit'
```

### Making Subsequent PRs

```bash
cd package-sets/
# 1. Fetch latest changes to package set

export PACKAGE_NAME="<package name>"
git checkout -b "$PACKAGE_NAME-0.14"
git fetch upstream
git reset --hard upstream

# 2. Add the library to the list of updated libraries
# and update its version field to `master`.
#
# Example: https://github.com/purescript/package-sets/pull/717

# Update the `src/updatedLibs.dhall` file
# so that the list of dependencies includes the name
# of the repo you updated
nano src/updatedLibs.dhall

# Update the `src/groups/purescript.dhall` file
# so that the version of that library now reads `master`.
#
# Tip: search for "<packageName> =" to quickly find that
# entry in the file
nano src/groups/purescript.dhall

# 3. Submit a PR with the update

git add src/updatedLibs.dhall
export MSG="Updated <package name> to v0.14.0"
git commit -m $MSG
gh pr create --title MSG --body ""
# 1st question: Choose the `purescript/package-sets` repo
# 2nd question: Choose your repo
# 3rd Question: Choose 'Submit'
```
