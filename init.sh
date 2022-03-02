#!/usr/bin/env bash

# See https://wizardzines.com/comics/bash-errors/
set -euo pipefail

npm i -g pulp bower purescript-psa spago
gh auth login
gh config set git_protocol ssh

# Download the PureScript release based on `PS_TAG`
export PS_TAG=v0.15.0-alpha-01
export OUTPUT=./purescript.tar.gz
export TAR_DIR=./purescript

# Download and extract the archive
curl --location --output $OUTPUT https://github.com/purescript/purescript/releases/download/$PS_TAG/linux64.tar.gz
tar -xvf $OUTPUT

# Move the `purs` binary to this folder
mv $TAR_DIR/purs ./purs

# Remove the uneeded files
rm -rf $TAR_DIR
rm $OUTPUT
