---
name: implement
description: "Use when an approved GitHub issue whose design and plan are already agreed is ready to build and ship, or on requests like 'implement issue #N', 'start working on the issue', branching from an issue, or getting the gates or CI green."
license: MIT
compatibility: "Requires git, the GitHub CLI (gh) authenticated, and a GitHub remote"
argument-hint: "[issue-number]"
---

# Implement

Take an approved GitHub issue and deliver it: branch → code → gates → PR → green CI. This is the execution half of the workflow; the design and plan were settled in the issue by the **blueprint** skill.

```text
issue (approved design + plan)
  └→ branch (from the issue)
       └→ write code (task by task, TDD)
            └→ run FULL gates (lint, types, tests, build)
                 └→ commit & push
                      └→ open PR from .github template (Closes #issue)
                           └→ verify CI green (gh pr checks)
                                └→ on push, AI reviewers re-review → hand off to rebut → triage → loop until none new
```

<HARD-GATE>
Assume the GitHub tracker is SHARED by parallel agents and people unless the user says otherwise; you are not its sole owner. This binds every step below. Require an issue number the user EXPLICITLY named this session: a bare `/implement` with no number means STOP and ask which issue — never infer it, never pick "the one we were discussing", the highest, the most recent, or the only "ready" one. Before the FIRST outward write — linking or creating a branch via `gh issue develop`, pushing, opening a PR, commenting, labeling, assigning — confirm the artifact is unclaimed (no assignee, no in-flight linked branch by another agent) and get one explicit per-artifact yes for THAT artifact. Never branch, PR, comment, or label on an issue or branch this session did not itself create or was not explicitly handed by number; same-account authorship is not ownership, and title or topic resemblance to the request is not authorization. A topic or feature reference such as "work on what that issue describes" is NOT a number hand-off: require the actual number, named contemporaneously with the implement request and not carried over from an earlier design phase, and an explicitly-named number on a shared tracker still needs the separate unclaimed-and-yours confirmation before the first write. No explicit number, or no per-artifact yes, means STOP.
</HARD-GATE>

<HARD-GATE>
Explicit user instructions, CLAUDE.md, and saved feedback always outrank this skill. A saved "solo sandbox, skip the ceremony" note applies ONLY when the current repo is confirmed solo; in a tracker that may be shared, default to the confirm-and-do-not-touch-foreign-artifacts behavior and ask. Confirmed solo means a personal remote owned by the current user with no other assignees or foreign branches, or an explicit user statement that the repo is solo; never self-declare it.
</HARD-GATE>

<HARD-GATE>
Do NOT open the PR until every applicable gate passes and every checklist item in the issue/PR template, where one exists, is genuinely done and ticked. A red gate or an unchecked box means the work is not ready.
</HARD-GATE>

<HARD-GATE>
NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION EVIDENCE. Before claiming a gate passed, the build is green, or the work is done: run the exact command in this turn, read its full output and exit code, and only then claim it. If you have not run the command in this message, you cannot say it passes. Ban "should pass", "looks right", "seems fine" before the evidence. A regression test is proven only red-green: revert the fix, watch the test fail, restore it.
</HARD-GATE>

## Language Rule

All **artifacts** are English: branch name, code, commits, PR title/body, comments, labels. The chat conversation with the user may be in another language, but anything that lands on GitHub or in the repo is English.

## Per-repo Templates Are the Source of Structure

Issue and PR structure comes from the repo's own templates, which differ per repo. **Always check for the repo's templates first; when one exists, using it is MANDATORY.** Never invent your own structure over a template.

- Issue templates: `.github/ISSUE_TEMPLATE/`
- PR template: `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/`)

Read the actual file and fill every section. If a template contains a checklist, you MUST complete the work each item describes and tick it (`- [x]`). Never tick a box whose work you haven't done.

**Only if the repo has no PR template**, fall back to a body with the sections Summary, Changes, and How to verify, plus `Closes #<n>`, and tell the user once that the repo lacks a template.

