#!/usr/bin/env bash

# $1 = the name of the package (e.g. prelude)

# See https://wizardzines.com/comics/bash-errors/
set -uo pipefail

# The GitHub Owner for a repo you wish to update
BASE_GH_ORG=purescript-node

# Your GitHub username
GH_USERNAME=JordanMartinez

BRANCH_NAME=master

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
git reset --hard upstream/$BRANCH_NAME

# use 'sed' to update all purescript dependencies in bower to `master`
echo "Updating all deps in 'bower.json' to 'master'"
sed --in-place -r 's/\^[0-9]+\.[0-9]+\.[0-9]+/master/g' bower.json
git add bower.json
git commit -m "Update Bower dependencies to master"

# Update package.json file
echo "Updating 'purescript-psa' to 'v0.8.0'"
sed --in-place -r 's/"purescript-psa": .+/"purescript-psa": "^0.8.0",/' package.json
git add package.json
git commit -m "Update purescript-psa to v0.8.0"

echo "Updating 'pulp' to 'v15.0.0'"
sed --in-place -r 's/"pulp": .+/"pulp": "^15.0.0",/' package.json
git add package.json
git commit -m "Update pulp to v15.0.0"

echo "Updating 'eslint' to 'v7.15.0'"
sed --in-place -r 's/"eslint": .+/"eslint": "^7.15.0",/' package.json
git add package.json
git commit -m "Update eslint to v7.5.0"

# Update the `.github/workflows/ci.yml` file to specifically use
# the `v0.14.0-rc3` PS release
echo "Update ci.yml to use purescript v0.14.0-rc3"
sed -i 's/        uses: purescript-contrib\/setup-purescript@main/        uses: purescript-contrib\/setup-purescript@main\n        with:\n          purescript: "0.14.0-rc3"/' .github/workflows/ci.yml
sed -i 's/      - uses: purescript-contrib\/setup-purescript@main/      - uses: purescript-contrib\/setup-purescript@main\n        with:\n          purescript: "0.14.0-rc3"/' .github/workflows/ci.yml
git add .github/workflows/ci.yml
git commit -m "Update to v0.14.0-rc3 purescript"

#### SPAGO ####
# Overwrite `packages.dhall` with the `prepare-0.14` version
#   To understand the below syntax, see
#     https://linuxize.com/post/bash-heredoc/
# cat <<"EOF" > packages.dhall
# let upstream =
#       https://raw.githubusercontent.com/purescript/package-sets/prepare-0.14/src/packages.dhall
#
# in  upstream
# EOF
# git add packages.dhall
# git commit -m "Update packages.dhall to prepare-0.14 bootstrap"

# Update dependency on globals to numbers. Note: this might not be needed
# every time.
# sed -i 's/"globals"/"numbers"/' spago.dhall
# git add spago.dhall
# git commit -m "Update dependency on 'globals' to 'numbers''"


echo ""
echo "Remaining Steps:"
echo "1. Run './compile.sh $1' and use '1' to select the 'master' branch if 'bower' complains"
echo "2. Navigate into 'purescript-$1' via 'pushd ../purescript-$1' (use 'popd' to return to this folder)"
echo "3. Open the below URL to see whether repo has any pre-existing PRs and/or issues"
echo https://github.com/purescript/purescript-$1
