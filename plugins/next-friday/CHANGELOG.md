# @next-friday/next-friday

## 0.1.0

### Minor Changes

- b6fce4d: Initial release: two issue-driven development workflow skills for Claude Code.

  - `blueprint` — design interview that records the approved design in a GitHub issue (or a committed spec document when the work needs one) plus an implementation plan
  - `implement` — turns an approved issue into a linked branch, gated commits, a template-driven pull request, and a green-CI verification step

### Patch Changes

- d7643d7: Polish `blueprint` and `implement` to release quality: handle the `gh pr checks --watch` zero-checks case without a false-failure loop, add squash-merge rebase guidance for stacked branches, cover fork PRs and no-write-access fallbacks, STOP gracefully when `gh` is missing or the repo is not on GitHub, fix the blueprint cross-references and the spec-mode plan-file handoff, and cut the redundant flow diagram and principles list.
