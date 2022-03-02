#!/usr/bin/env bash

# 1. Creates a local copy of every library in core, contrib, web, and node
# 2. Applies changes across all of them to ensure things remain consistent
#      so that future ecosystem updates are easier to do as a batch script

# See https://wizardzines.com/comics/bash-errors/
set -xuo pipefail

REMOVE_USE_STRICT_SCRIPT=$(cat node-scripts/remove-use-strict.js)

pushd ../purescript-test/purescript-prelude

# Transform to ES 6
lebab --replace src --transform commonjs
lebab --replace test --transform commonjs
# Replace 'export var' with 'export const'
find src -type f -wholename "**/*.js" -print0 | xargs -0 sed -i 's/export var/export const/g'
find test -type f -wholename "**/*.js" -print0 | xargs -0 sed -i 's/export var/export const/g'
# Remove `"use strict";\n\n`
find src -type f -wholename "**/*.js" -print0 -exec node --input-type module -e "$REMOVE_USE_STRICT_SCRIPT" -- {} \;
find test -type f -wholename "**/*.js" -print0 -exec node --input-type module -e "$REMOVE_USE_STRICT_SCRIPT" -- {} \;
git add src test
git commit -m "Migrated FFI to ES modules via 'lebab'"

popd
