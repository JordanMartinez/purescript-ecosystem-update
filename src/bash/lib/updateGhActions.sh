#!/usr/bin/env bash

ROOT_DIR=$(dirname "$(readlink -f "$0")")

# Updates the `.github/worksflows/ci.yml` file
# by checking whether the difference between the
# current file and the desired one match.
# (This uses a pre-computed diff).
# If so, overwrites current one with desired one.
function updateGhActions::main {
  if [ -f ".github/workflows/ci.yml" ]; then
    local TEMP_FILE
    TEMP_FILE=ci.yml.new
    pushd .github/workflows

    function updateEslint::main::checkAndCommit {
      local FILE_NUM CONTENT DIFF_EXPECTED DIFF_ACTUAL
      FILE_NUM="$1"
      CONTENT=$(cat "$ROOT_DIR/files/gh-actions/$FILE_NUM.yml")
      DIFF_EXPECTED=$(cat "$ROOT_DIR/files/gh-actions/$FILE_NUM.yml.diff")
      echo "$CONTENT" > "$TEMP_FILE"
      DIFF_ACTUAL=$(diff .ci.yml $TEMP_FILE)
      if [ "$DIFF_EXPECTED" == "$DIFF_ACTUAL" ]; then
        echo "Match found on $FILE_NUM"
        mv "$TEMP_FILE" ci.yml
        git add ci.yml
        git commit -m "Updated ci.yml using file pattern: $FILE_NUM"
      else
        echo "Match failed for $FILE_NUM"
      fi
    }

    updateEslint::main::checkAndCommit "1"
    popd
  else
    echo "No .github/workflows/ci.yml file found. Skipping CI update."
  fi
}