#!/usr/bin/env bash

# $1 = <package name>
#  Example: "now" for `purescript-contrib/purescript-now`

# Prints all usages of things that are deprecated or should be updated

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

cd ../purescript-$1

grep -r --include "*.purs" Proxy src/
grep -r --include "*.purs" Global src/
grep -r --include "*.purs" unsafeCoerce src/
grep -r --include "*.purs" fromRight src/
grep -r --include "*.purs" fromLeft src/
grep -r --include "*.purs" Proxy test/
grep -r --include "*.purs" Global test/
grep -r --include "*.purs" unsafeCoerce test/
grep -r --include "*.purs" fromRight test/
grep -r --include "*.purs" fromLeft test/