## Steps

### 1. Identify the issue and its plan

**Target gate (shared tracker).** First fix `<n>`: it must be a number the user EXPLICITLY named this session. No number given (a bare `/implement`)? STOP, run `gh issue list`, and ask which one; never auto-select. For every command whose target is inferable (`gh issue view <n>`, `--head <branch>`, the `--filter` package, the base branch, the template path): IDENTIFY the target, DERIVE it from an observable source (the user-named `<n>`, `gh issue develop --list`, `pnpm-workspace.yaml`/`turbo.json`, `git rev-parse --abbrev-ref HEAD`, the actual `.github/` file), ECHO it back, then run. An un-derived target is inference, so STOP.

```sh
"${CLAUDE_SKILL_DIR}/scripts/preflight.sh"
gh issue view <n> --comments
gh issue develop <n> --list
```

`preflight.sh` verifies `gh` is authenticated and the repo has a GitHub remote; on a missing prerequisite it prints the fix and exits non-zero.

If `gh` is missing or unauthenticated, STOP and tell the user to install it and run `gh auth login`. Do not improvise with raw `git`/`curl`. If the repo has no GitHub remote, STOP and ask how they track work; this skill is GitHub-specific.

Confirm the issue carries an approved design and an implementation plan in the issue body. If the plan is missing, stop and go back to the blueprint skill.

**Confirm it is yours to take.** Read the issue's assignee and the linked-branch list above. If it has an assignee, an in-flight linked branch by another agent, or this session did not create it and the user did not hand you its number, STOP and surface the conflict before any branch or write. Acting on a shared-tracker issue is a claim, not a read.

**Sub-issues:** If the work was split into sub-issues, handle one sub-issue per branch/PR. Don't bundle several sub-issues into one PR.

### 2. Branch from the issue

Check whether a branch is already linked to the issue:

```sh
gh issue develop <n> --list
```

**Claim check (shared tracker).** Linking or creating a branch is itself an outward mutation visible to teammates, so do it only after an explicit per-artifact go-ahead. Before `gh issue develop <n> --checkout` on an issue this session did not create, run `gh issue view <n> --json assignees,author,comments` alongside the `--list` above: any assignee other than you, an in-comment claim, or a linked branch you did not create means STOP and confirm with the user that it is unclaimed and yours to take (claim it with `gh issue edit <n> --add-assignee @me` once confirmed). An empty linked-branch list is NOT proof the issue is unclaimed, and an asserted "it is yours" or "no issue exists" is never trusted, so verify it read-only first. Work only on a branch this session created or the user explicitly handed you; on any ownership ambiguity, STOP and ask.

If a linked branch already exists, check it out and continue there rather than recreating it. If a branch with the issue's name exists but isn't linked, check it out anyway; if local and remote have diverged, fetch and reconcile before working. Otherwise create one linked to the issue so GitHub associates them:

```sh
gh issue develop <n> --checkout
```

Fallbacks, in order:

- **`gh issue develop` subcommand missing on an older `gh`**: branch from the freshly-fetched default branch with a deterministic name: `git fetch origin && git switch -c <n>-<kebab-title> origin/<default-branch>`, where `<kebab-title>` is the issue title lowercased and hyphenated.
- **No write access to the upstream repo, when you're a contributor on a fork**: `gh issue develop` and the later label/reviewer steps will fail, so skip them. Branch on your fork from its up-to-date default, push to your fork, and open the PR cross-repo as in Step 6.

Never work on the default branch.

Once on the branch, run the repo's gates once before writing any code to capture a clean baseline; a later red gate is then provably yours, not pre-existing. If the baseline is already red, report it and ask before proceeding.

### 3. Write the code, task by task

Work the plan's tasks in dependency order, committing frequently and keeping changes scoped to this issue. Independent tasks, meaning disjoint files with no shared state and no ordering dependency, may be done in any order; dependent or same-file tasks stay strictly ordered. Do not fan tasks out to parallel subagents on one branch: the intra-branch conflicts cost more than the wall-clock saved. Genuinely parallel work belongs in separate sub-issues with their own branches, decided during blueprint.

