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

export PATH="$(pwd):$PATH"

case "${1}" in
1)
  pushd ../purescript/purescript-$2
  # This is based on what was the `.travis.yml` file in the `purescript-prelude` repo
  npm install
  bower install --production
  npm run -s build
  bower install
  npm run -s test --if-present
  eslint src test
  popd
  ;;
2)
  pushd ../purescript-contrib/purescript-$2
  spago build -u "--strict"
  spago test
  eslint src test
  popd
  ;;
3)
  pushd ../purescript-node/purescript-node-$2
  spago build -u "--strict"
  spago test
  eslint src test
  popd
  ;;
4)
  pushd ../purescript-web/purescript-web-$2
  spago build -u "--strict"
  spago test
  eslint src test
  popd
  ;;
esac

echo "Done"
