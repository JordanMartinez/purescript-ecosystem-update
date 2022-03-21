# purescript-ecosystem-update

This repo stores scripts for forking, updating, and submitting PRs for the `core`, `contrib`, `node`, and `web` PureScript orgainzations' libraries.

## Why

Breaking changes made in libraries are done at the same time as when breaking changes are made in the PureScript compiler. Thus, we have to update all the foundational libraries for the PureScript ecosystem. This entails forking, updating, and submitting and merging many PRs. The scripts in this repo enable a streamlined workflow to make this update process easier.

## How: The intended workflow

```sh
# Create a separate folder for containing both the scripts
# and the local copies of the repos under their org-specific folder
mkdir ps-libs
cd ps-libs

# Clone this repo and enter it
git clone git@github.com:JordanMartinez/purescript-ecosystem-update.git 0.15
cd 0.15

./init.sh
./forkall.sh


# For each repo, the workflow looks like...
./next.sh 1

./compile.sh 1 prelude
# If any fixes need to be done separately / after the fact
# ./apply.sh 1 prelude ffi
./pr.sh 1 prelude
     # Q1: Choose the actual repo
     # Q2: Choose your fork
     # Q3: Choose 'Submit'

# Once the PR is merged...
echo "prelude" >> finished-dependencies.txt
./mkLibDeps.sh
# Do the next repo until finished
```

[./init.sh](./init.sh) sets up all the tools you need to make the scripts work.

[./forkAll.sh](./forkAll.sh) forks all repos to your account, clones them to a local folder, and applies all updates to each repo in a consistent manner.

[./next.sh](./next.sh) sees which package(s) can be updated since all their dependencies have been updated.

[./compile.sh](./compile.sh) compiles one repo and verifies that it builds, its tests pass, and any linting is checked.

[./apply.sh](./apply.sh) applies a single change to one repo. It's used to apply any one-time fixes if `forkAll.sh` missed it previously due to a bad script.

[./pr.sh](./pr.sh) opens a PR using the [GitHub CLI tool, gh](https://github.com/cli/cli) with a consistent title, message body, labels, and backlinking to the tracking issue.

[./mkLibDeps.sh](./mkLibDeps.sh) regenerates the `libDeps.txt` file, so you can know which libraries have been unblocked now that their dependencies have been updated.

When setup correctly, the project structure should look like this:
```
ps-libs/
  0.15/
    init.sh
    ...
  purescript/
  purescript-contrib/
  purescript-node/
  purescript-web/
```
