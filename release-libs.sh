#! /usr/bin/env bash
set -euo pipefail

BOWER_PACKAGES_JSON='https://raw.githubusercontent.com/purescript/registry/master/bower-packages.json'
NEW_PACKAGES_JSON='https://raw.githubusercontent.com/purescript/registry/master/new-packages.json'
PACKAGE_SET_PREFIX='https://raw.githubusercontent.com/purescript/package-sets/prepare-0.15'

function show_changes {
  git --no-pager show --format=''
}

function update_ci {
  echo "Updating compiler version in .github/workflows/ci.yml"
  local org="$1"
  sed -n '1,/uses: purescript-contrib\/setup-purescript/p' .github/workflows/ci.yml > ci.yml.tmp
  echo "" >> ci.yml.tmp
  if [ "$org" = purescript-contrib ]; then
    sed -n '/name: Cache PureScript dependencies/,$p' .github/workflows/ci.yml >> ci.yml.tmp
  else
    sed -n '/uses: actions\/setup-node/,$p' .github/workflows/ci.yml >> ci.yml.tmp
  fi
  mv ci.yml.tmp .github/workflows/ci.yml
  git add .github/workflows/ci.yml
  git commit -m "Update CI to build with the latest version of the compiler"
  show_changes
}

function update_bower_repository_url {
  local repository_url="$1"
  local bower_repository_url; bower_repository_url="$(jq --raw-output '.repository.url' bower.json)"
  if [ "$bower_repository_url" != "$repository_url" ]; then
    echo "Updating bower repository URL"
    echo "$bower_repository_url"
    echo "$repository_url"
    jq --arg repository_url "$repository_url" '.repository.url = $repository_url' bower.json > bower.json.tmp
    mv bower.json.tmp bower.json
    git add bower.json
    git commit -m "Update the bower repository URL to match the URL in the registry"
    show_changes
  fi
}

function update_bower_dependencies_with {
  local packages="$1"
  local key="$2"
  local names="$3"
  if [ -z "$names" ] || [ "$names" = '[]' ]; then
    jq --arg key "$key" 'del(.[$key])' bower.json > bower.json.tmp
  else
    local versions; versions="$(jq --argjson packages "$packages" 'map(ltrimstr("purescript-") | . as $package_name | $packages[$package_name].version | sub("^v";"^")? // null)' <<< "$names")"
    local dependencies; dependencies="$(jq --null-input --argjson keys "$names" --argjson values "$versions" '[[$keys, $values] | transpose[] | {key:.[0],value:.[1]}] | from_entries')"
    jq --arg key "$key" --argjson dependencies "$dependencies" '.[$key] = $dependencies' bower.json > bower.json.tmp
  fi
  mv bower.json.tmp bower.json
}

function update_bower_dependencies {
  echo "Updating bower dependencies"
  local packages="$1"
  for key in dependencies devDependencies; do
    local names; names="$(jq --arg key "$key" '.[$key] | keys?' bower.json)"
    update_bower_dependencies_with "$packages" "$key" "$names"
  done
  if ! git diff --quiet --exit-code bower.json; then
    git add bower.json
    git commit -m "Upgrade bower dependencies"
    show_changes
  fi
}

function update_contrib_bower_dependencies {
  echo "Updating bower dependencies"
  local packages="$1"
  local package_name="$2"
  curl --silent --show-error "$PACKAGE_SET_PREFIX/packages.dhall" > ./packages.dhall
  local dependencies; dependencies="$(jq --arg package_name "$package_name" '.[$package_name].dependencies | map("purescript-" + .)' <<< "$packages")"
  update_bower_dependencies_with "$packages" dependencies "$dependencies"
  local dev_dependencies; dev_dependencies="$(dhall-to-json <<< './spago.dhall' | jq --argjson dependencies "$dependencies" '.dependencies - ["psci-support"] | map("purescript-" + .) | . - $dependencies')"
  update_bower_dependencies_with "$packages" devDependencies "$dev_dependencies"
  if ! git diff --quiet --exit-code bower.json; then
    git add bower.json
    git commit -m "Upgrade bower dependencies"
    show_changes
  fi
}

function update_changelog {
  echo "Updating changelog"
  local org="$1"
  local package_name="$2"
  local version="$3"
  local release_date="$4"
  sed --in-place -e "s/## \[Unreleased\]/## \[Unreleased\]\\n\\nBreaking changes:\\n\\nNew features:\\n\\nBugfixes:\\n\\nOther improvements:\\n\\n## [$version](https:\/\/github.com\/$org\/purescript-$package_name\/releases\/tag\/$version) - $release_date/" CHANGELOG.md
  git add CHANGELOG.md
  git commit -m "Update the changelog"
  show_changes
}

function update_prelude_changelog {
  echo "Updating changelog"
  local package_name="$1"
  local version="$2"
  local release_date="$3"
  sed --in-place -e "s/## \[Unreleased\] - YEAR-MONTH-DATE/## [$version](https:\/\/github.com\/purescript\/purescript-$package_name\/releases\/tag\/$version) - $release_date/" CHANGELOG.md
  git add CHANGELOG.md
  git commit -m "Update the changelog"
  show_changes
}

