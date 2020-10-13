#!/usr/bin/env bash

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

# Produces the `libDeps.txt` file
node ./package-query.js --input ./packageSet.json --force genLibDeps --output ./libDeps.txt
