#!/usr/bin/env bash

# 1. Compiles code in project using locally-downloaded `purs` binary
# 2. Lints the javascript code

# Expected usage
#     ./pr.sh 1 prelude
#     ./pr.sh 2 aff
#     ./pr.sh 3 fs
#     ./pr.sh 4 xhr
# ... where ...
#   1 - purescript
#   2 - purescript-contrib
#   3 - purescript-node
#   4 - purescript-web

PATH="$(pwd):$PATH"
export PATH

JQ_SCRIPT_LOCATION=jq-script--update-bower-json.txt
source src/bash/lib/updateDeps.sh "$JQ_SCRIPT_LOCATION" "1"
JQ_SCRIPT_UPDATE_BOWER_JSON=$(cat "$JQ_SCRIPT_LOCATION")

case "${1}" in
0)
  pushd ../purescript-test/purescript-$2
  # If the package set has changed since the last time we ran
  # it may have a different hash.
  # So, let's overwrite it to remove that hash.
  updateDeps::bower
  updateDeps::spago

  spago build -u "--strict"
  spago test
  if [ -d "src" ]; then
    eslint src
  fi
  if [ -d "test" ]; then
    eslint test
  fi
  popd
  ;;
1)
  pushd ../purescript/purescript-$2
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
  popd
  ;;
2)
  pushd ../purescript-contrib/purescript-$2
  # If the package set has changed since the last time we ran
  # it may have a different hash.
  # So, let's overwrite it to remove that hash.
  updateDeps::spago

  spago build -u "--strict"
  spago test
  if [ -d "src" ]; then
    eslint src
  fi
  if [ -d "test" ]; then
    eslint test
  fi
  popd
  ;;
3)
  pushd ../purescript-node/purescript-node-$2
  # If the package set has changed since the last time we ran
  # it may have a different hash.
  # So, let's overwrite it to remove that hash.
  updateDeps::spago
  spago build -u "--strict"
  spago test
  if [ -d "src" ]; then
    eslint src
  fi
  if [ -d "test" ]; then
    eslint test
  fi
  popd
  ;;
4)
  pushd ../purescript-web/purescript-web-$2
  # If the package set has changed since the last time we ran
  # it may have a different hash.
  # So, let's overwrite it to remove that hash.
  updateDeps::spago
  spago build -u "--strict"
  spago test
  if [ -d "src" ]; then
    eslint src
  fi
  if [ -d "test" ]; then
    eslint test
  fi
  popd
  ;;
esac

echo "Done"
