#!/usr/bin/env bash

ROOT_DIR=$(dirname "$(readlink -f "$0")")

DISABLE_SCRIPT_UPDATE=$1

JQ_SCRIPT_LOCATION="$ROOT_DIR/src/jq/update-bower-json.txt"

PACKAGES_DHALL_CONTENT="let upstream =
      https://raw.githubusercontent.com/purescript/package-sets/prepare-0.15/src/packages.dhall

in  upstream"

REPO_URL_FILE_PS="$ROOT_DIR/files/repos/purescript.txt"
REPO_URL_FILE_PS_CONTRIB="$ROOT_DIR/files/repos/purescript-contrib.txt"
REPO_URL_FILE_PS_NODE="$ROOT_DIR/files/repos/purescript-web.txt"
REPO_URL_FILE_PS_WEB="$ROOT_DIR/files/repos/purescript-node.txt"


# Determines whether to use 'master' or 'main'
# as branch name for PureScript dependency in `bower.json` file
function updateDependencies::recalcBowerRepoBranches {
  local DEPS_FILE DEV_DEPS_FILE
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
    local FILE BRANCH
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
      # Sigh... fix filterable
      echo "  if has(\"purescript-filterable\") then .\"purescript-filterable\" |= \"main\" else . end |"
      echo "  ."
      echo ") else . end | "
      echo " if has (\"devDependencies\") then .devDependencies |= ("
      cat "$DEV_DEPS_FILE"
      echo "  if has(\"purescript-filterable\") then .\"purescript-filterable\" |= \"main\" else . end |"
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
function updateDeps::main {
  updateDeps::updateBower
  updateDeps::updateSpago
}

# Uses 'jq' to update all purescript `dependencies` and
# `devDependencies` (if exists) in bower.json to `master`
# or `main`, the default branch.
function updateDeps::updateBower {
  if [ -f "bower.json" ]; then
    echo "Updating all deps in 'bower.json' to 'master' or 'main'"
    local TMP_FILE
    TMP_FILE=bower.json.new

    set +x
    jq "$(cat "$JQ_SCRIPT_LOCATION")" bower.json > "$TMP_FILE" && mv "$TMP_FILE" bower.json
    set -x

    git add bower.json
    git commit -m "Update Bower dependencies to master or main"
  fi
}

# Overwrite `packages.dhall` with the `prepare-0.15` version
# of package set
function updateDeps::updateSpago {
  if [ -f "packages.dhall" ]; then
    echo "$PACKAGES_DHALL_CONTENT" > packages.dhall
    git add packages.dhall
    git commit -m "Update packages.dhall to 'prepare-0.15' package set"
  fi

  # drop `psci-support` from dependencies
  if [ -f "spago.dhall" ]; then
    local TMP_FILE
    TMP_FILE=spago.dhall.tmp
    sed '
      /, "psci-support"/d;
      s/ "psci-support"//;
      s/"psci-support" //;
      s/ dependencies = \[ \]/ dependencies = [ ] : List Text/;
      s/ dependencies = \[ \] : List Text : List Text/ dependencies = [ ] : List Text/;
      ' spago.dhall > $TMP_FILE && mv $TMP_FILE spago.dhall
    git add spago.dhall
    git commit -m "Removed unneeded 'psci-support' package"
  fi
}

function updateDeps::spagoInstallMissingDeps {
  if [ -f "spago.dhall" ]; then
    local SPAGO_OUT SPAGO_INSTALL_COMMAND PACKAGES_TO_INSTALL
    if [ -d ".spago" ]; then
      rm -rf .spago
    fi
    if [ -d "output" ]; then
      rm -rf output
    fi
    SPAGO_OUT=spago-out.txt
    spago build -u "--stash" 2> "$SPAGO_OUT"
    SPAGO_INSTALL_COMMAND=$(tail -n 1 "$SPAGO_OUT")
    rm "$SPAGO_OUT"
    if [ "$(echo "$SPAGO_INSTALL_COMMAND" | grep -c "spago install")" -eq 1 ]; then
      # deletes 'spago install ' part of text
      PACKAGES_TO_INSTALL="${SPAGO_INSTALL_COMMAND//spago install /}"
      # hacky way to get `spago install` to work
      spago install $(echo "$PACKAGES_TO_INSTALL" | tr ' ' ' ')
      git add spago.dhall
      git commit -m "Fix spago transitive dependency errors"
    fi
  fi
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