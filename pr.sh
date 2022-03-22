#!/usr/bin/env bash

# 1. Creates a PR for 1 project using consistent language

# Expected usage
#     ./pr.sh 1 prelude
#     ./pr.sh 2 aff
#     ./pr.sh 3 fs
#     ./pr.sh 4 xhr
# ... where ...
#   0 - purescript-test
#   1 - purescript
#   2 - purescript-contrib
#   3 - purescript-node
#   4 - purescript-web

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

ROOT_DIR=$(dirname "$(readlink -f "$0")")

# During the execution of the `gh pr create` command,
# you will be asked 3 questoins. Here's how to answer them
# 1st question: Base repo
#  - Choose the `purescript/purescript-<packageName>` or whichever one makes sense in that context
# 2nd question: where to push branch
#  - Choose your repo
# 3rd Question: Submit or continue in browser
#  - Choose 'Continue in browser' as a final sanity-check before submitting PR

#!/usr/bin/env bash

PR_ES_BODY_PS=$(cat "$ROOT_DIR/files/pr/body-of-es-pr.txt")
PR_UP_BODY_PS=$(cat "$ROOT_DIR/files/pr/body-of-update-pr.txt")

TITLE="Update to PureScript v0.15.0"

function makePr {
  git branch | grep '*'

  if [ "$(find src/ -type f -name '*.js' 2>/dev/null | wc -l)" -gt 0 ]; then
    gh pr create --title "$TITLE" --body "$PR_ES_BODY_PS" --label "purs-0.15" --label "type: breaking change" --web
  else
    gh pr create --title "$TITLE" --body "$PR_UP_BODY_PS" --label "purs-0.15" --label "type: breaking change" --web
  fi
}

case "${1}" in
0)
  # This file is based on the `.travis.yml` file in the `purescript-prelude` repo
  pushd "../purescript-test/purescript-$2"
  makePr
  popd
  ;;
1)
  # This file is based on the `.travis.yml` file in the `purescript-prelude` repo
  pushd "../purescript/purescript-$2"
  makePr
  popd
  ;;
2)
  pushd "../purescript-contrib/purescript-$2"
  makePr
  popd
  ;;
3)
  pushd "../purescript-node/purescript-$2"
  makePr
  popd
  ;;
4)
  pushd "../purescript-web/purescript-$2"
  makePr
  popd
  ;;
esac

echo "Done"
