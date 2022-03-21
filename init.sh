#!/usr/bin/env bash

# 1. Installs necessary tooling
# 2. Sets up `gh` tool
# 3. downloads the latest `purs` and stores it locally here
#      so other scripts can include it on the PATH

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

npm i -g pulp@16.0.0-0 bower purescript-psa spago esbuild lebab
gh auth login
gh config set git_protocol ssh

# Download the PureScript release based on `PS_TAG`
PS_TAG=v0.15.0-alpha-02
FILE=""
OUTPUT=./purescript.tar.gz
TAR_DIR=./purescript

unameOut="$(uname -s)"
case "${unameOut}" in
    Darwin*) FILE=linux64;;
    Linux*)  FILE=macos;;
    # CYGWIN*) FILE=Cygwin;;
    # MINGW*)  FILE=MinGw;;
    *)       echo "UNKNOWN:${unameOut}" && exit 1
esac

# Download and extract the archive
curl --location --output $OUTPUT https://github.com/purescript/purescript/releases/download/$PS_TAG/$FILE.tar.gz
tar -xvf $OUTPUT

# Move the `purs` binary to this folder
mv $TAR_DIR/purs ./purs

# Remove the uneeded files
rm -rf $TAR_DIR
rm $OUTPUT
