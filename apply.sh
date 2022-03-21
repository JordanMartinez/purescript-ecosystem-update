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
source src/bash/lib/updateDeps.sh "1"

source src/bash/lib/updateEslint.sh "fail"
source src/bash/lib/updateGhActions.sh
source src/bash/lib/updatePackageJson.sh
source src/bash/lib/checkForDeprecated.sh

PATH="$(pwd):$PATH"
export PATH

function pushdOrExit {
  pushd "$1" || (echo "'$1' does not exist. Did you run './forkAll.sh' yet for that directory?" && exit 1)
}

case "${1}" in
0)
  pushdOrExit "../purescript-test/purescript-$2"
  ;;
1)
  pushdOrExit "../purescript/purescript-$2"
  ;;
2)
  pushdOrExit "../purescript-contrib/purescript-$2"
  ;;
3)
  pushdOrExit "../purescript-node/purescript-node-$2"
  ;;
4)
  pushdOrExit "../purescript-web/purescript-web-$2"
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
"trans")
  updateDeps::spagoInstallMissingDeps
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

popd || echo "Could not popd"

echo "Done"
