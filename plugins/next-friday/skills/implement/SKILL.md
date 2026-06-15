---
name: implement
description: "Use when an approved GitHub issue (design and plan already agreed) is ready to build and ship, or on requests like 'implement issue #N', 'start working on the issue', 'open a PR for issue #N', branch from an issue, get the gates or CI green, or open a pull request from the repo template. The execution half that follows the blueprint skill."
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
```

<HARD-GATE>
Do NOT open the PR until every applicable gate passes and every checklist item in the issue/PR template (when one exists) is genuinely done and ticked. A red gate or an unchecked box means the work is not ready.
</HARD-GATE>

<HARD-GATE>
NO COMPLETION CLAIM WITHOUT FRESH VERIFICATION EVIDENCE. Before claiming a gate passed, the build is green, or the work is done: run the exact command in this turn, read its full output and exit code, and only then claim it. If you have not run the command in this message, you cannot say it passes. Ban "should pass", "looks right", "seems fine" before the evidence. A regression test is proven only red-green — revert the fix, watch the test fail, restore it.
</HARD-GATE>

## Language Rule

All **artifacts** are English: branch name, code, commits, PR title/body, comments, labels. The chat conversation with the user may be in another language, but anything that lands on GitHub or in the repo is English.

## Per-repo Templates Are the Source of Structure

Issue and PR structure comes from the repo's own templates, which differ per repo. **Always check for the repo's templates first — when one exists, using it is MANDATORY.** Never invent your own structure over a template.

- Issue templates: `.github/ISSUE_TEMPLATE/`
- PR template: `.github/PULL_REQUEST_TEMPLATE.md` (or `.github/PULL_REQUEST_TEMPLATE/`)

Read the actual file and fill every section. If a template contains a checklist, you MUST complete the work each item describes and tick it (`- [x]`) — never tick a box whose work you haven't done.

**Only if the repo has no PR template**, fall back to a body with these sections — Summary, Changes, How to verify — plus `Closes #<n>`, and tell the user once that the repo lacks a template.

## Steps

### 1. Identify the issue and its plan

```sh
gh auth status
gh issue view <n> --comments
```

If `gh` is missing or unauthenticated, STOP and tell the user to install it and run `gh auth login` — do not improvise with raw `git`/`curl`. If the repo has no GitHub remote, STOP and ask how they track work; this skill is GitHub-specific.

Confirm the issue carries an approved design and an implementation plan in the issue body. If the plan is missing, stop — go back to the blueprint skill.

**Sub-issues:** If the work was split into sub-issues, handle one sub-issue per branch/PR. Don't bundle several sub-issues into one PR.

### 2. Branch from the issue

Check whether a branch is already linked to the issue:

```sh
gh issue develop <n> --list
```

