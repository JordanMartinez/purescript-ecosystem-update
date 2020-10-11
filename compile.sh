#!/usr/bin/env bash

export PATH="$(pwd):$PATH"
cd ../purescript-$1
npm install
bower install --production
npm run -s build
bower install
npm -s test