function update_node_changelog {
  echo "Updating changelog"
  local release_date="$1"
  sed --in-place -e "s/2021-MONTH-DAY/$release_date/" CHANGELOG.md
  git add CHANGELOG.md
  git commit -m "Update the changelog"
  show_changes
}

function pull_request_body {
  local org="$1"
  local repository_url="$2"
  local version="$3"
  local release_notes; release_notes="$(sed -n "/## \[$version\]/,/## \[/p" CHANGELOG.md | sed -e '1d;$d')"
  local new_release_url; new_release_url="$(sed -e 's/\.git$//' <<< "$repository_url")/releases/new?tag=$version&title=$version&body=$(jq --slurp --raw-input --raw-output '@uri' <<< "$release_notes")"

cat << EOM
:robot: This is an automated pull request to prepare the next release of this library.

Some of the following steps are already done, others should be performed by a human once the pull request is merged:

  + [x] Update CI to build with the latest version of the compiler.
  + [x] Update the bower repository URL to match the URL in the registry.
  + [x] Upgrade bower dependencies.
  + [x] Update the changelog.
  + [ ] Publish a GitHub [release]($new_release_url).
  + [ ] Upload the release to Pursuit with \`pulp publish\`.
EOM
}

function open_pull_request {
  echo "Opening pull request"
  local body; body="$(pull_request_body "$1" "$2" "$3")"
  echo "$body"
  gh pr create --title "Prepare $version release" --body "$body"
}

function main {
  local org="$1"
  local release_date="$2"
  local packages; packages="$(dhall-to-json <<< "$PACKAGE_SET_PREFIX/src/groups/purescript.dhall // $PACKAGE_SET_PREFIX/src/groups/purescript-contrib.dhall // $PACKAGE_SET_PREFIX/src/groups/purescript-web.dhall // $PACKAGE_SET_PREFIX/src/groups/purescript-node.dhall")"
  local bower_packages; bower_packages="$(curl --silent --show-error "$BOWER_PACKAGES_JSON")"
  local new_packages; new_packages="$(curl --silent --show-error "$NEW_PACKAGES_JSON")"
  local registry; registry="$(jq --null-input --argjson bower_packages "$bower_packages" --argjson new_packages "$new_packages" '$bower_packages + $new_packages')"
  local org_packages; org_packages="$(dhall-to-json <<< "$PACKAGE_SET_PREFIX/src/groups/$org.dhall")"
  for package_name in $(jq --raw-output 'keys | .[]' <<< "$org_packages"); do
    local package; package="$(jq --arg key "$package_name" '.[$key]' <<< "$org_packages")"
    local repository_url; repository_url="$(jq --raw-output '.repo' <<< "$package")"
    local version; version="$(jq --raw-output '.version' <<< "$package")"
    local branch; branch="release-$version"
    local workspace; workspace="$(mktemp --directory)"
    echo "Preparing to release $package_name@$version"
    echo "Cloning $repository_url"
    git clone --depth 1 "$repository_url" "$workspace"
    pushd "$workspace"
    if git ls-remote --exit-code --heads origin "$branch" > /dev/null; then
      echo "Release branch $branch found on remote, skipping $package_name"
      continue
    fi
    git checkout -b "$branch"
    update_ci "$org"
    update_bower_repository_url "$(jq --raw-output --arg "key" "purescript-$package_name" '.[$key]' <<< "$registry")"
    if [ "$org" = purescript-contrib ]; then
      update_contrib_bower_dependencies "$packages" "$package_name"
    else
      update_bower_dependencies "$packages"
    fi
    if [ "$org" = purescript-node ]; then
      update_node_changelog "$release_date"
    elif [ "$package_name" = prelude ]; then
      update_prelude_changelog "$package_name" "$version" "$release_date"
    else
      update_changelog "$org" "$package_name" "$version" "$release_date"
    fi
    if [ -z "$dry_run" ]; then
      git push --set-upstream origin "$branch"
      open_pull_request "$org" "$repository_url" "$version"
    fi
    popd
    rm -rf "$workspace"
  done
}

dry_run=true
if [ "${1-}" = --no-dry-run ]; then
  dry_run=''
  shift
else
  echo "Starting script in Dry Run mode; rerun with '--no-dry-run' to make actual releaes."
fi

release_date=2021-02-26
# release_date="$(date --date "${1-}" '+%Y-%m-%d')"

if [ "$release_date" == "2021-02-26" ]; then
  echo "Release date hasn't been updated for 0.15.0 release. Update it and try again"
  exit 1
fi

while true; do
  read -rp "Which org should be released${dry_run:+ (this is a dry run)}? " org
  case $org in
      purescript|purescript-contrib|purescript-node|purescript-web )
        main "$org" "$release_date"; break;;
      * ) echo "Expecting one of purescript, purescript-contrib, purescript-node or purescript-web.";;
  esac
done