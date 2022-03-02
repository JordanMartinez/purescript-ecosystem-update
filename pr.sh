#!/usr/bin/env bash

# Expected usage
#     ./pr.sh 1 prelude
#     ./pr.sh 2 aff
#     ./pr.sh 3 fs
#     ./pr.sh 4 xhr
# ... where ...
#   1 - purescript
#   2 - purescript-contrib
#   3 - purescript-node
#   4 - purescript-web

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

# During the execution of the `gh pr create` command,
# you will be asked 3 questoins. Here's how to answer them
# 1st question: Base repo
#  - Choose the `purescript/purescript-<packageName>` or whichever one makes sense in that context
# 2nd question: where to push branch
#  - Choose your repo
# 3rd Question: Submit or continue in browser
#  - Choose 'Continue in browser' as a final sanity-check before submitting PR

#!/usr/bin/env bash

PR_BODY_PS=$(cat ./pr_body/purescript.txt)

TITLE="Update to v0.15.0"

case "${1}" in
1)
  # This file is based on the `.travis.yml` file in the `purescript-prelude` repo
  pushd ../purescript/purescript-$2
  git branch | grep '*'
  gh pr create --title "$TITLE" --body "$PR_BODY_PS" --label "purs-0.15" --label "type: breaking change"
  popd
  ;;
2)
  pushd ../purescript-contrib/purescript-$2
  git branch | grep '*'
  gh pr create --title "$TITLE" --body "$PS_BODY_PS" --label "purs-0.15" --label "type: breaking change"
  popd
  ;;
3)
  pushd ../purescript-node/purescript-node-$2
  git branch | grep '*'
  gh pr create --title "$TITLE" --body "$PS_BODY_PS" --label "purs-0.15" --label "type: breaking change"
  popd
  ;;
4)
  pushd ../purescript-web/purescript-web-$2
  git branch | grep '*'
  gh pr create --title "$TITLE" --body "$PS_BODY_PS" --label "purs-0.15" --label "type: breaking change"
  popd
  ;;
esac

echo "Done"
