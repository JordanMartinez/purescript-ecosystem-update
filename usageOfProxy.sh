#!/usr/bin/env bash

# Prints all places where a kind-specific Proxy is used

grep -r --include "*.purs" Proxy src/
grep -r --include "*.purs" Proxy test/
