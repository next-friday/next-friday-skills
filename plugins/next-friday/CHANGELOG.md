# @next-friday/next-friday

## 0.2.0

### Minor Changes

- 53737c6: Harden the blueprint and implement skills from a real end-to-end run and an expert audit, for safer worldwide use.

  Blueprint:

  - Rewrite the description to triggers-only so the skill body is read instead of a workflow summary being followed.
  - Add a convergence gate: never create or comment a GitHub artifact until the design is approved in chat (stops early-recording churn).
  - Add a "root context first" interview step (end goal, prior art, repo nature) before any tooling question.
  - Require self-contained artifacts — never reference another repository inside an issue, spec, or PR.
  - Relax one-question-per-message to batching tightly-coupled questions.
  - Generalize org-specific assumptions (title convention discovery, the ~400-line figure as a heuristic).

  Implement:

  - Rewrite the description to triggers-only.
  - Stop and hand off (never retry, force, or reroute) when a push or PR is blocked by a guard hook or policy.
  - Treat protected/owner-owned files as deferrals documented in the PR, not writes to retry.
  - Make gate discovery monorepo-aware: run gates in the package that owns the changed files and confirm they exercised the change.
  - Document an opt-in, permission-preserving way to reduce prompts; the skill never weakens permissions or bypasses guards.

  Both skills add `license` and `compatibility` frontmatter for spec compliance.

## 0.1.0

### Minor Changes

- b6fce4d: Initial release: two issue-driven development workflow skills for Claude Code.

  - `blueprint` — design interview that records the approved design in a GitHub issue (or a committed spec document when the work needs one) plus an implementation plan
  - `implement` — turns an approved issue into a linked branch, gated commits, a template-driven pull request, and a green-CI verification step

### Patch Changes

- d7643d7: Polish `blueprint` and `implement` to release quality: handle the `gh pr checks --watch` zero-checks case without a false-failure loop, add squash-merge rebase guidance for stacked branches, cover fork PRs and no-write-access fallbacks, STOP gracefully when `gh` is missing or the repo is not on GitHub, fix the blueprint cross-references and the spec-mode plan-file handoff, and cut the redundant flow diagram and principles list.
