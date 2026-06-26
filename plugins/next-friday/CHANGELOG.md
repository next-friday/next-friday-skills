# @next-friday/next-friday

## 0.11.12

### Patch Changes

- d5b4125: Factor the rules and disciplines the skills share into canonical references, so they are stated once instead of copy-pasted and cannot drift. A new `sync-skill-references.sh` mirrors the script-sync pattern (additive: it refreshes shared copies, never touches a skill's own references) with a `validate:references` CI gate. `references/shared-tracker-safety.md` now holds the shared-tracker authorization rules that blueprint and implement both enforce; each skill keeps its own critical inline gate (implement its issue-number and claim checks, blueprint its convergence and premise gates) and points at the shared doc for the common rules. `references/verification.md` and `references/debugging.md` hold the verification and debugging disciplines that implement and rebut share; each skill references them by name and keeps only its own application layer. No authorization gate is removed or weakened.

## 0.11.11

### Patch Changes

- 5220c86: Close the blueprint to implement seam. blueprint now defines a Trivial-tier plan as a single line — a Done criterion plus its Verification command — and implement accepts that one line as a valid plan instead of bouncing a Trivial change for lacking a task list or headers. implement's issue-number gate now accepts an issue this same session created via blueprint as an explicit hand-off, while still rejecting an inferred number (the highest, the most recent, or "the one we were discussing"), so the same-session design-to-build handoff no longer forces a re-type.

## 0.11.10

### Patch Changes

- f5aa428: Deepen the implement and rebut skills from guardrail-bullets into real disciplines. `implement` now debugs a failing gate by method — reproduce, make it fail reliably, isolate one variable, form a falsifiable hypothesis, fix the root cause — instead of "don't flail," keeping the circuit-breaker after about three non-converging attempts. Both `implement` and `rebut` gain rationalization rows drawn from real observed failures: a clean lint count that a syntax error makes lie, a blanket autofixer that mangles a logic file, a non-fast-forward push that should be rebased not forced, a review bot's suggested diff that injected an unrelated path (apply the point, not the literal diff), a string-matching scanner that flags a command the prose only names to forbid, and a bot acknowledgement that is a round-end signal rather than a finding to reply to. `blueprint`'s plan guidance now states a task's Done as an observable behavior or contract that survives a file or line moving, and frames the file map as implementation guidance rather than the definition of done.

## 0.11.9

### Patch Changes

- ea397cd: Give the blueprint skill an idea-stress-test phase so the interview validates whether and why before how. Before resolving any solution decision, blueprint now challenges the premise (should this exist, what breaks without it, the real problem under the stated solution), names and verifies the assumptions the request rests on, and forces a genuine alternative — including "don't build it / do less" — steelmanning the strongest rejected one. Premise and branch-deciding questions are resolved one at a time for genuine understanding rather than batched for a one-"yes" rubber-stamp, while tightly-coupled low-stakes detail still batches with a recommended answer. A new HARD-GATE bars solution design until the premise is validated, and the Trivial tier keeps a one-line premise check.

## 0.11.8

### Patch Changes

- 7c90f4b: Close five system-level gaps found re-auditing the skills. The rebut coverage gate (`verify-coverage.sh`) now resolves the triage account from `REBUT_TRIAGE_LOGIN` and only falls back to `gh api user`, so it works under the GitHub App token the continuous-triage automation recommends — where `gh api user` 403s as a user-to-server endpoint; the automation template now passes that login. The implement fork-PR handoff no longer contradicts itself: on a fork the contributor owns and triages their own PR, while the maintainer keeps the label and merge steps. rebut's in-invocation fix-loop now stops and surfaces to the user after about three non-converging rounds instead of looping unbounded. The reviewer-settle step no longer over-trusts `gh pr checks --watch` for a review-only bot that registers no check run; it pauses and re-gathers regardless of check state. And the closure summary now states "every bot finding (N of N)," listing any human threads separately rather than folding them into the count.

## 0.11.7

### Patch Changes

- 7fd1405: Fix five defects found auditing the skills and their scripts. The rebut Step 6 summary command used an undefined `$OWNER_REPO` and now uses gh's native `repos/{owner}/{repo}` placeholders, so the closure comment posts instead of 404ing. `verify-coverage.sh` no longer crashes on a review comment whose author account was deleted (`.user.login` is null-guarded before `endswith`). `ci-status.sh` only reports `ci: none` when there are genuinely no check rows, instead of when any check's description merely contains the words "no checks." `preflight.sh` anchors its GitHub-remote match so a host like `mygithub.com` no longer passes. And an implement example that wrote `gh issue develop --list` without the required issue number now matches the canonical `gh issue develop <n> --list`.

## 0.11.6

### Patch Changes

- 9a497c8: Close two robustness gaps in the implement and rebut skills found while dogfooding the flow. A push rejected as non-fast-forward — because the remote branch was advanced by a teammate, a release bot's version bump, or a PR "Update branch" merge — now has explicit recovery guidance (`git fetch` then `git rebase` onto the updated tip, then push again, never `--force`), kept distinct from a policy-blocked push, which still stops. And the implement skill's test-first mandate now carves out a change with no executable behavior, such as a documentation or prose edit, which has no failing test to write and is verified through the lint or structural gate instead.

## 0.11.5

### Patch Changes

- 98845f0: Give the rebut skill a runnable wait primitive. The "let the round settle" step said to "wait a bounded interval" without naming a command, and the obvious `sleep` is blocked in interactive Claude Code, so the wait was not reliably executable. It now names `gh pr checks <pr> --watch` — the same primitive Step 5.5 already uses — which blocks until the PR's checks finish, behaves the same interactively and headless, and covers the window asynchronous reviewers post in, with a brief-pause fallback when the PR has no checks.

## 0.11.4

### Patch Changes

- 4a52635: Tighten the rebut and implement flow so one logical review cycle stops fanning out into several CI runs and rework loops. `rebut` now lands every fix of a round in one commit and push instead of one per finding, and waits a bounded interval for asynchronous reviewers to settle before triaging, so a multi-reviewer round is handled as a single pass. `implement` no longer lets a blanket autofixer rewrite a non-trivial logic file (it can introduce syntax errors and low-value boilerplate a reviewer flags) and confirms a file parses with the language's parse or compile check before trusting a lint count, and it now detects an unrelated dirty typechange or symlink before the commit loop and stashes it once rather than letting a stashing pre-commit hook silently revert it on every commit. `blueprint` now requires approach-level choices (library versus hand-written, architecture latitude) to be settled before heavy work is delegated, and a rename or move task to search the repo for the old path during planning so stale references across config, imports, and docs are fixed in the same change rather than at push, one gate at a time.

  The same pass makes the skill prose stack-agnostic. The skills assume only git, GitHub, the `gh` CLI, and an optional AI reviewer, so guidance that had quietly framed the JavaScript/TypeScript toolchain as the default — naming `eslint.config`/`tsconfig` as "your" config, `pnpm-workspace.yaml`/`turbo.json` as the only way to find a monorepo target, and a fixed lint/type-check/test/build gate set — now reads as one ecosystem among many: it points at "the repo's config/gates/runner, whatever the stack" and gives cross-language examples (Node, Cargo, Go, Gradle, Bazel) rather than Node alone, so the skills apply cleanly in a repo of any language.

## 0.11.3

### Patch Changes

- 103a5a6: Stop `rebut` from silently dropping review replies. The skill posted replies in a tight loop and trusted each post command's own success line, so GitHub's secondary rate limit could drop most replies while the run still reported "all threads answered". Two new scripts back the reply step: `post-reply.sh` paces each post and confirms it persisted by reading the created reply id back from the API response (retrying with backoff when throttled), and `verify-coverage.sh` re-queries the PR after triage to assert every bot finding got a reply from the triage account, printing `answered N / M` and failing when any finding is unanswered. A new HARD-GATE forbids claiming the round is done from post output alone, and the async guidance now makes the continuous-triage automation the recommended default for any PR that draws more than one reviewer.
- 103a5a6: Ship each skill's helper scripts with the skill so they work under a standalone `skills` CLI install, not only a plugin install. The skills referenced their helpers as `${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh` from the plugin root; a standalone install copies only the skill's own directory and never sets `${CLAUDE_PLUGIN_ROOT}`, so every call broke. Helpers are now referenced via `${CLAUDE_SKILL_DIR}/scripts/<name>.sh` (resolves under both install paths) and each skill carries its own `scripts/` directory. The canonical scripts stay the single source at `plugins/next-friday/scripts/`; `scripts/sync-skill-scripts.sh` generates the per-skill copies and the new `validate:scripts` gate fails CI on drift.

## 0.11.2

### Patch Changes

- 2f0c63f: Guard shared trackers against autonomous artifact creation. `blueprint` and `implement` now assume the GitHub tracker is shared by parallel agents unless the user says otherwise: they require an explicit per-artifact confirmation before creating or claiming any issue, branch, or PR; refuse to infer an issue target from a bare `/implement` or topic resemblance; and never touch an artifact the session did not create. The `SessionStart` hook is reworded to be advisory and subordinate to the user's instructions, CLAUDE.md, and saved feedback rather than unconditionally pushing issue/PR creation.

## 0.11.1

### Patch Changes

- 3af2c06: fix(skills): ship skill helper files so installs resolve them

  `rebut` referenced `docs/continuous-triage.md`, which lived at the repository root, outside the packaged plugin, so every install resolved a dead link. The reviewer-subagent prompts that `blueprint` dispatches sat as loose files in the skill root. Move all of them under each skill's `references/` directory and repoint every reference. `validate-skills.sh` now resolves `references/<file>.md` paths so every referenced helper is gated at its real location, and its dead-weight scan covers `references/` so an unreferenced helper cannot ship unnoticed.

## 0.11.0

### Minor Changes

- c31e477: feat(skills): add shared script library and wire rebut

  Introduce a portable shell-script library at `plugins/next-friday/scripts/` (bash + git + gh only, gh's built-in `--jq`, graceful degradation) with `preflight.sh` (gh-auth + GitHub-remote gate), `gather-review.sh` (paginated reviews + inline comments so findings are never fabricated or dropped), and `ci-status.sh` (deterministic green / failing / none classification). The `rebut` skill now invokes these at Preflight, Step 1, and Step 5.5 instead of inlining the commands. `validate-skills.sh` now asserts every `SKILL.md` `${CLAUDE_PLUGIN_ROOT}/scripts/*.sh` reference resolves to an executable script.

  Also hardens `rebut` triage coverage — a lesson surfaced while triaging this PR: no gathered finding is left without a reply (silence reads as un-triaged and makes a human re-invoke the skill, looping), and Step 6 now posts a triage-summary comment on the PR conversation that closes the review summaries and gives a human visible proof the round was handled.

  Adds `pr-template.sh` (locate and print the repo's PR template) and wires all three skills to the library: `blueprint` and `implement` call `preflight.sh`, `implement` also calls `pr-template.sh` and `ci-status.sh`, and `rebut` uses all three. `title-lint.sh` and `issue-template.sh` were deliberately dropped — they parse local commitlint/YAML config that needs a non-portable `jq`/`yq`, and the model reads such config more robustly than a bash grep-hack would, so scripting them adds fragility, not anti-hallucination value.

## 0.10.0

### Minor Changes

- 23eb68f: feat(blueprint): deepen issue bodies into precise specs

  Blueprint now records a depth set (decision log, file map + reuse callout, verification, out-of-scope) for Standard/Large issues, with conditional contracts, global constraints, and prior-art added only when they carry content — never as empty headings. The handoff replaces the absolute "code in the PR" rule with a code-sketch policy (sketch only to pin ordering, an exact shape, a hard algorithm, or a public-API surface) and adds per-task Consumes/Produces contracts, a Verification line, and task right-sizing. A two-layer body-versioning rule (GitHub native edit history plus an in-body version banner) lets readers return to an earlier design. Trivial-tier behavior is unchanged.

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
