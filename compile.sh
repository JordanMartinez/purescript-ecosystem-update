#!/usr/bin/env bash

# 1. Compiles code in project using locally-downloaded `purs` binary
# 2. Lints the javascript code

# Expected usage
#     ./pr.sh 1 prelude
#     ./pr.sh 2 aff
#     ./pr.sh 3 fs
#     ./pr.sh 4 xhr
# ... where ...
#   0 - purescript-test
#   1 - purescript
#   2 - purescript-contrib
#   3 - purescript-node
#   4 - purescript-web

PATH="$(pwd):$PATH"
export PATH

ROOT_DIR=$(dirname "$(readlink -f "$0")")

JQ_SCRIPT_LOCATION="$ROOT_DIR/src/jq/update-bower-json.txt"
source src/bash/lib/updateDeps.sh "$JQ_SCRIPT_LOCATION" "1"
JQ_SCRIPT_UPDATE_BOWER_JSON=$(cat "$JQ_SCRIPT_LOCATION")

function compile::core {
  # This is based on what was the `.travis.yml` file in the `purescript-prelude` repo
  npm install
  bower install --production
  npm run -s build
  bower install
  npm run -s test --if-present
  if [ -d "src" ]; then
    eslint src
  fi
  if [ -d "test" ]; then
    eslint test
  fi
}

function compile::other {
  npm install
  updateDeps::main
  if [ -f "bower.json" ]; then
    bower install
    pulp build -- "--strict"
    pulp test -- "--strict"
  fi
  if [ -f "spago.dhall" ]; then
    spago build -u "--strict"
    spago test
  fi
  if [ -d "src" ]; then
    eslint src
  fi
  if [ -d "test" ]; then
    eslint test
  fi
}

case "${1}" in
0)
  pushd ../purescript-test/purescript-$2
  compile::other
  popd
  ;;
1)
  pushd ../purescript/purescript-$2
  compile::core
  popd
  ;;
2)
  pushd ../purescript-contrib/purescript-$2
  compile::other
  popd
  ;;
3)
  pushd ../purescript-node/purescript-node-$2
  compile::other
  popd
  ;;
4)
  pushd ../purescript-web/purescript-web-$2
  compile::other
  popd
  ;;
esac

echo "Done"
