#!/usr/bin/env bash

# Prints the list of packages that can be updated
# since all of their dependencies have been updated.

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

case "${1}" in
1)
  cat ./libDeps.txt | grep '^0' | grep '/purescript/'
  ;;
2)
  cat ./libDeps.txt | grep '^0' | grep '/purescript-contrib/'
  ;;
3)
  cat ./libDeps.txt | grep '^0' | grep '/purescript-node/'
  ;;
4)
  cat ./libDeps.txt | grep '^0' | grep '/purescript-web/'
  ;;
*)
  cat ./libDeps.txt | grep '^0'
  ;;
esac
