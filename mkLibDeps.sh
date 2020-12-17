#!/usr/bin/env bash

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

# Whenever a package gets updated
# add the package name to the `finished-dependencies.txt` file
# on a newline and then rerun this script

# Produces the `libDeps.txt` file
node ./package-query.js --input ./packageSet.json --force genLibDeps --output ./libDeps.txt --finished-dependencies-file ./finished-dependencies.txt

# node ./package-query.js --input ./packageSet.json --force genLibDeps --output ./originalPackagesList.txt

# Sleep for 0.1 seconds. otherwise only one file will be outputted
# sleep 0.1
# cat ./libDeps.txt | grep '/purescript/' > ./libDeps-purescript.txt
# cat ./libDeps.txt | grep '/purescript-contrib/' > ./libDeps-purescript-contrib.txt
# cat ./libDeps.txt | grep '/purescript-web/' > ./libDeps-purescript-web.txt
# cat ./libDeps.txt | grep '/purescript-node/' > ./libDeps-purescript-node.txt
