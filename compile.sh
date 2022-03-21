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

source "$ROOT_DIR/src/bash/lib/updateDeps.sh" "1"

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

function pushdOrExit {
  pushd "$1" || (echo "'$1' does not exist. Did you run './forkAll.sh' yet for that directory?" && exit 1)
}

function popdOrExit {
  popd || (echo "popd failed" && exit 1)
}

case "${1}" in
0)
  pushdOrExit "$ROOT_DIR/../purescript-test/purescript-$2"
  compile::other
  popdOrExit
  ;;
1)
  pushdOrExit "$ROOT_DIR/../purescript/purescript-$2"
  compile::core
  popdOrExit
  ;;
2)
  pushdOrExit "$ROOT_DIR/../purescript-contrib/purescript-$2"
  compile::other
  popdOrExit
  ;;
3)
  pushdOrExit "$ROOT_DIR/../purescript-node/purescript-node-$2"
  compile::other
  popdOrExit
  ;;
4)
  pushdOrExit "$ROOT_DIR/../purescript-web/purescript-web-$2"
  compile::other
  popdOrExit
  ;;
esac

echo "Done"