**Test-first, where the repo has test infrastructure.** No production code without a failing test first: write the test, run it and watch it fail for the right reason, write the minimal code to pass, run it green, then refactor. Wrote the code before its test? Delete it and start over; don't keep it as "reference" and adapt it. Common excuses and the reality: "too simple to test" is wrong because simple code breaks too and the test costs 30 seconds; "I'll test after" is wrong because a test that never watched the bug fail proves nothing; "I already tested it by hand" is wrong because ad-hoc isn't repeatable, and if it isn't a committed test, it didn't happen. If the repo has no test infrastructure, say so in the PR body; never fabricate tests.

- **Match the repo's commit convention.** Check `git log --oneline -20` before your first commit; if the repo uses Conventional Commits (`feat:`, `fix:`, ...), follow it. Don't invent your own style.
- **Keep the PR reviewable.** If the diff grows past roughly 400 changed lines, stop and propose splitting into sub-issues, each with its own PR. Oversized reviews get rubber-stamped; small PRs get real review.
- **Branch from the up-to-date default, not from another open PR's branch.** Independent PRs that each branch off the default integrate cleanly; a stack of branches does not. Stack only when a change has a hard dependency on unmerged work, and never under squash-merge, where the parent landing rewrites history and forces the child into a duplicate-content conflict cascade. If you are rebasing and force-pushing a child after its parent merged, that churn is the signal the work should not have been stacked: as a one-time recovery re-point it with `git fetch origin && git rebase --onto origin/<default-branch> <old-base-sha> <this-branch>` then `--force-with-lease`, and from then on sequence the work: land one, open the next from the merged default.
- **A planned change may be protected.** A `Write`/`Edit` is denied by a hook, the path is owner-owned via CODEOWNERS or a protected config, or policy forbids touching it. Treat the protection as authoritative: do NOT retry the write, escalate permissions, or route around the guard. Leave the file untouched, implement everything else, and record the deferral explicitly to the user and in the PR body as `Deferred: <path> is protected, needs owner action`. A protected file is a deferral, not a blocker to defeat.

### 4. Run the FULL gates before committing the final state

Discover the repo's gates from where the changed code lives, not just the repo root, and don't assume. In a monorepo the lint/type/test/build scripts often live in the sub-package that owns the files this issue touched, or in a workspace runner such as `turbo.json`, `nx.json`, or `pnpm-workspace.yaml`, not the root `package.json`. Identify the owning package and run its gates through the repo's task runner (e.g. `turbo run lint --filter=<pkg>`, `pnpm --filter <pkg> test`, or the package's local scripts). A root-level script may be absent, run nothing for that package, or falsely pass, so confirm the gate actually exercised your changes before trusting a green result. Run all gates that apply and make them pass:

- Lint
- Type-check
- Tests, running a single test while iterating and the full suite before the PR
- Build

A failing gate blocks the PR. Fix the cause; do not skip, disable, or `--no-verify` around a gate to make it pass.

**When a gate, or later a CI check, fails, debug by root cause and don't flail:**

- Investigate before touching anything: read the actual error and find the cause. No guess-and-retry.
- Change ONE thing at a time and re-run. A burst of simultaneous changes hides which one mattered.
- **After 3 failed fixes, STOP.** Repeated failure, especially surfacing somewhere new each time, means the approach or the plan is wrong, not that fix #4 is around the corner. Step back, question the design, and raise it with the user instead of guessing again.

**A file the repo's own gates don't cover is still unverified, not verified-by-default.** For every file the diff touches that no repo gate exercises, run the cheapest language-appropriate loadability check before committing and read its result this turn. Use `bash -n` or `shellcheck` for shell, a parse for JSON and YAML, `tsc --noEmit` for TypeScript the build skips, and `py_compile` for Python. Only a whole gate the repo genuinely lacks, such as no test setup yet, is exempt; state that absence explicitly in the PR body instead of skipping silently.

