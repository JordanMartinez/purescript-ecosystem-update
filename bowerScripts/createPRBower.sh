#!/usr/bin/env bash

# $1 = the name of the package (e.g. prelude)

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

# cd into the correct directory
cd ../purescript-$1

# Use gh to create the PR
gh pr create --title "Update to v0.14.0-rc3" --body "Backlinking to purescript/purescript#3942"
# 1st question: Choose the `purescript/purescript-<packageName>`
# 2nd question: Choose your repo
# 3rd Question: Choose 'Submit'
