#!/usr/bin/env bash

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

# $1 = <package name>
#  Example: "now" for `purescript-contrib/purescript-now`

# This file is based on the `.github/workflows/ci.yml` file in the
# `purescript-contrib/purescript-now` repo
export PATH="$(pwd):$PATH"
cd ../purescript-$1
npm install
npm run build
npm run test
