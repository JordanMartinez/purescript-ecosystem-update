#!/usr/bin/env bash

# 1. Creates a local copy of every library in core, contrib, web, and node
# 2. Applies changes across all of them to ensure things remain consistent
#      so that future ecosystem updates are easier to do as a batch script

# See https://wizardzines.com/comics/bash-errors/
set -xuo pipefail

ROOT_DIR=$(dirname "$(readlink -f "$0")")

CHANGELOG_DIR="$ROOT_DIR/files/changelogs"

if [ -d "$CHANGELOG_DIR" ]; then
  rm -rf "$CHANGELOG_DIR"
fi
mkdir -p "$CHANGELOG_DIR"

CHANGELOG_FILE="$CHANGELOG_DIR/next-release-notes.md"
MISSING="$CHANGELOG_DIR/missing"

function getChangelog::lineNumberOfFirstHdrLvl2 {
  local CONTENT
  CONTENT="$1"

  # We want to define the following regex in bash:
  #   /^ +[0-9]+\t## /
  # Unfortunately, the usage of the tab car `\t` causes issues.
  # The Tab char can only be added via the `$'\t'` workaround
  # but that doesn't work inside a string
  # So, we use 3 newline-less `echo`s to write this:
  GREP_REGEX="$(echo -n "^ +[0-9]+"; echo -n $'\t'; echo -n "##")"

  # Use `cat` to add each line's line number
  #   then search for lines starting with a Markdown header level 2
  #   The first one will be the `## Unreleased` header
  #   and the second one will be the most recent release
  # Use `head -n 2` to get the first and second header
  # Use `tail -n 1` to keep only the second header
  #   `cat -n` adds a few spaces in front of the lines' content
  # Use `sed` to remove spaces added to the front of each line's
  #   content by `cat -n`
  # Use `cut -f 1 -d $'\t'` to get the line number of the second header
  echo "$CONTENT" | cat -n | grep -E "$GREP_REGEX" | head -n 1 | sed -e 's/^ \+//' | cut -f 1 -d $'\t'
}

function getChangelog {
  local PARENT_DIR REMOTES_FILE
  PARENT_DIR=$(echo "$1" | sed 's|files/repos||; s/\.//g; s/txt//; s#/##g')
  REMOTES_FILE=$(cat "$1")

  if [ ! -d "../$PARENT_DIR" ]; then
    mkdir -p "../$PARENT_DIR"
  fi

  pushd "../$PARENT_DIR" || exit 1

  {
    echo "## \`$PARENT_DIR\` Libraries"
    echo ""
  } >> "$CHANGELOG_FILE"

  for line in $REMOTES_FILE; do
    REPO_URL=$(echo "$line" | sed 's/git@github.com://g; s/.git$//g')
    REPO_ORG=$(echo "$REPO_URL" | cut -d '/' -f 1 | sed 's/purescript-//')
    REPO_PROJ=$(echo "$REPO_URL" | cut -d '/' -f 2)
    PACKAGE="${REPO_PROJ//purescript-/}"

    if [ ! -d "$REPO_PROJ" ]; then
      gh repo fork "$REPO_URL" --clone=true
    fi

    pushd "$REPO_PROJ" || exit 1

    REMOTE_NAME="$(git remote -v 2>/dev/null | grep "$REPO_URL" | head -n 1 | cut -f 1 -d $'\t')"

    git reset --hard HEAD
    git fetch "$REMOTE_NAME"
    if [ "$(git branch -r | grep -c "$REMOTE_NAME/main")" -gt 0 ]; then
      git checkout "$REMOTE_NAME/main"
    else
      git checkout "$REMOTE_NAME/master"
    fi

    if [ ! -f "CHANGELOG.md" ]; then
      echo "$REPO_ORG|$PACKAGE" >> "$MISSING"
    else
      UNRELEASED_HEADER_LINE_NUM="$(getChangelog::lineNumberOfFirstHdrLvl2 "$(cat CHANGELOG.md)")"
      CONTENT_FIRST_LINE_NUM="$(( "$UNRELEASED_HEADER_LINE_NUM" + 1 ))"
      CL_NO_PREFIX="$(tail -n "+$CONTENT_FIRST_LINE_NUM" CHANGELOG.md)"

      NEXT_RELEASE_HEADER_LINE_NUM="$(getChangelog::lineNumberOfFirstHdrLvl2 "$CL_NO_PREFIX")"
      CONTENT_LAST_LIN_NUM="$(( "$NEXT_RELEASE_HEADER_LINE_NUM" - 1 ))"

      CL_CONTENT="$(echo "$CL_NO_PREFIX" | head -n "$CONTENT_LAST_LIN_NUM")"

      {
        echo "### $REPO_PROJ"
        echo "$CL_CONTENT"
        echo ""
      } >> "$CHANGELOG_FILE"
    fi

    popd || exit 1

  done

  popd || exit 1
}

getChangelog "./files/repos/purescript.txt"
getChangelog "./files/repos/purescript-contrib.txt"
getChangelog "./files/repos/purescript-web.txt"
getChangelog "./files/repos/purescript-node.txt"

if [ -f "$MISSING" ] && [ "$(wc -l < "$MISSING")" -gt 0 ]; then
  echo "======================================="
  echo "Repos with missing changelog files are:"
  cat "$MISSING"
fi