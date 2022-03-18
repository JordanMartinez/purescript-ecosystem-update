#!/usr/bin/env bash

# Prints all usages of things that are deprecated or should be updated

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

function checkForDeprecated::main {
  echo "=== src ==="
  grep -r --include "*.purs" eprecate src/
  grep -r --include "*.purs" roxy src/
  grep -r --include "*.purs" "import Math" src/

  echo "=== test ==="
  grep -r --include "*.purs" eprecate test/
  grep -r --include "*.purs" roxy test/
  grep -r --include "*.purs" "import Math" test/
}