If a linked branch already exists, check it out and continue there (don't recreate). If a branch with the issue's name exists but isn't linked, check it out anyway; if local and remote have diverged, fetch and reconcile before working. Otherwise create one linked to the issue (so GitHub associates them):

```sh
gh issue develop <n> --checkout
```

Fallbacks, in order:

- **`gh issue develop` subcommand missing** (older `gh`) → branch from the freshly-fetched default branch with a deterministic name: `git fetch origin && git switch -c <n>-<kebab-title> origin/<default-branch>`, where `<kebab-title>` is the issue title lowercased and hyphenated.
- **No write access to the upstream repo** (you're a contributor on a fork) → `gh issue develop` and the later label/reviewer steps will fail; skip them. Branch on your fork from its up-to-date default, push to your fork, and open the PR cross-repo (see Step 6).

Never work on the default branch.

Once on the branch, run the repo's gates once before writing any code to capture a clean baseline — a later red gate is then provably yours, not pre-existing. If the baseline is already red, report it and ask before proceeding.

### 3. Write the code, task by task

Follow the plan's bite-sized tasks in order. Commit frequently. Keep changes scoped to this issue.

**Test-first — where the repo has test infrastructure.** No production code without a failing test first: write the test, run it and watch it fail for the right reason, write the minimal code to pass, run it green, then refactor. Wrote the code before its test? Delete it and start over — don't keep it as "reference" and adapt it. Common excuses and the reality: "too simple to test" (simple code breaks too; the test costs 30 seconds); "I'll test after" (a test that never watched the bug fail proves nothing); "I already tested it by hand" (ad-hoc isn't repeatable — if it isn't a committed test, it didn't happen). If the repo has no test infrastructure, say so in the PR body; never fabricate tests.

- **Match the repo's commit convention** — check `git log --oneline -20` before your first commit; if the repo uses Conventional Commits (`feat:`, `fix:`, ...), follow it. Don't invent your own style.
- **Keep the PR reviewable** — if the diff grows past roughly 400 changed lines, stop and propose splitting into sub-issues (each with its own PR). Oversized reviews get rubber-stamped; small PRs get real review.
- **Stacked branches after a squash merge** — if this branch was built on another PR's branch and that PR squash-merges, the squash rewrites history: your branch's old base commits are no longer on the default branch, so the PR shows a polluted diff or conflicts. Re-point it onto the merged result: `git fetch origin && git rebase --onto origin/<default-branch> <old-base-sha> <this-branch>`, then force-push with `--force-with-lease`. Do this before continuing, not after opening the PR.
- **A planned change may be protected** — a `Write`/`Edit` is denied by a hook, the path is owner-owned (CODEOWNERS / a protected config), or policy forbids touching it. Treat the protection as authoritative: do NOT retry the write, escalate permissions, or route around the guard. Leave the file untouched, implement everything else, and record the deferral explicitly in the PR body ("Deferred: `<path>` is protected — needs owner action") and to the user. A protected file is a deferral, not a blocker to defeat.

### 4. Run the FULL gates — before committing the final state

Discover the repo's gates from where the changed code lives, not just the repo root (don't assume). In a monorepo the lint/type/test/build scripts often live in the sub-package that owns the files this issue touched, or in a workspace runner (`turbo.json`, `nx.json`, `pnpm-workspace.yaml`) — not the root `package.json`. Identify the owning package and run its gates through the repo's task runner (e.g. `turbo run lint --filter=<pkg>`, `pnpm --filter <pkg> test`, or the package's local scripts). A root-level script may be absent, run nothing for that package, or falsely pass — confirm the gate actually exercised your changes before trusting a green result. Run all gates that apply and make them pass:

- Lint
- Type-check
- Tests (and run a single test while iterating, full suite before PR)
- Build

A failing gate blocks the PR. Fix the cause — do not skip, disable, or `--no-verify` around a gate to make it pass.

**When a gate (or, later, a CI check) fails — debug by root cause, don't flail:**

- Investigate before touching anything: read the actual error and find the cause. No guess-and-retry.
- Change ONE thing at a time and re-run. A burst of simultaneous changes hides which one mattered.
- **After 3 failed fixes, STOP.** Repeated failure — especially surfacing somewhere new each time — means the approach or the plan is wrong, not that fix #4 is around the corner. Step back, question the design, and raise it with the user instead of guessing again.

**If a gate has no corresponding script in the repo** (e.g., no test setup yet), it does not block the PR — state its absence explicitly in the PR body instead of silently skipping it.

### 4.5. Self-review the diff against the plan

Before committing the final state, re-read the issue's plan and check your diff against it:

- **Every plan task is implemented** — point to the change that delivers each one, and list any gaps.
- **Nothing extra** — the diff adds only what the plan asked for (YAGNI): no drive-by refactors, no speculative code, no files the plan never named.
- "Close enough" on the plan is not done. If the diff and the plan disagree, fix the diff — or, if the plan itself was wrong, update the issue body and say so.

### 5. Commit & push

Commit any remaining changes from gate fixes, then push:

```sh
git add <files this issue touched>
git commit -m "<clear English message>"
git push -u origin <branch>
```

Stage only the files this issue touched — never blanket `git add -A`/`git add .`, which sweeps in unrelated or untracked files (build artifacts, temp bodies). On a fork, push to your fork's remote, not `origin` upstream.

**If the push is blocked** by a guard hook, branch protection, or a server-side rule: STOP. Do not retry, do not `--force`, do not `--no-verify`, do not reroute to another remote or rewrite the command to evade the block. The block is the user's policy, not an obstacle to engineer around. Report exactly what was refused and the command, leave the commits intact locally, and hand off to the user to complete the push (or grant it) themselves. A blocked push is an expected stop, not a failure.

### 6. Open the PR from the repo's template

Read `.github/PULL_REQUEST_TEMPLATE.md` and fill every section (or use the no-template fallback sections above). Write the body to a temp file — multi-line bodies break inline `--body` quoting:

```sh
gh pr create --head <branch> --title "<English title per the repo's title convention>" --body-file /tmp/pr-body.md
```

