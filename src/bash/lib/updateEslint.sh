#!/usr/bin/env bash

ROOT_DIR=$(dirname "$(readlink -f "$0")")

EXIT_IF_LINT_FAILURE="$1"

function updateEslint::lint {
  if [ -d "src" ] && [ "$(find src/ -type f -name '*.js' 2>/dev/null | wc -l)" -gt 0 ]; then
    eslint src
  fi
  if [ -d "test" ] && [ "$(find test/ -type f -name '*.js' 2>/dev/null | wc -l)" -gt 0 ]; then
    eslint src
  fi
}

# Updates the `.eslintrc.json` file
# by checking whether the file matches
# a saved one (e.g. `1-expected.json`)
# and uses the updated one that corresponds
# to that saved one (e.g. `1.json`).
# If so, overwrites current one with desired one.
function updateEslint::main {
  if [ -f ".eslintrc.json" ]; then

    function updateEslint::main::checkAndCommit {
      local FILE_NUM ESLINT_EXPECTED ESLINT_NEW_CONTENT
      FILE_NUM="$1"
      ESLINT_EXPECTED=$(cat "$ROOT_DIR/files/eslint/$FILE_NUM-expected.json")
      ESLINT_NEW_CONTENT=$(cat "$ROOT_DIR/files/eslint/$FILE_NUM.json")
      if [ "$(cat .eslintrc.json)" == "$ESLINT_EXPECTED" ]; then
        echo "Match found on $FILE_NUM"
        echo "$ESLINT_NEW_CONTENT" > .eslintrc.json

        case "$EXIT_IF_LINT_FAILURE" in
          "fail")
            updateEslint::lint
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
    updateEslint::main::checkAndCommit "5"
    updateEslint::main::checkAndCommit "6"
    updateEslint::main::checkAndCommit "7"
    updateEslint::main::checkAndCommit "8"
  else
    echo "No .eslintrc.json file found. Skipping eslint update."
  fi
}