# Workflow

1. Login to GitHub using the GitHub CLI tool

```bash
gh auth login
```

2. (Optional, but recommended) Change the default git protocol from `https` to `ssh`

```bash
gh config set git_protocol=ssh
```

3. Look at [`libDeps.txt`](./libDeps.txt) to see what to work on next. See also the [purescript repo's "update ecosystme to v0.14.0" issue](https://github.com/purescript/purescript/issues/3942)

4. Modify the `./setupRemote.sh` file's `GH_USERNAME` variable to use your GitHub username

5. Install the package and its dependencies and set up its git remotes

```bash
# Generate the corresponding `<packageName>.dhall` file
./genSpagoFile.sh <packageName>

# Install and compile just that package and its dependencies
./compile.sh <packageName>

# Setup a remote to your fork of the repo.
#   If package is stored at `.spago/packageName/version`
#   run `ls .spago/packageName` to see what the version is
./setupRemote.sh <packageName> <versionName>
```

Using `prelude` as an example, we would run...
```bash
# Generate the corresponding `<packageName>.dhall` file
./genSpagoFile.sh prelude

# Install and compile just that package and its dependencies
./compile.sh prelude

# outputs master
ls .spago/prelude

# Setup a remote to your fork of the repo.
./setupRemote.sh prelude master
```

6. Do your updates locally

```bash
cd .spago/packageName/versionName
#   make changes via your editor

# verify that the package still compiles
./compile.sh <packageName>

# if you need to reinstall / update a dependency
./reinstall <dependencyName> <packageName>
```

For example
```bash
cd .spago/functions/v4.0.0
#   make changes via your editor
# verify that the package still compiles
./compile.sh functions

# if you need to reinstall / update a dependency
# You can do this. Note: it will delete any prior work you had
# done previously
./reinstall prelude functions
```

7. Create a PR

```bash
git push -u origin updateTo14

# Create a PR on GitHub
```
