#!/usr/bin/env bash

# 1. Creates a local copy of every library in core, contrib, web, and node
# 2. Applies changes across all of them to ensure things remain consistent
#      so that future ecosystem updates are easier to do as a batch script

# See https://wizardzines.com/comics/bash-errors/
set -xuo pipefail

PACKAGES_DHALL_CONTENT="let upstream =
      https://raw.githubusercontent.com/purescript/package-sets/prepare-0.15/src/packages.dhall

in  upstream
"
REMOVE_USE_STRICT_SCRIPT=$(cat node-scripts/remove-use-strict.js)

ESLINTRC_CONTENT=$(cat files/.eslintrc.json)
ESLINT_DIFF_EXPECTED=$(cat files/.eslintrc.json.diff)

# Regenerate JQ script for updating bower.json file
# and store results in JQ_SCRIPT_UPDATE_BOWER_JSON
JQ_SCRIPT_LOCATION=jq-script--update-bower-json.txt

source ./displayBranch.sh
displayBranch::main $JQ_SCRIPT_LOCATION

JQ_SCRIPT_UPDATE_BOWER_JSON=$(cat $JQ_SCRIPT_LOCATION)

# Updates the dependencies in bower or spago projects
# to latest `master`/`main`
function forakAll::updateDependencies {
  local BUILD_TOOL=$1
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
function forkAll::updateBower {
  echo "Updating all deps in 'bower.json' to 'master' or 'main'"
  local TMP_FILE=bower.json.new
  cat bower.json | jq "$JQ_SCRIPT_UPDATE_BOWER_JSON" >$TMP_FILE && mv $TMP_FILE bower.json
  git add bower.json
  git commit -m "Update Bower dependencies to master or main"
}

# Overwrite `packages.dhall` with the `prepare-0.15` version
# of package set
function forkAll::updateSpago {
  echo $PACKAGES_DHALL_CONTENT > packages.dhall
  git add packages.dhall
  git commit -m "Update packages.dhall to 'prepare-0.15' package set"
}

function forkAll::updatePackageJson {
  if [ -f "package.json" ]; then
    local TMP_FILE=package.json.new
    cat package.json | jq '
      if has("devDependencies") then
        .devDependencies |= (
          if has("purescript-psa") then ."purescript-psa" = "^0.8.2" else . end |
          if has("pulp") then ."pulp" = "16.0.0-0" else . end
        )
      else . end' > $TMP_FILE && mv $TMP_FILE package.json
    git add package.json
    git commit -m "Update pulp to 16.0.0-0 and psa to 0.8.2"
  fi
}

# Updates the `.eslintrc.json` file
# by checking whether the difference between the
# current file and the desired one match.
# (This uses a pre-computed diff).
# If so, overwrites current one with desired one.
function forkAll::updateEslintrcJson {
  if [ -f ".eslintrc.json" ]; then
    local TEMP_FILE=.eslintrc.json.new
    echo $ESLINTRC_CONTENT > $TEMP_FILE
    local ESLINT_DIFF_ACTUAL=$(diff .eslintrc.json $TEMP_FILE)
    if [ "$ESLINT_DIFF_EXPECTED" == "$ESLINT_DIFF_ACTUAL" ]; then
      mv $TEMP_FILE .eslintrc.json
      git add .eslintrc.json
      git commit -m "Update .eslintrc.json to ES6"
    fi
  fi
}

# Uses a combination of `lebab`, `sed`
# and a Node script to update all FFI
# to ES modules. This will work 95%
# of the time, but still needs to be verified.
function forkAll::updateFFIToESModules {
  local MIGRATION_MSG="Migrated FFI to ES modules via 'lebab'"
  local EXPORT_UPDATE_MSG="Replaced 'export var' with 'export const'"
  local STRICT_FIX_MSG="Removed '\"use strict\";' in FFI files"
  if [ -d "src" ] && [ -d "test" ]; then
    echo "Using lebab to transform CJS to ES - both"
    # Transform to ES 6
    lebab --replace src --transform commonjs
    lebab --replace test --transform commonjs
    git add src test
    git commit -m "$MIGRATION_MSG"
    # Replace 'export var' with 'export const'
    find src -type f -wholename "**/*.js" -print0 | xargs -0 sed -i 's/export var/export const/g'
    find test -type f -wholename "**/*.js" -print0 | xargs -0 sed -i 's/export var/export const/g'
    git add src test
    git commit -m "$EXPORT_UPDATE_MSG"
    # Remove `"use strict";\n\n`
    find src -type f -wholename "**/*.js" -print0 -exec node --input-type module -e "$REMOVE_USE_STRICT_SCRIPT" -- {} \;
    find test -type f -wholename "**/*.js" -print0 -exec node --input-type module -e "$REMOVE_USE_STRICT_SCRIPT" -- {} \;
    git add src test
    git commit -m "$STRICT_FIX_MSG"
  elif [ -d "src" ]; then
    echo "Using lebab to transform CJS to ES - source"
    lebab --replace src --transform commonjs
    git add src
    git commit -m "$MIGRATION_MSG"

    find src -type f -wholename "**/*.js" -print0 | xargs -0 sed -i 's/export var/export const/g'
    git add src
    git commit -m "$EXPORT_UPDATE_MSG"

    find src -type f -wholename "**/*.js" -print0 -exec node --input-type module -e "$REMOVE_USE_STRICT_SCRIPT" -- {} \;
    git add src
    git commit -m "$STRICT_FIX_MSG"
  fi
}

# Update the `.github/workflows/ci.yml` file to specifically use
# the latest alpha PS release
function forkAll::updateCiYml {
  echo "Update ci.yml to use purescript unstable"
  sed -i 's/        uses: purescript-contrib\/setup-purescript@main/        uses: purescript-contrib\/setup-purescript@main\n        with:\n          purescript: "unstable"/' .github/workflows/ci.yml
  sed -i 's/      - uses: purescript-contrib\/setup-purescript@main/      - uses: purescript-contrib\/setup-purescript@main\n        with:\n          purescript: "unstable"/' .github/workflows/ci.yml
  git add .github/workflows/ci.yml
  git commit -m "Update to CI to use 'unstable' purescript"
}

function forkAll {
  local PARENT_DIR=$(echo "$1" | sed 's/repos//; s/\.//g; s/txt//; s#/##g')
  local REMOTES_FILE=$(cat $1)
  local DEFAULT_BRANCH_NAME=$2
  local BUILD_TOOL=$3

  mkdir -p ../$PARENT_DIR
  pushd ../$PARENT_DIR

  for line in $REMOTES_FILE; do
    REPO_URL=$(echo $line | sed 's/git@github.com://g; s/.git$//g')
    REPO_ORG=$(echo $REPO_URL | cut -d '/' -f 1)
    REPO_PROJ=$(echo $REPO_URL | cut -d '/' -f 2)

    gh repo fork $REPO_URL --clone=true
    pushd $REPO_PROJ

    # Ensure `origin` points to the actual repo
    # by seeing if the number of remotes is just 2 or not
    if [ $(git remote -v 2>/dev/null | wc -l) -gt 2 ]; then
      git remote rename origin self
      git remote rename upstream origin
    fi

    # If there are JS files, we need to update them using the
    # working-group-purescript-es org.
    # Note: the code below might only work with GNU Bash (i.e. not on Macs).
    if [ $(find src/ -type f -name '*.js' 2>/dev/null | wc -l) -gt 0 ]; then
      echo "$REPO_URL has JS files"
      gh repo fork $REPO_URL --clone=false --org working-group-purescript-es
      git remote add wg "git@github.com:working-group-purescript-es/$REPO_PROJ.git"
      git fetch wg
      if [ $(git branch -r | grep 'wg/es-modules' | wc -l) -gt 0 ]; then
        git checkout wg/es-modules
      else
        git checkout origin/master
      fi
      git switch -c es-modules-libraries
      git push -u wg es-modules-libraries

      forkAll::updateEslintrcJson

      forkAll::updateFFIToESModules
    else
      # No JS Files here!
      echo "$REPO_URL does not have any JS files"
      git checkout origin/$DEFAULT_BRANCH_NAME
      git switch -c update-to-0.15
      git push -u origin update-to-0.15
    fi

    forkAll::updateCiYml

    forkAll::updateDependencies $BUILD_TOOL

    forkAll::updatePackageJson

    popd

  done

  popd
}

# forkAll "./repos/ps-0.txt" "master" "bower"
forkAll "./repos/purescript.txt" "master" "bower"
# forkAll "./repos/purescript-contrib.txt" "main" "spago"
# forkAll "./repos/purescript-web.txt" "master" "spago"
# forkAll "./repos/purescript-node.txt" "master" "spago"

# echo ""
# echo "Remaining Steps:"
# echo "1. Run './compile.sh $1' and use '1' to select the 'master' branch if 'bower' complains"
# echo "2. Navigate into 'purescript-$1' via 'pushd ../purescript-$1' (use 'popd' to return to this folder)"
# echo "3. Open the below URL to see whether repo has any pre-existing PRs and/or issues"
# echo https://github.com/purescript/purescript-$1
