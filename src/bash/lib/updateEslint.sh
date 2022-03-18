#!/usr/bin/env bash

ROOT_DIR=$(dirname "$(readlink -f "$0")")

EXIT_IF_LINT_FAILURE="$1"

# Updates the `.eslintrc.json` file
# by checking whether the difference between the
# current file and the desired one match.
# (This uses a pre-computed diff).
# If so, overwrites current one with desired one.
function updateEslint::main {
  if [ -f ".eslintrc.json" ]; then
    local TEMP_FILE
    TEMP_FILE=.eslintrc.json.new

    function updateEslint::main::checkAndCommit {
      local FILE_NUM ESLINTRC_CONTENT ESLINT_DIFF_EXPECTED ESLINT_DIFF_ACTUAL
      FILE_NUM="$1"
      ESLINTRC_CONTENT=$(cat "$ROOT_DIR/files/eslint/$FILE_NUM.json")
      ESLINT_DIFF_EXPECTED=$(cat "$ROOT_DIR/files/eslint/$FILE_NUM.json.diff")
      echo "$ESLINTRC_CONTENT" > "$TEMP_FILE"
      ESLINT_DIFF_ACTUAL=$(diff .eslintrc.json $TEMP_FILE)
      if [ "$ESLINT_DIFF_EXPECTED" == "$ESLINT_DIFF_ACTUAL" ]; then
        echo "Match found on $FILE_NUM"
        mv "$TEMP_FILE" .eslintrc.json

        case "$EXIT_IF_LINT_FAILURE" in
          "fail")
            if [ -d "src" ]; then
              eslint src
            fi
            if [ -d "test" ]; then
              eslint src
            fi
            ;;
          *)
            echo "Skipping lint check"
            ;;
        esac
        git add .eslintrc.json
        git commit -m "Update .eslintrc.json to ES6"
      else
        echo "Match failed for $FILE_NUM"
      fi
    }

    updateEslint::main::checkAndCommit "1"
    updateEslint::main::checkAndCommit "2"
    updateEslint::main::checkAndCommit "3"
    updateEslint::main::checkAndCommit "4"
  else
    echo "No .eslintrc.json file found. Skipping eslint update."
  fi
}