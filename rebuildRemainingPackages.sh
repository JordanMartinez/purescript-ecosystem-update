#!/usr/bin/env bash

# Overwrites `libDeps.txt` to show the packages that can be updated now
# provided you have Node and spago installed

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

DEPS=./finished-dependencies.txt

# Overwrite DEPS and add proxy and generics-rep to file
echo "" > $DEPS
echo "proxy" >> $DEPS
echo "generics-rep" >> $DEPS

# overwrite the `packages-0.14.dhall` file with hash-less copy
# so that any new updates are automatically pulled in
cp packages-0.14-no-hash.dhall packages-0.14.dhall

# Now use that package set to compute those that have already been updated
spago -x spago-0.14.dhall ls packages | cut -d ' ' -f 1 >> $DEPS

# Now calculate the ones that are unblocked
node ./package-query.js --input ./packageSet.json --force genLibDeps --output ./libDeps.txt --finished-dependencies-file $DEPS
