#!/usr/bin/env bash

# $1 = the name of the package (e.g. prelude)

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

# The GitHub Owner for a repo you wish to update
BASE_GH_ORG=purescript

# Your GitHub username
GH_USERNAME=JordanMartinez

# The current release candidate
PS_TAG=v0.14.0-rc3

# go up one level
cd ..

# Fork the repo using GitHub's CLI tool and `git clone` it.
gh repo fork $BASE_GH_ORG/purescript-$1 --clone=true --remote=true

# change into that just cloned repo
cd purescript-$1

# Checkout a new branch based on the current `master` branch
git checkout -b updateTo14

# Ensure we're at the real repo's current `master` branch in case
# we've done work on this repo before in our own fork
git reset --hard upstream/master

# use 'sed' to update all purescript dependencies in bower to `master`
echo "Updating all deps in 'bower.json' to 'master'"
sed --in-place -r 's/\^[0-9]+\.[0-9]+\.[0-9]+/master/g' bower.json

# use `sed` to update purescript-psa to v0.8.0
echo "Updating 'purescript-psa' to 'v0.8.0'"
sed --in-place -r 's/"purescript-psa": .+/"purescript-psa": "^0.8.0"/' package.json

# use `sed` to update TAG in .travis.yml to latest release candidate
# by commenting out old one
# and inserting new one in front of the next command (i.e. `curl`)
echo "Updating '.travis.yml' TAG to $PS_TAG"
sed --in-place 's/- TAG/# - TAG/' .travis.yml

## See https://stackoverflow.com/a/584926
sed --in-place 's/- curl/- TAG='"$PS_TAG"'\n  - curl/' .travis.yml

# Add these files and commit them to our branch
git add bower.json package.json .travis.yml
git commit -m "Update TAG to $PS_TAG; dependencies to master; psa to v0.8.0"

echo ""
echo "Remaining Steps:"
echo "1. Run './compile.sh $1' and use '1' to select the 'master' branch if 'bower' complains"
echo "2. Navigate into 'purescript-$1' via 'pushd ../purescript-$1' (use 'popd' to return to this folder)"
echo "3. Open the below URL to see whether repo has any pre-existing PRs and/or issues"
echo https://github.com/purescript/purescript-$1