**Do not let a blanket autofixer rewrite a non-trivial logic file.** An automatic fixer, such as a linter's fix mode, can turn complex code into a syntax error and pad it with low-value boilerplate, for example empty doc blocks or stub annotations, that a later reviewer flags. Fix findings in logic files by hand, scoped to the finding; reserve autofix for purely mechanical, low-risk reformatting such as import ordering or quote style. And a lint or warning count is only trustworthy on code that parses: one syntax error can make the tool bail and under-report, hiding the file's other findings until the next run. So run the language's parse or compile check, per the loadability checks above, and confirm the file parses before you trust a count or call it clean.

### 4.5. Self-review the diff against the plan

Before committing the final state, re-read the issue's plan and check your diff against it:

- **Every plan task is implemented.** Point to the change that delivers each one, and list any gaps.
- **Nothing extra.** The diff adds only what the plan asked for, per YAGNI: no drive-by refactors, no speculative code, no files the plan never named.
- "Close enough" on the plan is not done. If the diff and the plan disagree, fix the diff. If the plan itself was wrong, update the issue body and say so.

### 5. Commit & push

Commit any remaining changes from gate fixes, then push:

```sh
git add <files this issue touched>
git commit -m "<clear English message>"
git push -u origin <branch>
```

Stage only the files this issue touched. Never blanket `git add -A`/`git add .`, which sweeps in unrelated or untracked files such as build artifacts and temp bodies. On a fork, push to your fork's remote, not `origin` upstream.

**Protect an unrelated dirty file from the commit hook before you commit.** A pre-commit hook that stashes unstaged changes while it runs, a common setup, can fail to restore a file whose type changed, such as a symlink-to-regular-file typechange, so an unrelated work-in-progress file is silently reverted on every commit and has to be restored by hand each time. Before the first commit of the loop, run `git status --short` and look for a dirty entry the issue does not touch, especially a typechange (the `T` status code) or symlink. If one exists, stash it once yourself with `git stash push -- <path>` and restore it with `git stash pop` after the final commit, or surface it to the user, rather than letting the hook eat it on every commit.

**If the push is blocked** by a guard hook, branch protection, or a server-side rule: STOP. Do not retry, do not `--force`, do not `--no-verify`, do not reroute to another remote or rewrite the command to evade the block. The block is the user's policy, not an obstacle to engineer around. Report exactly what was refused and the command, leave the commits intact locally, and hand off to the user to complete or grant the push themselves. A blocked push is an expected stop, not a failure.

### 6. Open the PR from the repo's template

Print the repo's PR template with `"${CLAUDE_SKILL_DIR}/scripts/pr-template.sh"` and fill every section. It writes the template to stdout, lists the options when a `PULL_REQUEST_TEMPLATE/` directory holds several, and exits 3 with a fallback note when the repo has none; in that case use the no-template Summary / Changes / How to verify body above. Write the body to a temp file, since multi-line bodies break inline `--body` quoting:

```sh
gh pr create --head <branch> --title "<English title per the repo's title convention>" --body-file /tmp/pr-body.md
```

- **Always pass `--head <branch>` explicitly.** Without it, `gh` infers the currently checked-out branch, so in a session with more than one active branch the PR silently attaches to the wrong one. **From a fork**, qualify it as `--head <fork-owner>:<branch>` so `gh` opens the PR cross-repo into the upstream.
- **Title follows the repo's enforced convention.** Check for a pr-title validation workflow and the repo's commitlint config; discover the rule by reading the repo, never assume another repo's scheme. A common rule set is conventional `type(scope): subject` validated by commitlint, and **no `#N` in the title**, because squash-merge appends `(#PR)` and an issue ref in the title duplicates on the default branch. Issue refs go in the body only.
- **If PR creation is blocked** by a hook or policy: STOP, exactly as with a blocked push. Do not force or reroute. Report what was refused and hand off to the user to open the PR.
- Body MUST include `Closes #<n>` so merging closes the issue.
- Labels: only apply ones that already exist (check `gh label list`). Reviewers: determine from CODEOWNERS or ask the user, never guess. **On a fork you lack write access**, so skip the label/reviewer steps; the maintainer applies them.
- **Complete and tick every checklist item** in the PR, plus any remaining issue-template checklist. Each ticked box must reflect work actually done.

