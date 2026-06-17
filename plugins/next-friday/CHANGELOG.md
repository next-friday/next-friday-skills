# @next-friday/next-friday

## 0.9.0

### Minor Changes

- aae6ff6: Make the skills global-ready: generic at the tool layer, human-aware, beginner-friendly, and honest about continuous triage.

  - Keep the universal Git/GitHub/CI substrate concrete but describe specific review and CI tools generically, named only as hedged examples, per the "discovered, not assumed" promise.
  - `rebut` now handles human reviewers, not only bots: the verification core applies to any reviewer, but for a human it collaborates instead of refuting and drafts replies rather than auto-posting.
  - `rebut` states plainly that a skill cannot watch a PR over time and points to `docs/continuous-triage.md`, an opt-in GitHub Action template that re-invokes triage on each review round until the PR closes.
  - README gains a plain-language "What this does for you" for newcomers; the agent-facing `SKILL.md` files stay precise.

## 0.8.0

### Minor Changes

- 609bca7: Harden the workflow skills and their tooling from a full retrospective and audit.

  - `blueprint` defines the unit of work as one logical change — code, tests, docs, and config in a single PR — with an explicit batch-vs-split rule, and tells sub-issues to branch independently off the default branch rather than stack under squash-merge.
  - `implement` works independent tasks in dependency order without fanning one branch out to parallel subagents, hands off to `rebut` for the AI-review round instead of duplicating its triage, runs a language-appropriate loadability check on any changed file the repo's gates do not cover before committing, and reconfirms before outward writes when the session was scoped local-first.
  - `rebut` attributes replies consistently and triggers right after a push where a reviewer is expected.
  - `validate-skills.sh` gains portable, exact-token sibling and quote handling and no longer fails open on unrecognized hook commands; the unused `drill-skill.sh` is removed and `label-issue-by-type.sh` reads its type list from `.commitlintrc.json`.

## 0.7.0

### Minor Changes

- fabe9dd: Add a SessionStart hook that reminds the agent of the issue-driven workflow at the start of each session, so `blueprint`, `implement`, and `rebut` are reached for instead of skipped. The reminder is a short pointer to the skills rather than a copy of their bodies, keeping session context light.
- c3cec17: `rebut` now opens every in-thread reply with a consistent attribution line that marks the comment as automated triage by the agent, posted through the maintainer's account rather than written by them personally. This keeps automated triage from being mistaken for the maintainer's own review, and points to a bot or machine account as the stronger identity when one is available.

## 0.6.0

### Minor Changes

- 2a769f7: Add the `rebut` skill: triage AI code-review findings on a pull request — verify each against the real code, fix the valid ones, refute false positives with evidence, and reply per thread marked as automated triage. Reply-only; the human resolves the threads.

## 0.5.0

### Minor Changes

- 5f24078: blueprint now records a structured implementation plan in the issue body: a Goal/Architecture/Tech-Stack header, a file map, ordered tasks (files + intent + an explicit Done criterion) at task altitude, a "no placeholders" rule, and a plan self-review (spec coverage, placeholder scan, name consistency). A new plan-issue-reviewer-prompt.md adds a Buildability review pass, and the visual companion gains a decision test.

## 0.4.0

### Minor Changes

- d19bd5a: implement now carries the execution rigor it described only loosely: a test-first rule with the common excuses rebutted, a verification gate (no completion claim without fresh command evidence), a root-cause debugging method for failing gates with a stop-after-three-fixes rule, a self-review of the diff against the plan before the PR, a clean-baseline check on the fresh branch, and a disciplined stance for responding to PR review feedback.
- e8a4f1c: blueprint now stages the converged design to a temp Markdown file and waits for the user to approve that draft (which they can forward to a human reviewer) before creating the issue. The post-record gate becomes a confirmation rather than a second review, and the recording flow now updates an existing issue's body instead of commenting the design onto it.

## 0.3.0

### Minor Changes

- fba9ec8: blueprint now treats the GitHub issue body as the single source of truth: the design and the implementation plan live in the body and are rewritten as the design evolves, instead of accreting across append-only comments. The committed-file "Spec Document Mode" is removed, and implement reads the design and plan from the issue body.

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
