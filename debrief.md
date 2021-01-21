# Debrief

`v0.13.8` was released on May 23, 2020. `v0.14.0` was released on `???, 2021`. Below summarizes the issues we experienced along the way and tries to provide an explanation for what happened, why, what we can fix, and what we can't.

## The Larger Context

The initial Coercible PR was [first created on May 4, 2018](https://github.com/purescript/purescript/pull/3351#issue-185918529). After some initial feedback, [9 months passed](https://github.com/purescript/purescript/pull/3351#issuecomment-470342192) before the next round of feedback occurred. The [next three months (March to June)](https://github.com/purescript/purescript/pull/3351#issuecomment-514778214) saw activity before no activity occurred again. While the PR was finished, it was not [merged until Feb 2020](https://github.com/purescript/purescript/pull/3351#event-3019914938). Harry clarified in Slack that they didn't merge the Coercible PR immediately because at the time they weren't certain whether the next PureScript release should be a breaking one or not.

[Based on the first commit in his PR](https://github.com/purescript/purescript/pull/3779/commits/83fedaa4b3152fed751e2ff63c5c39c2cbcebc2d), Nate started working on the PolyKinds feature in August 2019 before [announcing it in October 2019]](https://discourse.purescript.org/t/help-getting-polykinds-over-the-line/1025/). He finished the gist of it around Febuary 2020. The last few weeks ironed out a few things and it was finally merged in early [March 2020]](https://github.com/purescript/purescript/pull/3779#event-3129505043).

In Jan 2020, we learned that [the Bower registry would no longer accept new package submissions](https://discourse.purescript.org/t/the-bower-registry-is-no-longer-accepting-package-submissions/1103). While we knew we would need to build our own registry at some point, this forced the issue. For the rest of the year, @f-f spearheaded the design of the registry we would use to replace `bower`. The design is mostly finished, but the implementation hasn't yet been completed. I'm not yet sure what design issues we may come across as we implement it.

Mid-March 2020, COVID became a pandemic and things got... really weird. I'm not sure how much that affected core contributors and the rest of the community.

From March 2020 to September 2020, various issues with the Coercible feature (and the interplay between Coercible and PolyKinds, I believe) were found and fixed, resulting in (at the time of writing) 16 PRs.

Travis CI was being used in all `core`, `web`, `node`, and `contrib` PureScript libraries besides the compiler repo. [Using this post's timeline for context](https://www.jeffgeerling.com/blog/2020/travis-cis-new-pricing-plan-threw-wrench-my-open-source-works), Travis CI announced that it would no longer offer its free tier for open source projects. Following Spago, we chose GitHub Actions as the CI to use as its replacement, migrating all of the above repos to GitHub Actions.

We have many small modular libraries that make up the `core`, `web`, `node`, and `contrib` libraries. Due to the resulting dependency graph between them, we can only update a few libraries at a time and we have to submit many PRs to update the entire ecosystem. A single change that needs to be made across all of them (e.g. update dependencies to latest version / `master`; update CI to be consistent across all of them; etc.) can be quickly bottlenecked if a core contributor does not approve and merge the PR.

Lastly, it's our policy to do breaking changes in `core`, `contrib`, `web`, and `node` libraries at the same time as breaking language changes, so that fixing these changes can be batched together rather than be an ongoing activity. Unfortunately, many of these libraries haven't been receiving the maintenance attention that they need. Thus, we paid a "maintenance debt" in this release cycle.

## Specific issues

Ordering these in a chronological way, these are the issues we came across.

### Bower's solver chooses the wrong version

- When we were originally updating all libraries to `v0.14.0`, we needed to change their dependencies to the `master` branch. If any one of them was not on `master`, including test dependencies, then a version of a library that was still on `v0.13.x` and all of its transitive dependencies would be pulled in. As a result, the code would often not compile.

### Lack of a clear dependency graph between packages, including test dependencies

- Harry's list (based on Gary's old script?)
- Jordan's list (based on a package-set)
- while both lists were useful in tracking down which repo to do next, neither included a package's test dependencies. For example, even though `purescript-validation` was something that should have been easily updated early in the process, its test dependency on `purescript-quickcheck` was much farther down the line. Thus, it was the second- or third-to-last package we updated.

### Lack of getting a timely review or responding to PR feedback in a timely manner

- Early in the process of updating `core` libraries to `v0.14.0`, there were multiple times where one library towards the "root" of the dependency graph (i.e. very few dependencies on anything else) can hold up all of its dependent libraries for two reasons:
    - Either a PR was submitted but a core contributor takes a long time to approve it, much less respond with feedback on what needs to be changed to get it merged
    - Or a PR was submitted and changes were requested but the original person took a long time to make such changes (e.g. vacation, didn't see it, schedule cycles didn't "line up")

While I can't recall exactly how long it took, I recall `core` libraries taking a month or so (e.g. all of October) just to update 30 repos or so because of this issue. Most of the changes needed to update the library were trivial (e.g. updating bower, pulp, psa, and depenedencies).

### Lack of a single tracking issues to which all other issues backlinked

- Early on in [purescript/purescript#3942](https://github.com/purescript/purescript/issues/3942), we originally created a checked list of linked repos. After a while, the issue's length made it difficult to determine which repos had PRs submitted, which of those PRs were merged, and what remaining work we had to do. Numerous comments throughout the issue made it hard to know the status of what to do. Part of the issue here is that GitHub does not provide tooling for the kind of mass-change we're doing in the ecosystem
- Over time, we started creating an issue to which all other PRs would backlink. This made things significantly easier to see which PRs had been submitted, were merged, and still had work to be done.
- Jordan thinks we need two GH issues to fully resolve this pain: one to act as a 'backlinking-target' issue for PRs and other issues and a second one to be used for discussion. However, a more appropriate tool would be better (e.g. a spreadsheet), but Jordan isn't sure what tool would work that's cheap and integrates with GitHub.

### We started migrating `web`/`node` libraries from `bower` to `spago` across multiple repos and then reverted that change

This was my (Jordan's) fault. `contrib` libraries had changed their default branch from `master` to `main`. Thus, one PR I submitted that updated dependencies to `master`, which still referred to `v0.13.x` dependencies rather than `main`, which had been updated to `v0.14.0`. Thus, Bower was pulling in `v0.13.x` transitive dependencies and I could not determine why that was happening. I led other contributors to migrate from Bower to Spago. Harry pushed hard against. I investigated the issue further and found the `master`/`main` issue. Once that was fixed, we reverted this migration work again, wasting time and energy.

### Package sets in the `package-set` repo don't automatically update when `contrib` repos are updated

`contrib` libraries made the decision to switch to `spago` before we started updating the `v0.14.0` libraries. When updating the `contrib` repos to `v0.14.0`, we sometimes changed the list of dependencies it had. However, the `packages.dhall` file in the `package-sets` repo wasn't updated unless we also updated its corresponding entry. This wasn't hard to fix, but could complicate CI. If `foo` pulled in `bar` (as defined in the `packages.dhall` file in the `package-sets` repo) rather than `bar` (as defined in the `purescript-bar` repo), CI would complain and we'd have to figure out why. Fortunately, this was rarely a problem.

### Numerous `contrib` repos depended on a repo outside of the `contrib` libraries

`core` libraries have a policy that they do not depend on non-`core` libraries. While this can make some things inconvenient, it makes a huge difference when updating libraries due to a breaking change in the compiler.

`contrib` does not currently follow such a policy, and the pain of that choice revealed itself in this release cyle. There were test dependencies were outside of `contrib` maintainers' control (e.g. `purescript-naturals`, `purescript-spec` or `purescript-test-unit`). For `naturals`, we dropped the dependency and updated the code. For the test libraries, we had to bootstrap a workaround using `ReaderT String Aff a`, so that we did not touch the tests but still got the nice test reports provided by those other libraries.

`contrib` should implement a similar policy as `core` to reduce this problem in the future.

### We had to migrate `core`, `web`, and `node` libraries from Travis CI to GitHub Actions

Travis CI suddenly announced their free tier was gone. @f-f strongly encouraged us to use GH Actions due to it working "surprsingly well" for him with `spago`. We followed suit.

`bash` scripts helped us automate a lot of this. We also made a mistake in the initial script, so we had to use a second one to fix issues done by the first one.

### Too many breaking changes to do in one breaking PS release

- getting `v0.14.0` out sooner became more important than adding another breaking change
- some changes were not merged because of a few reasons:
    - no one reviewed the PR
    - disagreement among core contributors about whether something should be done / how it should be done
    - lack of expertise in an area to know whether such changes were correct and appropriate

### Morale of _new_ contributors dropped three times when...

- we realized that `web` and `node` libraries would need to be updated, too.
    - "YES! `core` libraries are finally compiling on `v0.14.0`. `contrib` libraries were, too. That means we're almost done, right!? 😁 Awesom--Wait! WHAT!? We still have TWO more GitHub organization's worth of libraries to update? Bleh..."
- we realized that, now that the ecosystem compiled on `v0.14.0`, it was time to merge breaking changes and fix their ripples throughout the ecosystem
    - "Ok, NOW all libraries are done. We can now-- Wait, WHAT!? We still have to implement a breaking change in `purescript-gen`? What!? I can't get CI to pass until I've fixed a dependency's usage of some code that was broken in a recently merged PR unrelated to this one? Double bleh..."
- we realized we would have to write changelogs for 4 GitHub organizations' worth of repositories
    - "Ok, NOW all libraries are done and all but a few 'breaking changes' PRs are pending review. Not much else is--WAIT! ARE YOU KIDDING ME!? WE HAVE TO WRITE CHANGELOGS DOCUMENTING EVERYTHING WE'VE BEEN DOING IN THE PAST 4 MONTHS!? THAT'S LIKE 200 REPOSITORIES, MAN! 😭 ... well... at least we can automate parts of this via a script and generate an initial changelog using GitHub releases. Oh, and we need to update all repos' CI to `v0.14.0-rc5`. Oh, and.... And.... Blehdy bleh..."

On a side note, I'd say the gratitude _new_ contributors had for _current_ maintainers who have been doing this for a while increased greatly. Wow... the core contributors have done a LOT of behind-the-scenes work.
