#!/usr/bin/env bash

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

ROOT_DIR=$(dirname "$(readlink -f "$0")")

# Whenever a package gets updated
# add the package name to the `finished-dependencies.txt` file
# on a newline and then rerun this script

# Produces the `libDeps.txt` file
node "$ROOT_DIR/src/node/lib/package-graph.js" --input ./packages-0.14.7.json --force lib-deps --output ./libDeps.txt --deps ./finished-dependencies.txt
