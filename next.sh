#!/usr/bin/env bash

# Prints the list of packages that can be updated
# since all of their dependencies have been updated.

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

ROOT_DIR=$(dirname "$(readlink -f "$0")")

DEPS_CONTENT="$(cat "$ROOT_DIR/files/package-graph/libDeps.txt" | grep '^0')"

case "${1}" in
1)
  echo "$DEPS_CONTENT" | grep '/purescript/'
  ;;
2)
  echo "$DEPS_CONTENT" | grep '/purescript-contrib/'
  ;;
3)
  echo "$DEPS_CONTENT" | grep '/purescript-node/'
  ;;
4)
  echo "$DEPS_CONTENT" | grep '/purescript-web/'
  ;;
*)
  echo "$DEPS_CONTENT"
  ;;
esac
