---
name: rebut
description: "Use on an open pull request that carries AI code-review comments — CodeRabbit, Gemini Code Assist, or a similar bot reviewer — that need handling, and right after pushing to a PR where such a reviewer is expected to weigh in. Triggers on requests like 'audit the bot comments', 'respond to coderabbit', 'rebut the reviewer', 'go through the AI review', or whenever an open PR shows unresolved bot review threads to triage."
license: MIT
compatibility: "Requires git, the GitHub CLI (gh) authenticated with pull-request write access, and a GitHub remote."
argument-hint: "[pr-number]"
---

# Rebut

Triage the AI code-review comments on a pull request and answer them with rigor. Verify every
finding against the real code, fix the ones that are real, refute the false positives with
evidence, and reply in each thread, marked as automated triage. The human still clicks Resolve.

This is the counterpart to human review, not a copy of it. AI reviewers such as CodeRabbit or Gemini
Code Assist post **far more** findings, mix real bugs with false positives, and are **repo-blind** —
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

## When the reviewer is a human

The verification core — the two HARD-GATEs above, never apply or refute without checking the current code and back every reply with evidence — holds for **any** reviewer. The rest of this skill is tuned for bots, and a human reviewer inverts every bot trait: they usually know the repo, post fewer and higher-signal findings, and have a face that a blunt refutation can threaten. So when the reviewer is human:

- **Drop the bot framing.** Do not treat their review as repo-blind, high-false-positive noise; it usually is not.
- **Collaborate, do not refute.** Verify, then fix what is right and push back on what is wrong with technical reasoning — never performative agreement, never a curt "false positive" aimed at a colleague.
- **Do not auto-post as them.** Draft the reply and hand it to the maintainer to send in their own voice; the automated-triage attribution line fits a bot-triage reply, not a peer reply. Reply autonomously only to bot threads.

The rest of this skill — the steps, the attribution marker, the auto-reply — assumes a bot reviewer. Apply it as written to bots; adapt per the three points above for humans.

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
the top-level review summaries and every inline comment. Miss none. Tag each thread's author as a bot — recognizable by the `[bot]` login suffix shown in the gathered output — or a human: bot threads follow Steps 4-6 as written, human threads follow "When the reviewer is a human" above.

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
- Commit and push under the **maintainer's** account — the same account that owns the PR and posts the replies. Capture the SHA for the
  reply.

## Step 5 — Reply in each thread

Reply to the original comment so it threads inline — never a top-level PR comment.

**Open every reply with the same attribution line, on every thread, without exception.** You post
through the maintainer's `gh` token, so GitHub shows their avatar and a reader assumes they wrote
it. The attribution line names the agent and disconnects the comment from the maintainer,
so automated triage is never mistaken for the maintainer's own review:

> 🤖 Automated triage by Claude Code, posted through the maintainer's account — not a personal review.

When the repo has a bot or machine account, post under that identity instead so the author itself is
non-personal; the attribution line is the fallback for a personal token.

Write the body to a file and post it with `-F body=@<file>` — the attribution line makes the body
multi-line, which breaks inline `-f body="..."` quoting. A fix reply:

```text
> 🤖 Automated triage by Claude Code, posted through the maintainer's account — not a personal review.

**rebut** — Fixed in <sha>: <one line on the change>.
```

A refute states the evidence:

```text
> 🤖 Automated triage by Claude Code, posted through the maintainer's account — not a personal review.

**rebut** — Not changing this: <concrete reason, e.g. a repo lint rule requires it; the gate passes>.
```

```sh
gh api "repos/$OWNER_REPO/pulls/<pr>/comments/<comment_id>/replies" -F body=@/tmp/reply.md
```

**Reply-only.** Do NOT resolve the threads — resolving is the human's call.

## Step 5.5 — Re-verify CI, then catch the round your fix-push provoked

If Step 4 pushed any fix commits, that push re-triggers CI and a fresh AI-review round. Before summarizing:

- **Re-verify CI.** Probe first with `gh pr checks <pr> || echo "no checks reported"`; when checks exist, run `gh pr checks <pr> --watch` and confirm green with your own eyes — never assert CI is green without this evidence. If the PR has no checks, `--watch` exits non-zero with `no checks reported`; that is NOT a failure — note "no CI configured" and move on, exactly as the **implement** skill handles it.
- **Catch the new round.** The fix-push provokes a fresh bot round. Re-run Step 1's gather; if it surfaced new actionable findings, triage them through Steps 2-5, then return to the top of this step. Every push repeats this re-verify and re-gather; the loop ends only when a gather adds nothing new — only acknowledgements, or no comments.

If Step 4 changed nothing (every finding was REFUTE or INTENTIONAL), there is no new push and no new round — skip straight to Step 6.

## Step 6 — Summarize

Hand back a per-finding verdict table (finding → FIX / REFUTE / INTENTIONAL / MINOR → what you did),
the fix commit SHAs, and the actual `gh pr checks` result from Step 5.5 — reported as "CI is green" only when it truly is, or "no CI configured" when the PR has none — followed by a clear "these threads are answered and safe to Resolve."

## Across rounds: automate re-invocation, never pretend to watch

This skill triages the round in front of it now, plus any round your own fix-push provokes within the same invocation (Step 5.5). It does **not** watch the PR over time: a skill is one invocation with no background process, so any claim to "keep watching until the PR closes" would be fiction. A reviewer — bot or human — who comments tomorrow needs the skill invoked again.

To triage every future round automatically until the PR closes, re-invoke this skill from **outside** it, not from prose inside it: a GitHub Action on the `pull_request_review`, `pull_request_review_comment`, and `issue_comment` events that runs the agent headless, or an equivalent watch loop. Guard it so the fix-push's own review round cannot re-trigger it forever, and run it under a bot or app token rather than a personal one. See `docs/continuous-triage.md` for a starting template.

## Red flags — STOP

| Thought                          | Reality                                                                                                                      |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| "It's CRITICAL, it must be real" | Severity is a heuristic. Verify it like any other.                                                                           |
| "Just apply the suggested diff"  | It may break a repo gate the bot can't see. Verify against the gate first.                                                   |
| "Dismiss it, the bot is noisy"   | A bare dismissal is not a refute. Cite the evidence.                                                                         |
| "Reply with no marker"           | It reads as the maintainer's own words. Open every reply with the Claude Code attribution line, then the `**rebut**` marker. |
| "Resolve the thread too"         | Resolving is the human's decision; this skill replies only.                                                                  |
