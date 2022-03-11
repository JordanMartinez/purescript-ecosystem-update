#!/usr/bin/env bash

function displayBranch::main {
  local FINAL_FILE=$1
  local DEPS_FILE=bowerDeps-deps.txt
  local DEV_DEPS_FILE=bowerDeps-dev-deps.tx

  function rmFile {
    rm $1 || echo "$1 doesn't exist; skipping."
  }

  # jq '.dependencies |= (
  #   if has("purescript-repo") then (.purescript-repo |= "branchName") else . end |
  #   if has("purescript-repo2") then (.purescript-repo2 |= "branchName") else . end |
  #   .
  # ) | .devDependencies |= (
  #   if has("purescript-repo") then (.purescript-repo |= "branchName") else . end |
  #   if has("purescript-repo2") then (.purescript-repo2 |= "branchName") else . end |
  #   .
  # )'
  #
  # Intended to be called via `cat bower.json | jq $(cat $FINAL_FILE)`
  function printBranch {
    local FILE=$(cat $1)
    local BRANCH=$2

    echo "if has(\"dependencies\") then .dependencies |= (" > $FINAL_FILE

    for line in $FILE; do
      REPO_URL=$(echo $line | sed 's/git@github.com://g; s/.git$//g')
      REPO_ORG=$(echo $REPO_URL | cut -d '/' -f 1)
      REPO_PROJ=$(echo $REPO_URL | cut -d '/' -f 2)
      echo "  if has(\"$REPO_PROJ\") then .\"$REPO_PROJ\" |= \"$BRANCH\" else . end |" >> $DEPS_FILE
      echo "  if has(\"$REPO_PROJ\") then .\"$REPO_PROJ\" |= \"$BRANCH\" else . end |" >> $DEV_DEPS_FILE
    done
    cat $DEPS_FILE >> $FINAL_FILE
    echo "  ." >> $FINAL_FILE
    echo ") else . end | " >> $FINAL_FILE
    echo " if has (\"devDependencies\") then .devDependencies |= (" >> $FINAL_FILE
    cat $DEV_DEPS_FILE >> $FINAL_FILE
    echo "  ." >> $FINAL_FILE
    echo ") else . end" >> $FINAL_FILE
  }
  rmFile $FINAL_FILE
  rmFile $DEPS_FILE
  rmFile $DEV_DEPS_FILE

  printBranch "./repos/purescript.txt" "master"
  printBranch "./repos/purescript-contrib.txt" "main"
  printBranch "./repos/purescript-web.txt" "master"
  printBranch "./repos/purescript-node.txt" "master"

  rmFile $DEPS_FILE
  rmFile $DEV_DEPS_FILE
}
