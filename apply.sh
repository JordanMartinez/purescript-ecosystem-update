#!/usr/bin/env bash

# 1. Compiles code in project using locally-downloaded `purs` binary
# 2. Lints the javascript code

# Expected usage
#     ./apply.sh 1 prelude
#     ./apply.sh 2 aff
#     ./apply.sh 3 fs
#     ./apply.sh 4 xhr
# ... where ...
#   0 - purescript-test
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

source src/bash/lib/updateEslint.sh "fail"
source src/bash/lib/updateGhActions.sh
source src/bash/lib/updatePackageJson.sh
source src/bash/lib/checkForDeprecated.sh

REMOVE_USE_STRICT_SCRIPT=$(cat "$ROOT_DIR/src/node/lib/remove-use-strict.js")

PATH="$(pwd):$PATH"
export PATH
BUILD_TOOL=""

case "${1}" in
0)
  pushd ../purescript-test/purescript-$2
  ;;
1)
  pushd ../purescript/purescript-$2
  ;;
2)
  pushd ../purescript-contrib/purescript-$2
  ;;
3)
  pushd ../purescript-node/purescript-node-$2
  ;;
4)
  pushd ../purescript-web/purescript-web-$2
  ;;
*)
  echo "$1 is not a valid option."
  exit 1
  ;;
esac

case "$3" in
"deps")
  updateDeps::main
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
"clear-bower")
  if [ -f "bower.json" ]; then
    rm -rf bower_components/ output/
    bower cache clean
  else
    echo "No bower.json file found"
  fi
  ;;
"check")
  checkForDeprecated::main
  ;;
*)
  echo "$3 is not a valid option"
  exit 1
esac

popd

echo "Done"
