#!/usr/bin/env bash

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

# Whenever a package gets updated
# add the package name to the `finished-dependencies.txt` file
# on a newline and then rerun this script

# Produces the `libDeps.txt` file
node ./package-query.js --input ./packageSet.json --force genLibDeps --output ./libDeps.txt --finished-dependencies-file ./finished-dependencies.txt

# cat ./libDeps.txt | grep '/purescript/' > ./libDeps-purescript.txt
cat ./libDeps.txt | grep '/purescript-contrib/' > ./libDeps-purescript-contrib.txt
