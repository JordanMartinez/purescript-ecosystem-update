# Workflow

1. Login to GitHub using the GitHub CLI tool

```bash
gh auth login
```

2. Change the default git protocol from `https` to `ssh`

```bash
gh config set git_protocol=ssh
```

3. Modify the `./setupRemote.sh` file
     - Change the `GH_USERNAME` variable to use your GitHub username
     - Change the `PS_TAG` variablel to whatever is the latest.

4. Look at [`libDeps.txt`](./libDeps.txt) to see what to work on next. See also the [purescript repo's "update ecosystme to v0.14.0" issue](https://github.com/purescript/purescript/issues/3942)

5. Claim the package on the issue

6. Setup the repo and automate the boilerplate updates

```bash
./setupRemote.sh <packageName>
```

7. Test whether code compiles

```bash
./compile.sh <packageName>
```

8. Navigate to the created directory

```bash
cd ../purescript-<packageName>
```

9. Create a PR via `gh` CLI tool

```bash
gh pr create
# 1st question: Choose the `purescript/purescript-<packageName>`
# 2nd question: Choose your repo
# For title: Update to v0.14.0-rc3
# For body
## Press `e` to open text editor
## Write: `Backlinking to purescript/purescript#3942`
## Press CTRL+O
## Press CTRL+X
# 3rd Question: Choose 'Submit'
```

10. Look at the repo to see whether any issues/PRs should also be merged.
