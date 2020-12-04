#!/usr/bin/env bash

# Prints all places where a kind-specific Proxy is used

cd ../purescript-$1

grep -r --include "*.purs" Proxy src/
grep -r --include "*.purs" Global src/
grep -r --include "*.purs" unsafeCoerce src/
grep -r --include "*.purs" Proxy test/
grep -r --include "*.purs" Global test/
grep -r --include "*.purs" unsafeCoerce test/