- **Always pass `--head <branch>` explicitly.** Without it, `gh` infers the currently checked-out branch — in a session with more than one active branch, the PR silently attaches to the wrong one. **From a fork**, qualify it as `--head <fork-owner>:<branch>` so `gh` opens the PR cross-repo into the upstream.
- **Title follows the repo's enforced convention** — check for a pr-title validation workflow and the repo's commitlint config; discover the rule by reading the repo, never assume another repo's scheme. A common rule set: conventional `type(scope): subject` validated by commitlint, and **no `#N` in the title** (squash-merge appends `(#PR)`; an issue ref in the title duplicates on the default branch). Issue refs go in the body only.
- **If PR creation is blocked** by a hook or policy: STOP, exactly as with a blocked push — do not force or reroute. Report what was refused and hand off to the user to open the PR.
- Body MUST include `Closes #<n>` so merging closes the issue.
- Labels: only apply ones that already exist (check `gh label list`). Reviewers: determine from CODEOWNERS or ask the user — never guess. **On a fork you lack write access**, so skip the label/reviewer steps; the maintainer applies them.
- **Complete and tick every checklist item** in the PR (and any remaining issue-template checklist). Each ticked box must reflect work actually done.

### 7. Verify CI on the PR

Local gates passing is necessary, not sufficient — the repo's CI and branch protection decide whether the PR can merge.

First see whether the PR has any checks at all, then watch only if it does:

```sh
gh pr checks <pr-number> || echo "no checks reported"
# only when checks exist:
gh pr checks <pr-number> --watch
```

- **No checks exist** → `gh pr checks --watch` exits non-zero with `no checks reported` when a PR has zero check runs. That is NOT a CI failure — do NOT loop trying to "fix" it. Report "no CI configured" (and, for a team-owned repo, suggest adding it) and stop.
- **All checks green** → report the PR URL + CI status to the user. Done.
- **A check fails** → treat it exactly like a failing local gate: debug by root cause (Step 4), fix, push, re-watch. Never hand the PR over for review with red CI.

**Responding to review feedback on the PR:**

- Evaluate each comment against the codebase before changing anything — verify the claim; don't reflexively comply.
- A wrong or YAGNI suggestion gets technical pushback, not performative agreement ("you're absolutely right!"); a correct one gets the fix, stated plainly.
- Fix one comment at a time and re-verify (Step 4) after each.
- Reply in the inline review thread, not as a top-level PR comment.

## Red Flags — STOP

- About to open a PR with a failing/skipped gate → STOP. Gates must pass for real.
- About to write the PR body from scratch while `.github/PULL_REQUEST_TEMPLATE.md` exists → STOP. Use the template.
- About to tick a checklist box whose work isn't done → STOP. Do the work first.
- About to commit on the default branch → STOP. Branch from the issue.
- About to bundle multiple sub-issues into one PR → STOP. One sub-issue per PR.
- PR body has no `Closes #<n>` → STOP. Link the issue.
- About to report "done" while CI is red or still pending → STOP. Watch `gh pr checks` to green first.
- About to retry, `--force`, `--no-verify`, or reroute a push/PR that a hook or policy blocked → STOP. Hand off to the user.
- About to retry a write the environment denied (protected/owner-owned file) → STOP. Defer it and document in the PR body.

## Rationalizations

| Excuse                                          | Reality                                                                                           |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| "Tests are flaky, I'll open the PR anyway"      | A red gate means not ready. Fix the cause or quarantine explicitly with the reviewer's knowledge. |
| "The PR template is generic, I'll write my own" | The repo chose that template. Fill it; don't replace it.                                          |
| "I'll tick the checklist to save time"          | Ticking undone work is lying to the reviewer. Do it, then tick.                                   |
| "`--no-verify` is faster"                       | Bypassing hooks ships the bug the gate exists to catch.                                           |
| "I'll commit straight to main, it's small"      | Every change ships via a branch and PR that closes the issue.                                     |
| "The guard hook is just being annoying"         | A guard hook (blocked push, protected file) is the user's policy. Stop and hand off; never evade. |
| "I'll widen permissions so it stops prompting"  | This skill never weakens permissions or bypasses guards. Friction is the user's choice to change. |

## Running with fewer prompts (opt-in, user's choice)

If you want fewer approval prompts for an end-to-end run, that is the user's decision to make in their own Claude Code settings — for example pre-approving specific, scoped read-only commands (`gh pr checks`, `git status`) or enabling an OS sandbox — **before** starting. This skill never weakens permissions for you, never bypasses a guard hook, and never suggests `--no-verify`, `--force`, or `--dangerously-*` flags to reduce friction. If a step is blocked it stops and hands off (Steps 5 and 6) rather than seeking a way around the prompt. Lowering prompt friction must never lower a security boundary.
