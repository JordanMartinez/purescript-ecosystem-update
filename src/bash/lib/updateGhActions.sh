#!/usr/bin/env bash

# Update the `.github/workflows/ci.yml` file to specifically use
# the latest alpha PS release
function updateGhActions::main {
  echo "Update ci.yml to use purescript unstable"
  sed -i 's/        uses: purescript-contrib\/setup-purescript@main/        uses: purescript-contrib\/setup-purescript@main\n        with:\n          purescript: "unstable"/' .github/workflows/ci.yml
  sed -i 's/      - uses: purescript-contrib\/setup-purescript@main/      - uses: purescript-contrib\/setup-purescript@main\n        with:\n          purescript: "unstable"/' .github/workflows/ci.yml
  git add .github/workflows/ci.yml
  git commit -m "Update to CI to use 'unstable' purescript"
}