### 7. Verify CI on the PR

Local gates passing is necessary, not sufficient; the repo's CI and branch protection decide whether the PR can merge.

First see whether the PR has any checks at all, then watch only if it does:

```sh
gh pr checks <pr-number> --watch                            # wait for checks to settle (exits non-zero if none)
"${CLAUDE_SKILL_DIR}/scripts/ci-status.sh" <pr-number>    # classify the settled state
```

`ci-status.sh` prints the rows and a final status line, distinguishing the states by exit code: `ci: green` (0), `ci: failing` (1), a read error (2), `ci: none` (3), `ci: pending` (4).

- **No checks exist** → `ci-status.sh` prints `ci: none` (exit 3). That is NOT a CI failure, so do NOT loop trying to "fix" it. Report "no CI configured", and for a team-owned repo suggest adding it, then stop.
- **All checks green** → CI is clear, but do NOT stop here: green CI is the precondition for the AI-review round below, not the finish line. Report the PR URL and CI status, then handle that round before declaring done.
- **A check fails** → treat it exactly like a failing local gate: debug by root cause (Step 4), fix, push, re-watch. Never hand the PR over for review with red CI.

**After CI is green, the work is not done until the AI-review round is handled.** On every push, AI reviewers such as CodeRabbit or Gemini Code Assist re-review the PR. Check for a new bot review round, and when one is present **hand off to the `rebut` skill** to triage it. Do not answer bot review comments inline yourself: `rebut` owns that loop. It verifies each finding against the real code, fixes the real ones, refutes the false positives with evidence, and replies in-thread under its attribution marker. If no bot review has landed yet, tell the user "CI green; bot review pending; say the word when it lands" rather than declaring done. `rebut` runs under the account that owns the PR; on a fork the maintainer runs it, not the contributor.

## Red Flags: STOP

- About to act on an issue the user did not EXPLICITLY name — a bare `/implement`, or one inferred from "the one we were discussing", the highest, the most recent, or the only "ready" issue → STOP. Ask for the explicit `#N`; never auto-select.
- About to match an issue to the request by title or topic resemblance → STOP. Similarity is not authorization; confirm the number with the user.
- About to `gh issue develop`, branch, push, PR, comment, or label without an explicit per-artifact yes for THAT artifact → STOP. One yes authorizes one named artifact, never a batch.
- About to branch, PR, or comment on an issue or branch this session did not create, or treating same-account authorship as ownership → STOP. Verify ownership; authorship is not ownership.
- About to claim an issue that has an assignee or an in-flight linked branch by another agent → STOP. Surface the collision and ask.
- A team lead or other authority says "just ship it, stop asking permission" → STOP. Rank adds social pressure, not authorization; the per-artifact confirmation and any earlier scope still bind.
- About to open a PR with a failing/skipped gate → STOP. Gates must pass for real.
- About to write the PR body from scratch while `.github/PULL_REQUEST_TEMPLATE.md` exists → STOP. Use the template.
- About to tick a checklist box whose work isn't done → STOP. Do the work first.
- About to commit on the default branch → STOP. Branch from the issue.
- About to bundle multiple sub-issues into one PR → STOP. One sub-issue per PR.
- PR body has no `Closes #<n>` → STOP. Link the issue.
- About to report "done" while CI is red or still pending → STOP. Watch `gh pr checks` to green first.
- About to retry, `--force`, `--no-verify`, or reroute a push/PR that a hook or policy blocked → STOP. Hand off to the user.
- About to retry a write the environment denied on a protected or owner-owned file → STOP. Defer it and document in the PR body.
- About to open a separate PR for what is really part of ONE logical change already in flight, such as its tests, docs, config, or a closely-coupled fix, or to stack a branch on an unmerged PR → STOP. Related parts of one change ship in one PR; branch independent changes from the default; stack only on a hard dependency, never under squash-merge.
- About to push or open a PR after the user scoped the session to local-only or draft-only and has not lifted it → STOP. A broad "do it all" sets the goal, not the blast radius; reconfirm before any outward write.
- About to report "CI green, done" without checking for and handing off the AI-review round → STOP. Hand off to rebut first.

