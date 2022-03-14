#!/usr/bin/env bash

# 1. Compiles code in project using locally-downloaded `purs` binary
# 2. Lints the javascript code

# Expected usage
#     ./apply.sh 1 prelude
#     ./apply.sh 2 aff
#     ./apply.sh 3 fs
#     ./apply.sh 4 xhr
# ... where ...
#   1 - purescript
#   2 - purescript-contrib
#   3 - purescript-node
#   4 - purescript-web

ROOT_DIR=$(dirname "$(readlink -f "$0")")

source src/bash/lib/migrateFfiToEs6.sh

# Regenerate JQ script for updating bower.json file
# and store results in JQ_SCRIPT_UPDATE_BOWER_JSON
JQ_SCRIPT_LOCATION=jq-script--update-bower-json.txt
source src/bash/lib/updateDeps.sh "$JQ_SCRIPT_LOCATION" "1"
JQ_SCRIPT_UPDATE_BOWER_JSON=$(cat "$JQ_SCRIPT_LOCATION")

source src/bash/lib/updateEslint.sh
source src/bash/lib/updateGhActions.sh
source src/bash/lib/updatePackageJson.sh

REMOVE_USE_STRICT_SCRIPT=$(cat $ROOT_DIR/src/node/lib/remove-use-strict.js)

export PATH="$(pwd):$PATH"
BUILD_TOOL=""

case "${1}" in
1)
  pushd ../purescript/purescript-$2
  BUILD_TOOL="bower"
  ;;
2)
  pushd ../purescript-contrib/purescript-$2
  BUILD_TOOL="spago"
  ;;
3)
  pushd ../purescript-node/purescript-node-$2
  BUILD_TOOL="bower"
  ;;
4)
  pushd ../purescript-web/purescript-web-$2
  BUILD_TOOL="bower"
  ;;
*)
  echo "$1 is not a valid option."
  exit 1
  ;;
esac

case "$3" in
"deps")
  updateDeps::main "$BUILD_TOOL"
  ;;
"packageJson")
  updatePackageJson::main
  ;;
"eslint")
  updateEslint::main
  ;;
"ffi")
  migrateFfiToEs6::main
  ;;
"ci")
  updateGhActions::main
  ;;
*)
  echo "$3 is not a valid forkAll function name"
  exit 1
esac

popd

echo "Done"
