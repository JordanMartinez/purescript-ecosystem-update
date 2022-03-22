#!/usr/bin/env bash

# ROOT_DIR="$(dirname "$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")")"

ADD_PULP_AND_BOWER_TO_CI="
      - name: Verify Bower & Pulp
        run: |
          npm install bower pulp@16.0.0-0
          npx bower install
          npx pulp build -- --censor-lib --strict
          if [ -d \"test\" ]; then
            npx pulp test
          fi"

# Update the `.github/workflows/ci.yml` file to specifically use
# the latest alpha PS release
function updateGhActions::main {
  local ORG
  ORG="$1"
  case "${ORG}" in
    "purescript-contrib")
      updateGhActions::contrib
      ;;
    *)
      updateGhActions::core
      ;;
  esac
}

function updateGhActions::contrib {
  echo "Update ci.yml to use purescript unstable"
  sed -i'.bckup' 's/          purs-tidy: "latest"/          purescript: "unstable"\n          purs-tidy: "latest"/' .github/workflows/ci.yml
  rm .github/workflows/ci.yml.bckup
  git add .github/workflows/ci.yml
  git commit -m "Update to CI to use 'unstable' purescript"

  echo "$ADD_PULP_AND_BOWER_TO_CI" >> .github/workflows/ci.yml
  git add .github/workflows/ci.yml
  git commit -m "Add CI test: verify 'bower.json' file works via pulp"

  sed -i'.bckup' '
    s/      - name: Run tests/#      - name: Run tests/;
    s/        run: npm run test/#        run: npm run test/;
    s/        run: spago test --no-install/#        run: spago test --no-install/;
    ' .github/workflows/ci.yml
  rm .github/workflows/ci.yml.bckup
  git add .github/workflows/ci.yml
  git commit -m "Ignore spago-based tests (temporarily)"
}

function updateGhActions::core {
  echo "Update ci.yml to use purescript unstable"
  sed -i'.bckup' '
    s/        uses: purescript-contrib\/setup-purescript@main/        uses: purescript-contrib\/setup-purescript@main\n        with:\n          purescript: "unstable"/;
    s/      - uses: purescript-contrib\/setup-purescript@main/      - uses: purescript-contrib\/setup-purescript@main\n        with:\n          purescript: "unstable"/' .github/workflows/ci.yml
  rm .github/workflows/ci.yml.bckup
  git add .github/workflows/ci.yml
  git commit -m "Update to CI to use 'unstable' purescript"
}
