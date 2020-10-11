#!/usr/bin/env bash

# Produces the `libDeps.txt` file
node ./package-query.js --input ./packageSet.json --force genLibDeps --output ./libDeps.txt
