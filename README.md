# purescript-ecosystem-update

This repo stores scripts for forking, updating, and submitting PRs for the `core`, `contrib`, `node`, and `web` PureScript orgainzations' libraries.

## Why

Breaking changes made in libraries are done at the same time as when breaking changes are made in the PureScript compiler. Thus, we have to update all the foundational libraries for the PureScript ecosystem. This entails forking, updating, and submitting and merging many PRs. The scripts in this repo enable a streamlined workflow to make this update process easier.

## How: The intended workflow

### By Example

```sh
# Create a separate folder for containing both the scripts
# and the local copies of the repos
mkdir ps-libs
cd ps-libs

# Clone this repo and enter it
git clone git@github.com:JordanMartinez/purescript-ecosystem-update.git 0.15
cd 0.15

spago build

# Fix any errors produced by the init command
./peu.js init

# Clone all repos locally using `gh` without getting rate-limited
./peu.js cloneAll
# Generate information used by most other commands
./peu.js releaseInfo
# Generate the order in which libraries need to be updated
./peu.js updateOrder

# At this point, one can modify this program to do
# release-specific changes across all repos.
# If a single file is going to be changed, the `getFile`
# command can help see what all the edge cases are immediately.
./peu.js getFile .github/workflows/ci.yml

# Once this program has been updated to do all changes,
# one can start updating them by doing the following:

# For each repo...
  # See what the next library to update is
./peu.js updateOrder
head -n 5 files/order/updated-pkgs
  # Verify that it compiles and will pass CI locally
./peu.js compile prelude
  # Submit a PR via `gh`
./peu.js pr prelude
  # Mark library as updated
echo "prelude" >> files/order/updated-pkgs
  # Loop

# Once all libraries are updated,
# this program will need to be updated once more
# to do release-specific things
./peu.js release

# Once the scripts are tested and work across the repos,
# one can easily open a PR for them
./peu.js release --submit-pr
echo "prelude" >> files/order/released-pkgs
./peu.js release --submit-pr
echo "effect" >> files/order/released-pkgs
# ...

# Once all libraries are releasd and an initial package set
# is released, we can see which libraries are unblocked:
./peu.js spagoOrder
echo "interpolate" >> files/order/released-pkgs
```

### Folder Structure

When setup correctly, the project structure should look like this:
```
ps-libs/
  0.15/
    peu.js
    ...
  lib/
    prelude/
    .../
    node-fs/
    .../
```
