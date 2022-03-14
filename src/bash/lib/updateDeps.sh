#!/usr/bin/env bash

ROOT_DIR=$(dirname "$(readlink -f "$0")")

JQ_SCRIPT_LOCATION=$1
DISABLE_SCRIPT_UPDATE=$2

PACKAGES_DHALL_CONTENT="let upstream =
      https://raw.githubusercontent.com/purescript/package-sets/prepare-0.15/src/packages.dhall

in  upstream
"

REPO_URL_FILE_PS="$ROOT_DIR/repos/purescript.txt"
REPO_URL_FILE_PS_CONTRIB="$ROOT_DIR/repos/purescript-contrib.txt"
REPO_URL_FILE_PS_NODE="$ROOT_DIR/repos/purescript-web.txt"
REPO_URL_FILE_PS_WEB="$ROOT_DIR/repos/purescript-node.txt"


# Determines whether to use 'master' or 'main'
# as branch name for PureScript dependency in `bower.json` file
function updateDependencies::recalcBowerRepoBranches {
  local DEPS_FILE, DEV_DEPS_FILE
  DEPS_FILE=bowerDeps-deps.txt
  DEV_DEPS_FILE=bowerDeps-dev-deps.tx

  function rmFile {
    rm "$1" || echo "$1 doesn't exist; skipping."
  }

  # jq '
  #   if has("dependencies" then .dependencies |= (
  #     if has("purescript-repo") then (."purescript-repo" |= "branchName") else . end |
  #     if has("purescript-repo2") then (."purescript-repo2" |= "branchName") else . end |
  #     .
  #   ) else . end |
  #   if has("devDependencies") then .devDependencies |= (
  #     if has("purescript-repo") then (."purescript-repo" |= "branchName") else . end |
  #     if has("purescript-repo2") then (."purescript-repo2" |= "branchName") else . end |
  #     .
  #   ) else . end
  #   '
  #
  # Intended to be called via `cat bower.json | jq "$FILE_CONTENTS"`
  function printBranch {
    local FILE, BRANCH
    FILE=$(cat "$1")
    BRANCH="$2"

    echo "if has(\"dependencies\") then .dependencies |= (" > "$JQ_SCRIPT_LOCATION"

    for line in $FILE; do
      REPO_URL=$(echo "$line" | sed 's/git@github.com://g; s/.git$//g')
      # REPO_ORG=$(echo "$REPO_URL" | cut -d '/' -f 1)
      REPO_PROJ=$(echo "$REPO_URL" | cut -d '/' -f 2)
      echo "  if has(\"$REPO_PROJ\") then .\"$REPO_PROJ\" |= \"$BRANCH\" else . end |" >> "$DEPS_FILE"
      echo "  if has(\"$REPO_PROJ\") then .\"$REPO_PROJ\" |= \"$BRANCH\" else . end |" >> "$DEV_DEPS_FILE"
    done
    {
      echo "if has(\"dependencies\") then .dependencies |= ("
      cat "$DEPS_FILE"
      echo "  ."
      echo ") else . end | "
      echo " if has (\"devDependencies\") then .devDependencies |= ("
      cat "$DEV_DEPS_FILE"
      echo "  ."
      echo ") else . end"
    } > "$JQ_SCRIPT_LOCATION"
  }

  rmFile "$DEPS_FILE"
  rmFile "$DEV_DEPS_FILE"

  printBranch "$REPO_URL_FILE_PS" "master"
  printBranch "$REPO_URL_FILE_PS_CONTRIB" "main"
  printBranch "$REPO_URL_FILE_PS_NODE" "master"
  printBranch "$REPO_URL_FILE_PS_WEB" "master"

  rmFile "$DEPS_FILE"
  rmFile "$DEV_DEPS_FILE"
}

# Updates the dependencies in bower or spago projects
# to latest `master`/`main`
function updateDependencies::main {
  local BUILD_TOOL
  BUILD_TOOL="$1"
  case "$BUILD_TOOL" in
  "bower") forkAll::updateBower
    ;;
  "spago") forkAll::updateSpago
    ;;
  *) echo "Unknown build tool option: $3" ;;
  esac
}

# Uses 'jq' to update all purescript `dependencies` and
# `devDependencies` (if exists) in bower.json to `master`
# or `main`, the default branch.
function updateDeps::updateBower {
  echo "Updating all deps in 'bower.json' to 'master' or 'main'"
  local TMP_FILE=bower.json.new
  jq "$JQ_SCRIPT_UPDATE_BOWER_JSON" bower.json > "$TMP_FILE" && mv "$TMP_FILE" bower.json
  git add bower.json
  git commit -m "Update Bower dependencies to master or main"
}

# Overwrite `packages.dhall` with the `prepare-0.15` version
# of package set
function updateDeps::updateSpago {
  echo "$PACKAGES_DHALL_CONTENT" > packages.dhall
  git add packages.dhall
  git commit -m "Update packages.dhall to 'prepare-0.15' package set"
}

case "${DISABLE_SCRIPT_UPDATE}" in
  "1")
    echo "Not updating JQ script for bower deps that is stored in file: $1"
    ;;
  *)
    echo "Updating JQ script for bower deps. Storing content in file: $1"
    rmFile "$JQ_SCRIPT_LOCATION" || echo "$JQ_SCRIPT_LOCATION does not exist; skipping its deletion."
    updateDependencies::recalcBowerRepoBranches
    ;;
esac