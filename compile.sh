#!/usr/bin/env bash

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

export PATH="$(pwd):$PATH"
cd ../purescript-$1
npm install
bower install --production
npm run -s build
bower install
npm -s test
