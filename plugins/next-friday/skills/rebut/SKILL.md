---
name: rebut
description: "Use on an open pull request that carries AI code-review comments — CodeRabbit, Gemini Code Assist, or a similar bot reviewer — that need handling. Triggers on requests like 'audit the bot comments', 'respond to coderabbit', 'rebut the reviewer', 'go through the AI review', or whenever an open PR shows unresolved bot review threads to triage."
license: MIT
compatibility: "Requires git, the GitHub CLI (gh) authenticated with pull-request write access, and a GitHub remote."
argument-hint: "[pr-number]"
---

# Rebut

Triage the AI code-review comments on a pull request and answer them with rigor. Verify every
finding against the real code, fix the ones that are real, refute the false positives with
evidence, and reply in each thread, marked as automated triage. The human still clicks Resolve.

This is the counterpart to human review, not a copy of it. AI reviewers (CodeRabbit, Gemini Code
Assist) post **far more** findings, mix real bugs with false positives, and are **repo-blind** —
they do not know your custom lint config, conventions, or tooling, so they flag
correct-for-your-repo patterns as bugs, confidently. **A bot's severity is not its correctness**:
a `CRITICAL` can be a false positive, and a nit can hide a real bug.

<HARD-GATE>
Never apply a suggestion and never refute one without first verifying the finding against the
CURRENT code. Reproduce the claim, or run the gate, or read the convention — then decide.
</HARD-GATE>

<HARD-GATE>
Every reply carries a verdict backed by evidence: a commit SHA for a fix, or a concrete reason
for a refute (the gate output, the convention, the line that disproves it). Never post
"you're absolutely right" and never a bare dismissal.
</HARD-GATE>

## Why AI reviewers get their own triage

- **Repo-blind.** The bot does not load your `eslint.config`, your `tsconfig`, or your house
  rules. It will flag a pattern your own tooling REQUIRES. Real example: a reviewer marked
  `meta.defaultOptions` as CRITICAL "wrong", but the repo's `require-meta-default-options` lint
  forces it — applying the suggestion would have broken the build. Blind-apply is as dangerous as
  blind-dismiss.
- **High false-positive rate.** Many findings are speculative or style-only. Some are real bugs
  the human missed. The job is to separate them with evidence, not vibes.
- **Confidently wrong.** Severity labels are heuristics. Verify a `CRITICAL` the same as a nit.

## Preflight

```sh
gh auth status
```

Identify the PR: the `[pr-number]` argument, else the PR for the current branch
(`gh pr view --json number`).

## Step 1 — Gather every finding

```sh
OWNER_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
gh api --paginate "repos/$OWNER_REPO/pulls/<pr>/reviews"  --jq '.[] | "[\(.user.login)] \(.state)\n\(.body)\n"'
gh api --paginate "repos/$OWNER_REPO/pulls/<pr>/comments" --jq '.[] | "[\(.user.login)] \(.path):\(.line) id=\(.id)\n\(.body)\n"'
```

List each finding with its author, `path:line`, comment `id` (needed to reply), and body. Include
the top-level review summaries and every inline comment. Miss none.

## Step 2 — Verify each finding (the core of this skill)

For each finding, answer two questions against the **current** code, not the bot's framing:

1. **Does the problem reproduce?** Open the file at the line. Trace the logic. Construct the input
   the bot describes and check the actual behavior. If it is a bug, it must be demonstrable.
2. **Is the suggestion correct for THIS repo?** Run the relevant gate (lint, type-check, test). Check
   the documented convention. A fix that passes the bot but fails a repo gate is wrong here.

Change one thing at a time and re-verify. Do not batch.

## Step 3 — Classify

| Verdict         | Meaning                             | Action                                        |
| --------------- | ----------------------------------- | --------------------------------------------- |
| **FIX**         | Real, reproduces                    | Fix it (Step 4)                               |
| **REFUTE**      | False positive for this repo        | Reply with the evidence that disproves it     |
| **INTENTIONAL** | Deliberate choice the bot can't see | Reply explaining the intent                   |
| **MINOR**       | Cosmetic, non-gating                | Note it; fix or skip per the maintainer's bar |

## Step 4 — Fix the valid ones

- Minimal change scoped to the finding. For a bug, write the failing test first, watch it fail,
  fix, watch it pass.
- Run the repo's full gates. A red gate blocks the fix.
- Commit and push under the **developer's** account (the code is theirs). Capture the SHA for the
  reply.

## Step 5 — Reply in each thread

Reply to the original comment so it threads inline — never a top-level PR comment. Prefix every
reply with the `rebut` marker so it reads as automated triage, not your own casual take:

```sh
gh api "repos/$OWNER_REPO/pulls/<pr>/comments/<comment_id>/replies" \
  -f body="**rebut** (automated triage) — Fixed in <sha>: <one line on the change>."
```

For a refute, state the evidence:

```sh
gh api "repos/$OWNER_REPO/pulls/<pr>/comments/<comment_id>/replies" \
  -f body="**rebut** (automated triage) — Not changing this: <concrete reason, e.g. required by require-meta-default-options; lint passes>."
```

**Reply-only.** Do NOT resolve the threads — resolving is the human's call.

## Step 6 — Summarize

Hand back a per-finding verdict table (finding → FIX / REFUTE / INTENTIONAL / MINOR → what you did),
the fix commit SHAs, and a clear "CI is green; these threads are answered and safe to Resolve."

## Red flags — STOP

| Thought                          | Reality                                                                     |
| -------------------------------- | --------------------------------------------------------------------------- |
| "It's CRITICAL, it must be real" | Severity is a heuristic. Verify it like any other.                          |
| "Just apply the suggested diff"  | It may break a repo gate the bot can't see. Verify against the gate first.  |
| "Dismiss it, the bot is noisy"   | A bare dismissal is not a refute. Cite the evidence.                        |
| "Reply with no marker"           | An unmarked reply reads as your casual take. Prefix it as automated triage. |
| "Resolve the thread too"         | Resolving is the human's decision; this skill replies only.                 |