## Rationalizations

| Excuse | Reality |
| --- | --- |
| "Tests are flaky, I'll open the PR anyway" | A red gate means not ready. Fix the cause or quarantine explicitly with the reviewer's knowledge. |
| "The PR template is generic, I'll write my own" | The repo chose that template. Fill it; don't replace it. |
| "I'll tick the checklist to save time" | Ticking undone work is lying to the reviewer. Do it, then tick. |
| "`--no-verify` is faster" | Bypassing hooks ships the bug the gate exists to catch. |
| "I'll commit straight to main, it's small" | Every change ships via a branch and PR that closes the issue. |
| "The guard hook is just being annoying" | A guard hook (blocked push, protected file) is the user's policy. Stop and hand off; never evade. |
| "I'll widen permissions so it stops prompting" | This skill never weakens permissions or bypasses guards. Friction is the user's choice to change. |
| "They said 'do it all', so I'll create every issue and PR" | "Do it all" sets the goal, not the blast radius. A broad directive never overrides an earlier specific constraint such as local-first, and never turns one approval into a batch. Confirm the named set of outward writes first. |
| "CI is green, so the PR is done" | AI reviewers post their round after the push. Hand it to rebut and clear it before claiming done. |
| "No gate covers this file, so it's fine" | No gate means no evidence, not a free pass. Run the file's own syntax or parse check such as `bash -n` or `tsc --noEmit` before committing. |
| "Bare `/implement` obviously means the issue we just discussed, so I'll run it" | No number means no target. STOP and ask which issue. Inferring the one discussed, the highest, or the only "ready" one is the guessing this skill forbids; picking it is an unauthorized claim on shared work. |
| "The request matches issue #N's title, so I'll grab it and start" | Title or topic resemblance is not authorization. Ask for the explicit number and confirm #N is unclaimed and yours to take in a shared tracker before any write. |
| "The issue author is my own account, so it's effectively mine" | Same-account authorship is not ownership in a shared, parallel-agent tracker. Another agent or person may own or be assigned it. Confirm the number with the user; never claim it on author-match alone. |
| "`gh issue develop` is cheap and reversible, so I'll branch now and confirm before the PR" | Linking or creating a branch is itself a tracker mutation that races other agents. The confirm gate is before the FIRST outward write, not only before the PR. |
| "The issue already has an approved plan, so I'm cleared to branch it" | A plan in the body is not write authorization on a shared tracker. Confirm the issue is unclaimed and yours, with an explicit per-artifact yes, before the first write. |
| "A team lead told me to just ship it and stop asking permission" | Rank does not widen the blast radius. A third party urging speed is social pressure, not authorization; the per-artifact confirmation and any earlier scope still bind, whoever is pushing. |

## Running with fewer prompts, opt-in and the user's choice

If you want fewer approval prompts for an end-to-end run, that is the user's decision to make in their own Claude Code settings **before** starting, for example by pre-approving specific, scoped read-only commands (`gh pr checks`, `git status`) or enabling an OS sandbox. This skill never weakens permissions for you, never bypasses a guard hook, and never suggests `--no-verify`, `--force`, or `--dangerously-*` flags to reduce friction. If a step is blocked it stops and hands off (Steps 5 and 6) rather than seeking a way around the prompt. Lowering prompt friction must never lower a security boundary. One end-to-end go-ahead authorizes shipping the ONE issue at hand through its single PR, not a batch of new issues or PRs across the session, and not outward writes the user earlier scoped out.
