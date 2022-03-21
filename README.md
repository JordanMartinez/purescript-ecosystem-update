# purescript-ecosystem-update

This repo stores scripts for forking, updating, and submitting PRs for the `core`, `contrib`, `node`, and `web` PureScript orgainzations' libraries.

## Why

Breaking changes made in libraries are done at the same time as when breaking changes are made in the PureScript compiler. Thus, we have to update all the foundational libraries for the PureScript ecosystem. This entails forking, updating, and submitting and merging many PRs. The scripts in this repo enable a streamlined workflow to make this update process easier.

## How: The intended workflow

```sh
# Create a separate folder for containing both the scripts
# and the local copies of the repos under their org-specific folder
mkdir ps-libs
cd ps-libs

# Clone this repo and enter it
git clone git@github.com:JordanMartinez/purescript-ecosystem-update.git 0.15
cd 0.15

./init.sh
./forkall.sh


# For each repo, the workflow looks like...
./compile.sh 1 prelude
# If any fixes need to be done separately / after the fact
# ./apply.sh 1 prelude ffi
./pr.sh 1 prelude
     # Q1: Choose the actual repo
     # Q2: Choose your fork
     # Q3: Choose 'Submit'

# Once the PR is merged...
echo "prelude" >> finished-dependencies.txt
./mkLibDeps.sh
# Do the next repo until finished
```

[./init.sh](./init.sh) sets up all the tools you need to make the scripts work.

[./forkAll.sh](./forkAll.sh) forks all repos to your account, clones them to a local folder, and applies all updates to each repo in a consistent manner.

[./compile.sh](./compile.sh) compiles one repo and verifies that it builds, its tests pass, and any linting is checked.

[./pr.sh](./pr.sh) opens a PR using the [GitHub CLI tool, gh](https://github.com/cli/cli) with a consistent title, message body, labels, and backlinking to the tracking issue.

[./mkLibDeps.sh](./mkLibDeps.sh) regenerates the `libDeps.txt` file, so you can know which libraries have been unblocked now that their dependencies have been updated.

[./apply.sh](./apply.sh) applies a single change to one repo. It's used to apply any one-time fixes if `forkAll.sh` missed it previously due to a bad script.

When setup correctly, the project structure should look like this:
```
ps-libs/
  0.15/
    init.sh
    ...
  purescript/
  purescript-contrib/
  purescript-node/
  purescript-web/
```
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
