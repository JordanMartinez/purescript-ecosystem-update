# Workflow

## Context

These instructions work only on the `purescript` organization repos, which use `bower`. These instructions will change when we work on the `purescript-contrib` organization repos (because it uses `spago`) and will likely change slightly after that when people work on updating the non-`purescript*` repos.

This workflow makes heavy usage of GitHub's new CLI tool, `gh`, and bash scripts to speed up the manual process of cloning a repo, setting up the remote, making changes, and submitting a PR. You can submit a PR in less than 20 seconds when the library doesn't need to be updated.

This workflow assumes that you will use two terminal sessions/windows/tabs to update a library: one where the present working directory is this folder (i.e. `master`) and the other will be the library you rae updating (e.g. `purescript-prelude`). The `purs` binary is stored in this folder (i.e. `master`) (as opposed to the folder that stores a library, such as `purescript-prelude`), so that you don't need to deal with path mangling. Rather, you will run `./compile.sh <packageName>` to compile the package properly.

At this time, `package-graph.js` isn't necessary as `libDeps.txt` provides the information we currently need at this stage of the update. It may be needed in the future, but I will likely just push a change to this repo that you can then fetch to get that new information.

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

Note: the instructions below are outdated. All files mentioned below have been suffixed with "Bower" as they won't be the exact commands one will use if using "Spago". So, I renamed the original (e.g. "setupRemote.sh" -> "setupBower.sh"), duplicated the file, prefixedthat file with "Spago" (e.g. "setupRemote.sh" -> "setupSpago.sh") and updated the Spago file to work on Spago. There are a few other assumptions made in this process that will be documented later.

### Setup your environment

1. Create a new directory explicitly for this purpose so that any changes made in this directory will not affect any of your other projects

```bash
mkdir 15
```

2. `git clone` this repo while inside that new folder

```bash
cd 15
git clone https://github.com/JordanMartinez/purescript-ecosystem-update.git master
cd master
```

3. [Install GitHub's new CLI tool: `gh`](https://github.com/cli/cli#installation)

4. Run the `./init.sh` file (globally installs `pulp`, `bower`, and `purescript-psa`; logs you into GitHub via `gh`; downloads the `purs` binary)

```bash
./init.sh
```

5. Modify the `./fork.sh` file
     - Change the `GH_USERNAME` variable to use your GitHub username
     - Change the `PS_TAG` variable to whatever is the latest.

### Contribute

1. Look at [`libDeps.txt`](./libDeps.txt) and see which `purescript` organization repo hasn't been claimed yet. Refer to these links as well:

2. Clone the repo, set up remotes, and automate the boilerplate updates (i.e. `ci.yml`, `package.json`, `bower.json` files) by running the below bash script

```bash
# pwd = master folder
./fork.sh <packageName>
# A folder called `../purescript-<packageName>` will now have been created
```

3. Check whether the library uses any code known to be need of updating

```bash
# pwd = master folder
./usageCheck.sh <packageName>
```

4. Try compiling the code. Use the name of the build tool:

```bash
# pwd = master folder

# If library uses bower...
./bower.sh <packageName>
# This will use Bower to compile the code in `../purescript-<packagename>`

# If library uses Spago...
./spago.sh <packageName>
# This will use Spago to compile the code in `../purescript-<packagename>`
```

6. Create a PR via the `gh` CLI tool

```bash
# pwd = master folder
./pr.sh <packageName>
# 1st question: Choose the `purescript/purescript-<packageName>`
# 2nd question: Choose your repo
# 3rd Question: Choose 'Submit'
```

7. If the library needs any updating, has any other issues or PRs, work on those in a separate PR.

8. Loop

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
# pwd = master folder
cd ../package-sets/
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
