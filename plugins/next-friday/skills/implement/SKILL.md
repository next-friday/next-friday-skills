---
name: implement
description: "Use when a GitHub issue's design and plan are agreed and it's time to implement and ship - turns an approved issue into a branch, working code that passes all gates, and a pull request opened from the repo's template, watched to green CI. Follows the blueprint skill. Triggers on requests like 'implement issue #N', 'start working on the issue', 'open a PR for issue #N'."
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

Confirm the issue carries an approved design and an implementation plan (in the issue body/comments by default, or in committed spec/plan files linked from the issue when blueprint used spec document mode). If the plan is missing, stop — go back to the blueprint skill.

**Sub-issues:** If the work was split into sub-issues, handle one sub-issue per branch/PR. Don't bundle several sub-issues into one PR.

### 2. Branch from the issue

Check whether a branch is already linked to the issue — blueprint's spec document mode creates one when committing the spec file:

```sh
gh issue develop <n> --list
```

If a linked branch exists, check it out and continue there. Otherwise create one linked to the issue (so GitHub associates them):

```sh
gh issue develop <n> --checkout
```

If `gh issue develop` is unavailable, create a branch named for the issue (`<n>-<slug>`) and push it. Never work on the default branch.

### 3. Write the code, task by task

Follow the plan's bite-sized tasks in order. TDD where the repo has test infrastructure: failing test → minimal code → passing test. Commit frequently. Keep changes scoped to this issue.

- **Match the repo's commit convention** — check `git log --oneline -20` before your first commit; if the repo uses Conventional Commits (`feat:`, `fix:`, ...), follow it. Don't invent your own style.
- **Keep the PR reviewable** — if the diff grows past roughly 400 changed lines, stop and propose splitting into sub-issues (each with its own PR). Oversized reviews get rubber-stamped; small PRs get real review.

### 4. Run the FULL gates — before committing the final state

Discover the repo's gates (don't assume); typically from `package.json` scripts / `turbo.json` / CI config. Run all that apply and make them pass:

- Lint
- Type-check
- Tests (and run a single test while iterating, full suite before PR)
- Build

A failing gate blocks the PR. Fix the cause — do not skip, disable, or `--no-verify` around a gate to make it pass.

**If a gate has no corresponding script in the repo** (e.g., no test setup yet), it does not block the PR — state its absence explicitly in the PR body instead of silently skipping it.

### 5. Commit & push

Commit any remaining changes from gate fixes, then push:

```sh
git add <changed files>
git commit -m "<clear English message>"
git push -u origin <branch>
```

### 6. Open the PR from the repo's template

Read `.github/PULL_REQUEST_TEMPLATE.md` and fill every section (or use the no-template fallback sections above). Write the body to a temp file — multi-line bodies break inline `--body` quoting:

```sh
gh pr create --head <branch> --title "<English title per the repo's title convention>" --body-file /tmp/pr-body.md
```

- **Always pass `--head <branch>` explicitly.** Without it, `gh` infers the currently checked-out branch — in a session with more than one active branch, the PR silently attaches to the wrong one.
- **Title follows the repo's enforced convention** — check for a pr-validate workflow (often a thin caller into an org `<org>/.github` hub) and the repo's commitlint config. Common org rules: conventional `type(scope): subject` validated by commitlint, and **no `#N` in the title** (squash-merge appends `(#PR)`; an issue ref in the title duplicates on the default branch). Issue refs go in the body only.
- Body MUST include `Closes #<n>` so merging closes the issue.
- Labels: only apply ones that already exist (check `gh label list`). Reviewers: determine from CODEOWNERS or ask the user — never guess.
- **Complete and tick every checklist item** in the PR (and any remaining issue-template checklist). Each ticked box must reflect work actually done.

### 7. Verify CI on the PR

Local gates passing is necessary, not sufficient — the repo's CI and branch protection decide whether the PR can merge.

```sh
gh pr checks --watch
```

- **All checks green** → report the PR URL + CI status to the user. Done.
- **A check fails** → treat it exactly like a failing local gate: fix the cause, push, re-watch. Never hand the PR over for review with red CI.
- **No checks configured** → say so explicitly in your report; for a team-owned repo, suggest adding CI.

## Red Flags — STOP

- About to open a PR with a failing/skipped gate → STOP. Gates must pass for real.
- About to write the PR body from scratch while `.github/PULL_REQUEST_TEMPLATE.md` exists → STOP. Use the template.
- About to tick a checklist box whose work isn't done → STOP. Do the work first.
- About to commit on the default branch → STOP. Branch from the issue.
- About to bundle multiple sub-issues into one PR → STOP. One sub-issue per PR.
- PR body has no `Closes #<n>` → STOP. Link the issue.
- About to report "done" while CI is red or still pending → STOP. Watch `gh pr checks` to green first.

## Rationalizations

| Excuse                                          | Reality                                                                                           |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| "Tests are flaky, I'll open the PR anyway"      | A red gate means not ready. Fix the cause or quarantine explicitly with the reviewer's knowledge. |
| "The PR template is generic, I'll write my own" | The repo chose that template. Fill it; don't replace it.                                          |
| "I'll tick the checklist to save time"          | Ticking undone work is lying to the reviewer. Do it, then tick.                                   |
| "`--no-verify` is faster"                       | Bypassing hooks ships the bug the gate exists to catch.                                           |
| "I'll commit straight to main, it's small"      | Every change ships via a branch and PR that closes the issue.                                     |
