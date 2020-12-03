#!/usr/bin/env bash

# $1 = <BASE_GH_USERNAME>/<GH_REPO>"
#   Example: "purescript-contrib/purescript-now"

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

BASE_GH_USERNAME=$(echo $1 | cut -d'/' -f1)
GH_REPO=$(echo $1 | cut -d'/' -f2)

# Your GitHub username
YOUR_GH_USERNAME=JordanMartinez

# PureScript-Contrib libraries use `main` as their default branch
CHECKED_OUT_BRANCH=main

# The current release candidate
PS_TAG=v0.14.0-rc3

# go up one level
cd ..

# Fork the repo using GitHub's CLI tool and `git clone` it.
gh repo fork $BASE_GH_USERNAME/$GH_REPO --clone=true --remote=true

# change into that just cloned repo
cd $GH_REPO

# Checkout a new branch based on the current `main` branch
# using the upstream repo in case we've done work on this repo before
# in our own fork
git checkout -b updateTo14 upstream/$CHECKED_OUT_BRANCH

# Overwrite `packages.dhall` with the `prepare-0.14` version
#   To understand the below syntax, see
#     https://linuxize.com/post/bash-heredoc/
cat <<"EOF" > packages.dhall
let upstream =
      https://raw.githubusercontent.com/purescript/package-sets/prepare-0.14/src/packages.dhall sha256:f591635bcfb73053bcb6de2ecbf2896489fa5b580563396f52a1051ede439849

in  upstream
EOF

# Add these files and commit them to our branch
git add packages.dhall
git commit -m "Update packages.dhall to prepare-0.14 bootstrap"

# Update the `.github/workflows/ci.yml` file to specifically use
# the `v0.14.0-rc3` PS release
sed -i 's/        uses: purescript-contrib\/setup-purescript@main/        uses: purescript-contrib\/setup-purescript@main\n        with:\n          purescript: "0.14.0-rc3"/' .github/workflows/ci.yml

git add .github/workflows/ci.yml
git commit -m "Update CI to use v0.14.0-rc3 PS release"

# Update dependency on globals to numbers. Note: this might not be needed
# every time.
sed -i 's/"globals"/"numbers"/' spago.dhall
git add spago.dhall
git commit -m "Update dependency on 'globals' to 'numbers''"

echo <<EOF
Remaining Steps:
1. Run './compileSpago.sh $GH_REPO'
2. Navigate into 'purescript-$GH_REPO' via 'pushd ../purescript-$GH_REPO' (use 'popd' to return to this folder)
3. Open the below URL to see whether repo has any pre-existing PRs and/or issues
     https://github.com/purescript-contrib/purescript-$GH_REPO
4. Do all changes needed (breaking, fix warnings, add kind signatures, etc.)
5. Run './createPRSpago.sh $GH_REPO'
EOF
