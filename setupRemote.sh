#!/usr/bin/env bash

# $1 = the name of the package (e.g. prelude)

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

# The GitHub Owner for a repo you wish to update
BASE_GH_ORG=purescript

# Your GitHub username
GH_USERNAME=JordanMartinez

# go up one level
cd ..

# Fork the repo using GitHub's CLI tool, but don't `git clone` it here
gh repo fork $BASE_GH_ORG/purescript-$1 --clone=true --remote=true

cd purescript-$1

# Checkout a new branch based on the current `master` branch
git checkout -b updateTo14

git reset --hard upstream/master

# use 'sed' to update dependencies to `master`
echo "Updating all deps in `bower.json` to `master`"
sed --in-place -r 's/\^[0-9]+\.[0-9]+\.[0-9]+/master/g' bower.json

# use `sed` to update psa to v0.8.0
echo "Updating `purescript-psa` to `v0.8.0`"
sed --in-place 's/"purescript-psa": "^0.6.0"/"purescript-psa": "^0.8.0"/' package.json

git add bower.json package.json
git commit -m "Update dependencies to master; psa to v0.8.0"

echo ""
echo "Open the below URL to see whether repo has any pre-existing PRs and/or issues"
echo https://github.com/purescript/purescript-$1
