#!/usr/bin/env bash

# 1. Creates a local copy of every library in core, contrib, web, and node
# 2. Applies changes across all of them to ensure things remain consistent
#      so that future ecosystem updates are easier to do as a batch script

# See https://wizardzines.com/comics/bash-errors/
set -xuo pipefail

ROOT_DIR=$(dirname "$(readlink -f "$0")")

source src/bash/lib/migrateFfiToEs6.sh

# Regenerate JQ script for updating bower.json file
# and store results in JQ_SCRIPT_UPDATE_BOWER_JSON
JQ_SCRIPT_LOCATION=jq-script--update-bower-json.txt
source src/bash/lib/updateDeps.sh "$JQ_SCRIPT_LOCATION" "0"
JQ_SCRIPT_UPDATE_BOWER_JSON=$(cat "$JQ_SCRIPT_LOCATION")

source src/bash/lib/updateEslint.sh "continue"
source src/bash/lib/updateGhActions.sh
source src/bash/lib/updatePackageJson.sh

REMOVE_USE_STRICT_SCRIPT=$(cat "$ROOT_DIR/src/node/lib/remove-use-strict.js")


function forkAll {
  local PARENT_DIR REMOTES_FILE DEFAULT_BRANCH_NAME
  PARENT_DIR=$(echo "$1" | sed 's/repos//; s/\.//g; s/txt//; s#/##g')
  REMOTES_FILE=$(cat "$1")
  DEFAULT_BRANCH_NAME=$2

  mkdir -p "../$PARENT_DIR"
  pushd "../$PARENT_DIR" || (echo "pushd failed for '../$PARENT_DIR'" && exit)

  for line in $REMOTES_FILE; do
    REPO_URL=$(echo "$line" | sed 's/git@github.com://g; s/.git$//g')
    # REPO_ORG=$(echo "$REPO_URL" | cut -d '/' -f 1)
    REPO_PROJ=$(echo "$REPO_URL" | cut -d '/' -f 2)

    gh repo fork "$REPO_URL" --clone=true
    pushd "$REPO_PROJ" || (echo "pushd failed for '$REPO_PROJ'" && exit)

    # Ensure `origin` points to the actual repo
    # by seeing if the number of remotes is just 2 or not
    if [ "$(git remote -v 2>/dev/null | wc -l)" -gt 2 ]; then
      git remote rename origin self
      git remote rename upstream origin
    fi

    # If there are JS files, we need to update them using the
    # working-group-purescript-es org.
    # Note: the code below might only work with GNU Bash (i.e. not on Macs).
    if [ "$(find src/ -type f -name '*.js' 2>/dev/null | wc -l)" -gt 0 ]; then
      echo "$REPO_URL has JS files"
      gh repo fork "$REPO_URL" --clone=false --org working-group-purescript-es
      git remote add wg "git@github.com:working-group-purescript-es/$REPO_PROJ.git"
      git fetch wg
      if [ "$(git branch -r | grep -c 'wg/es-modules')" -gt 0 ]; then
        git checkout wg/es-modules
      else
        git checkout "origin/$DEFAULT_BRANCH_NAME"
      fi
      git switch -c es-modules-libraries
      git push -u wg es-modules-libraries

      updateEslint::main

      migrateFfiToEs6::main
    else
      # No JS Files here!
      echo "$REPO_URL does not have any JS files"
      git checkout "origin/$DEFAULT_BRANCH_NAME"
      git switch -c update-to-0.15
      git push -u origin update-to-0.15
    fi

    updateGhActions::main

    updateDeps::main

    updatePackageJson::main

    popd || (echo "popd on repo dir failed" && exit 1)

  done

  popd || (echo "popd on org dir failed" && exit 1)
}

# forkAll "./repos/ps-0.txt" "master"
# forkAll "./repos/purescript.txt" "master"
forkAll "./repos/purescript-test.txt" "main"
# forkAll "./repos/purescript-contrib.txt" "main"
# forkAll "./repos/purescript-web.txt" "master"
# forkAll "./repos/purescript-node.txt" "master"

# echo ""
# echo "Remaining Steps:"
# echo "1. Run './compile.sh $1' and use '1' to select the 'master' branch if 'bower' complains"
# echo "2. Navigate into 'purescript-$1' via 'pushd ../purescript-$1' (use 'popd' to return to this folder)"
# echo "3. Open the below URL to see whether repo has any pre-existing PRs and/or issues"
# echo https://github.com/purescript/purescript-$1
