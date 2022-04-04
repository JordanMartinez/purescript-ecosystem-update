#! /usr/bin/env bash
set -euo pipefail

echo "Stopping script execution to prevent accidental usage."
echo "Remove these three two lines locally"
exit 1

function show {
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
  git commit -m "Use the latest compiler version on CI"
  show
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
    git commit -m "Update the bower repository url to the one known by the registry"
    show
  fi
}

function update_bower_dependencies {
  echo "Updating bower dependencies"
  for key in 'dependencies' 'devDependencies'; do
    local names; names="$(jq --arg key "$key" '.[$key] | keys?' bower.json)"
    [ -n "$names" ] || continue
    local versions; versions="$(jq --argjson packages "$packages"  'map(ltrimstr("purescript-") | . as $package_name | $packages[$package_name].version | sub("^v";"^")? // null)' <<< "$names")"
    local dependencies; dependencies="$(jq --null-input --argjson keys "$names" --argjson values "$versions" '[[$keys, $values] | transpose[] | {key:.[0],value:.[1]}] | from_entries')"
    jq --arg key "$key" --argjson dependencies "$dependencies" '.[$key] = $dependencies' bower.json > bower.json.tmp
    mv bower.json.tmp bower.json
  done
  if ! git diff --quiet --exit-code bower.json; then
    git add bower.json
    git commit -m "Update bower dependencies"
    show
  fi
}

function update_changelog {
  echo "Updating changelog"
  local package_name="$1"
  local version="$2"
  local release_date="$3"
  sed --in-place -e "s/## \[Unreleased\]/## \[Unreleased\]\\n\\nBreaking changes:\\n\\nNew features:\\n\\nBugfixes:\\n\\nOther improvements:\\n\\n## [$version](https:\/\/github.com\/purescript\/purescript-$package_name\/releases\/tag\/$version) - $release_date/" CHANGELOG.md
  git add CHANGELOG.md
  git commit -m "Update CHANGELOG.md"
  show
}

function update_prelude_changelog {
  echo "Updating changelog"
  local package_name="$1"
  local version="$2"
  local release_date="$3"
  sed --in-place -e "s/## \[Unreleased\] - YEAR-MONTH-DATE/## [$version](https:\/\/github.com\/purescript\/purescript-$package_name\/releases\/tag\/$version) - $release_date/" CHANGELOG.md
  git add CHANGELOG.md
  git commit -m "Update CHANGELOG.md"
  show
}

function update_contrib_changelog {
  sed --in-place -e 's/ (😱!!!)//' CHANGELOG.md
  update_changelog "$1" "$2" "$3"
}

function update_node_library_changelog {
  echo "Updating changelog"
  local release_date="$1"
  sed --in-place -e "s/2021-MONTH-DAY/$release_date/" CHANGELOG.md
  git add CHANGELOG.md
  git commit -m "Update CHANGELOG.md"
  show
}

function pull_request_body {
  local repository_url="$1"
  local branch="$2"
  local version="$3"
  local release_notes; release_notes="$(sed -n "/## \[$version\]/,/## \[/p" CHANGELOG.md | sed -e '$d')"
  local new_release_url; new_release_url="$(sed -e 's/\.git$//' <<< "$repository_url")/releases/new?tag=$version&target=$branch&title=$version&body=$(jq --slurp --raw-input --raw-output '@uri' <<< "$release_notes")"

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
  local org_packages; org_packages="$(dhall-to-json <<< "$package_set/src/groups/$org.dhall")"
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
      update_bower_dependencies
      if [ "$org" = purescript-node ]; then
        update_node_library_changelog "$release_date"
      elif [ "$org" = purescript-contrib ]; then
        update_contrib_changelog "$package_name" "$version" "$release_date"
      elif [ "$package_name" = prelude ]; then
        update_prelude_changelog "$package_name" "$version" "$release_date"
      else
        update_changelog "$package_name" "$version" "$release_date"
      fi
      if [ -z "$dry_run" ]; then
        git push origin "$branch"
        open_pull_request "$repository_url" "$branch" "$version"
      fi
      popd
      rm -rf "$workspace"
  done
}

package_set='https://raw.githubusercontent.com/kl0tl/package-sets/next'
packages="$(dhall-to-json <<< "$package_set/src/groups/purescript.dhall // $package_set/src/groups/purescript-contrib.dhall // $package_set/src/groups/purescript-web.dhall // $package_set/src/groups/purescript-node.dhall")"
registry="$(curl --silent --show-error https://raw.githubusercontent.com/purescript/registry/master/bower-packages.json)"

dry_run=''
if [ "${1-}" = --dry-run ]; then
  dry_run=true
  shift
fi

release_date="$(date --date "${1-}" '+%Y-%m-%d')"

while true; do
  read -rp "Which org should be released${dry_run:+ (this is a dry run)}? " org
  case $org in
      purescript|purescript-contrib|purescript-node|purescript-web )
        main "$org" "$release_date"; break;;
      * ) echo "Expecting one of purescript, purescript-contrib, purescript-node or purescript-web.";;
  esac
done