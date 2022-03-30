#!/usr/bin/env bash

# MIT License
#
# Copyright © 2022 Jordan Martinez
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

echo "Verifying 'lebab' is installed or installing it if it's not."
which lebab || npm i -g lebab

# Because I couldn't figure out how to replace
# multi-line content, I reverted to using Node.js
NODE_SCRIPT_FILE_REMOVE_USE_STRICT=migrate-ffi-remove-use-strict.mjs

echo "Creating the '$NODE_SCRIPT_FILE_REMOVE_USE_STRICT' file"

cat  > "$NODE_SCRIPT_FILE_REMOVE_USE_STRICT" <<EOF
import process from "process";
import fs from "fs";

const fileName = process.argv[2];
const content = fs.readFileSync(fileName, "utf-8");
const fixed = content.replaceAll(/[ \t]*"use strict";\n+/g, "");

fs.writeFileSync(fileName, fixed);
EOF


# Uses a combination of `lebab`, `sed`
# and a Node script to update all FFI
# to ES modules. This will work 95%
# of the time, but the changes still
# need to be verified.
MIGRATION_MSG="Migrated FFI to ES modules via 'lebab'"
EXPORT_UPDATE_MSG="Replaced 'export var' with 'export const'"
FIX_USE_STRICT_MSG="Removed '\"use strict\";' in FFI files"

if [ -d "src" ] && [ -d "test" ]; then
  echo "Using lebab to transform CJS to ES - both"
  # Transform to ES 6
  lebab --replace src --transform commonjs
  lebab --replace test --transform commonjs
  git add src test
  git commit -m "$MIGRATION_MSG"

  # Replace 'export var' with 'export const'
  echo "Replacing 'export var' with 'export const'"
  find src -type f -wholename "**/*.js" -print0 -exec sed -i'.bckup' 's/export var/export const/g' "{}" \; -exec rm "{}.bckup" \;
  find test -type f -wholename "**/*.js" -print0 -exec sed -i'.bckup' 's/export var/export const/g' "{}" \; -exec rm "{}.bckup" \;
  git add src test
  git commit -m "$EXPORT_UPDATE_MSG"

  # Remove `"use strict";\n\n`
  echo "Replacing '\"use strict;\"'"
  find src -type f -wholename "**/*.js" -print0 -exec node "$NODE_SCRIPT_FILE_REMOVE_USE_STRICT" "{}" \;
  find test -type f -wholename "**/*.js" -print0 -exec node "$NODE_SCRIPT_FILE_REMOVE_USE_STRICT" "{}" \;
  git add src test
  git commit -m "$FIX_USE_STRICT_MSG"
elif [ -d "src" ]; then
  echo "Using lebab to transform CJS to ES - src only"
  lebab --replace src --transform commonjs
  git add src
  git commit -m "$MIGRATION_MSG"

  echo "Replacing 'export var' with 'export const'"
  find src -type f -wholename "**/*.js" -print0 -exec sed -i'.bckup' 's/export var/export const/g' "{}" \; -exec rm "{}.bckup" \;
  git add src
  git commit -m "$EXPORT_UPDATE_MSG"

  echo "Replacing '\"use strict;\"'"
  find src -type f -wholename "**/*.js" -print0 -exec node "$NODE_SCRIPT_FILE_REMOVE_USE_STRICT" "{}" \;
  git add src
  git commit -m "$FIX_USE_STRICT_MSG"
fi

echo "Removing '$NODE_SCRIPT_FILE_REMOVE_USE_STRICT' file"
rm "$NODE_SCRIPT_FILE_REMOVE_USE_STRICT"
