#!/usr/bin/env bash

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

# This file is based on the `.travis.yml` file in the `purescript-prelude` repo
export PATH="$(pwd):$PATH"
cd ../purescript-$1
npm install
bower install --production
npm run -s build
bower install
npm -s test
