#!/usr/bin/env bash

# $1 = <package name>
#  Example: "now" for `purescript-contrib/purescript-now`

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

# cd into the correct directory
cd ../purescript-$1

# Use gh to create the PR
gh pr create --title "Update to v0.14.0-rc3" --body "Backlinking to purescript-contrib/governance#35"
# 1st question: Choose the `purescript/purescript-<packageName>`
# 2nd question: Choose your repo
# 3rd Question: Choose 'Submit'
