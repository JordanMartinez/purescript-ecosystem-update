#!/usr/bin/env bash

# Prints all places where a kind-specific Proxy is used

cd ../purescript-$1

grep -r --include "*.purs" Proxy src/
grep -r --include "*.purs" Proxy test/
