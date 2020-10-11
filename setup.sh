#!/usr/bin/env bash

npm i -g pulp bower purescript-psa@0.8.0
gh auth login
gh config set git_protocol ssh
