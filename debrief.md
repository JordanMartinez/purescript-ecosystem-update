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
- The above issue was especially problematic because `contrib` libraries changed their default branch from `master` to `main`. Thus, one PR updated dependencies to `master`, which still referred to `v0.13.x` dependencies rather than `main`, which had been updated to `v0.14.0`.

### Lack of a clear dependency graph between packages, including test dependencies

- Harry's list (based on Gary's old script?)
- Jordan's list (based on a package-set)
- while both lists were useful in tracking down which repo to do next, neither included a package's test dependencies. For example, even though `purescript-validation` was something that should have been easily updated early in the process, its test dependency on `purescript-quickcheck` was much farther down the line. Thus, it was the second- or third-to-last package we updated.

### Lack of getting a timely review or responding to PR feedback in a timely manner

- Due to the above Bower issue, we could only update a few libraries at a time. If these libraries

### Lack of a single tracking issues to which all other issues backlinked

- initial issue listed all repos with checkboxes
- issue length became a problem as one could no longer see all PRs submitted and whether they had been merged or not

### Too many breaking changes to do in one breaking PS release

- getting `v0.14.0` out sooner became more important than adding another breaking change
- some changes were not merged because of a few reasons:
    - no one reviewed the PR
    - disagreement among core contributors about whether something should be done / how it should be done
    - lack of expertise in an area to know whether such changes were correct and appropriate