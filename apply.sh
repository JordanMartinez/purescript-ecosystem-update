#!/usr/bin/env bash

# 1. Compiles code in project using locally-downloaded `purs` binary
# 2. Lints the javascript code

# Expected usage
#     ./apply.sh <org-num> <package-name> <fix-name>
# ... where <org-num> is...
#   0 - purescript-test
#   1 - purescript
#   2 - purescript-contrib
#   3 - purescript-node
#   4 - purescript-web
#
# ... <package-name> is the repo's name excluding `purescript-`
#                    or `purescript-node-`/`purescript-web-`
#                    if <org-num> is 3 or 4.
#
# ... <fix-name> is the actions listed at the bottom of this script.

ROOT_DIR=$(dirname "$(readlink -f "$0")")

source "$ROOT_DIR/src/bash/lib/migrateFfiToEs6.sh"
source "$ROOT_DIR/src/bash/lib/updateDeps.sh" "1"
source "$ROOT_DIR/src/bash/lib/updateEslint.sh" "fail"
source "$ROOT_DIR/src/bash/lib/updateGhActions.sh"
source "$ROOT_DIR/src/bash/lib/updatePackageJson.sh"
source "$ROOT_DIR/src/bash/lib/checkForDeprecated.sh"

PATH="$(pwd):$PATH"
export PATH

function pushdOrExit {
  pushd "$1" || (echo "'$1' does not exist. Did you run './forkAll.sh' yet for that directory?" && exit 1)
}

case "${1}" in
0)
  pushdOrExit "$ROOT_DIR/../purescript-test/purescript-$2"
  ;;
1)
  pushdOrExit "$ROOT_DIR/../purescript/purescript-$2"
  ;;
2)
  pushdOrExit "$ROOT_DIR/../purescript-contrib/purescript-$2"
  ;;
3)
  pushdOrExit "$ROOT_DIR/../purescript-node/purescript-$2"
  ;;
4)
  pushdOrExit "$ROOT_DIR/../purescript-web/purescript-$2"
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
  if [ "$1" == "2" ]; then
    updateGhActions::main "purescript-contrib"
  else
    updateGhActions::main "purescript-all-others"
  fi
  ;;
"clear-bower")
  if [ -f "bower.json" ]; then
    rm -rf bower_components/ output/
    bower cache clean
  else
    echo "No bower.json file found"
  fi
  ;;
"bi-dev")
  bower install -D "purescript-$4"
  git add bower.json
  git commit -m "Installed bower dev dependency: purescript-$4"
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
