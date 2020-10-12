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
