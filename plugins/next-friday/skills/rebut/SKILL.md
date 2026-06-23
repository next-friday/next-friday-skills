---
name: rebut
description: "Use on an open pull request that carries AI code-review comments from CodeRabbit, Gemini Code Assist, or a similar bot reviewer that need handling, and right after pushing to a PR where such a reviewer is expected to weigh in. Triggers on requests like 'audit the bot comments', 'respond to coderabbit', 'rebut the reviewer', 'go through the AI review', or whenever an open PR shows unresolved bot review threads to triage."
license: MIT
compatibility: "Requires git, the GitHub CLI (gh) authenticated with pull-request write access, and a GitHub remote."
argument-hint: "[pr-number]"
---

# Rebut

Triage the AI code-review comments on a pull request and answer them with rigor. Verify every
finding against the real code, fix the ones that are real, refute the false positives with
evidence, and reply in each thread, marked as automated triage. The human still clicks Resolve.

This is the counterpart to human review, not a copy of it. AI reviewers such as CodeRabbit or Gemini
Code Assist post **far more** findings, mix real bugs with false positives, and are **repo-blind**.
They do not know your custom lint config, conventions, or tooling, so they flag
correct-for-your-repo patterns as bugs, confidently. **A bot's severity is not its correctness**:
a `CRITICAL` can be a false positive, and a nit can hide a real bug.

<HARD-GATE>
Never apply a suggestion and never refute one without first verifying the finding against the
CURRENT code. Reproduce the claim, or run the gate, or read the convention, then decide.
</HARD-GATE>

<HARD-GATE>
Every reply carries a verdict backed by evidence: a commit SHA for a fix, or a concrete reason
for a refute such as the gate output, the convention, or the line that disproves it. Never post
"you're absolutely right" and never a bare dismissal.
</HARD-GATE>

## Why AI reviewers get their own triage

- **Repo-blind.** The bot does not load your `eslint.config`, your `tsconfig`, or your house
  rules. It will flag a pattern your own tooling REQUIRES. Real example: a reviewer marked
  `meta.defaultOptions` as CRITICAL "wrong", but the repo's `require-meta-default-options` lint
  forces it. Applying the suggestion would have broken the build. Blind-apply is as dangerous as
  blind-dismiss.
- **High false-positive rate.** Many findings are speculative or style-only. Some are real bugs
  the human missed. The job is to separate them with evidence, not vibes.
- **Confidently wrong.** Severity labels are heuristics. Verify a `CRITICAL` the same as a nit.

## When the reviewer is a human

The verification core holds for **any** reviewer: the two HARD-GATEs above, never apply or refute without checking the current code, and back every reply with evidence. The rest of this skill is tuned for bots, and a human reviewer inverts every bot trait: they usually know the repo, post fewer and higher-signal findings, and have a face that a blunt refutation can threaten. So when the reviewer is human:

- **Drop the bot framing.** Do not treat their review as repo-blind, high-false-positive noise; it usually is not.
- **Collaborate, do not refute.** Verify, then fix what is right and push back on what is wrong with technical reasoning. Never performative agreement, never a curt "false positive" aimed at a colleague.
- **Do not auto-post as them.** Draft the reply and hand it to the maintainer to send in their own voice. The automated-triage attribution line fits a bot-triage reply, not a peer reply. Reply autonomously only to bot threads.

The rest of this skill, meaning the steps, the attribution marker, and the auto-reply, assumes a bot reviewer. Apply it as written to bots; adapt per the three points above for humans.

## Preflight

```sh
"${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh"
```

`preflight.sh` confirms `gh` is authenticated and the repo has a GitHub remote. On a missing prerequisite it prints the fix on stderr and exits non-zero; relay that and stop. Identify the PR: the `[pr-number]` argument, else the PR for the current branch (`gh pr view --json number`).

## Step 1: Gather every finding

```sh
"${CLAUDE_PLUGIN_ROOT}/scripts/gather-review.sh" <pr>
```

`gather-review.sh` prints a `REVIEWS` block holding each review's author, state, and body, and a `COMMENTS` block holding each inline comment's author, `path:line`, `id=<id>`, and body, via `gh`'s built-in `--jq`, so nothing is invented or dropped. List each finding with its author, `path:line`, comment `id` needed to reply, and body. Include the top-level review summaries and every inline comment. Miss none. Tag each thread's author as a bot, recognizable by the `[bot]` login suffix shown in the gathered output, or a human: bot threads follow Steps 4-6 as written, human threads follow "When the reviewer is a human" above.

## Step 2: Verify each finding (the core of this skill)

For each finding, answer two questions against the **current** code, not the bot's framing:

1. **Does the problem reproduce?** Open the file at the line. Trace the logic. Construct the input
   the bot describes and check the actual behavior. If it is a bug, it must be demonstrable.
2. **Is the suggestion correct for THIS repo?** Run the relevant gate (lint, type-check, test). Check
   the documented convention. A fix that passes the bot but fails a repo gate is wrong here.

Change one thing at a time and re-verify. Do not batch.

## Step 3: Classify

| Verdict         | Meaning                             | Action                                        |
| --------------- | ----------------------------------- | --------------------------------------------- |
| **FIX**         | Real, reproduces                    | Fix it (Step 4)                               |
| **REFUTE**      | False positive for this repo        | Reply with the evidence that disproves it     |
| **INTENTIONAL** | Deliberate choice the bot can't see | Reply explaining the intent                   |
| **MINOR**       | Cosmetic, non-gating                | Note it; fix or skip per the maintainer's bar |

## Step 4: Fix the valid ones

- Minimal change scoped to the finding. For a bug, write the failing test first, watch it fail,
  fix, watch it pass.
- Run the repo's full gates. A red gate blocks the fix.
- Commit and push under the **maintainer's** account, the same account that owns the PR and posts the replies. Capture the SHA for the
  reply.

## Step 5: Reply in each thread

Reply to the original comment so it threads inline, never a top-level PR comment.

**Open every reply with the same attribution line, on every thread, without exception.** You post
through the maintainer's `gh` token, so GitHub shows their avatar and a reader assumes they wrote
it. The attribution line names the agent and disconnects the comment from the maintainer,
so automated triage is never mistaken for the maintainer's own review:

> 🤖 Automated triage by Claude Code, posted through the maintainer's account, not a personal review.

When the repo has a bot or machine account, post under that identity instead so the author itself is
non-personal; the attribution line is the fallback for a personal token.

Write the body to a file and post it with `-F body=@<file>`. The attribution line makes the body
multi-line, which breaks inline `-f body="..."` quoting. A fix reply:

```text
> 🤖 Automated triage by Claude Code, posted through the maintainer's account, not a personal review.

**rebut** fixed in <sha>: <one line on the change>.
```

A refute states the evidence:

```text
> 🤖 Automated triage by Claude Code, posted through the maintainer's account, not a personal review.

**rebut** not changing this: <concrete reason, e.g. a repo lint rule requires it; the gate passes>.
```

```sh
gh api "repos/$OWNER_REPO/pulls/<pr>/comments/<comment_id>/replies" -F body=@/tmp/reply.md
```

**Reply-only, never Resolve.** Post replies through the API; never click "Resolve conversation". The green Resolve button is the human reviewer's, and it is how they *verify* this skill's work: they read each thread, confirm a reply is present, confirm the summary comment exists, and only then resolve. If the skill resolves, the human cannot tell whether they or the agent closed the thread, the exact confusion that makes them re-check or re-run the triage. This skill's entire output is replies plus one summary comment; the Resolve button stays theirs.

**Leave no thread blank.** Every finding gathered in Step 1 gets a reply: a `FIX` with its SHA, or a `REFUTE` / `INTENTIONAL` / `MINOR` with its reason. A bot comment with no response is indistinguishable from un-triaged work: a human reviewer cannot tell whether the skill ran, so they re-invoke it and the round loops. Silence is never a verdict. Disagreeing with a finding still requires a stated reason, never an empty thread.

## Step 5.5: Re-verify CI, then catch the round your fix-push provoked

If Step 4 pushed any fix commits, that push re-triggers CI and a fresh AI-review round. Before summarizing:

- **Re-verify CI.** When checks are still settling, wait with `gh pr checks <pr> --watch`, then classify with `"${CLAUDE_PLUGIN_ROOT}/scripts/ci-status.sh" <pr>`: `ci: green` (exit 0) is clear; `ci: failing` (exit 1) blocks, so debug it; `ci: none` (exit 3) means no CI configured, which is NOT a failure, so note it and move on, exactly as the **implement** skill handles it; `ci: pending` (exit 4) means re-run `--watch`, then re-probe; a read error (exit 2) is not "green", so surface it. Confirm green with your own eyes; never assert it without the script's evidence.
- **Catch the new round.** The fix-push provokes a fresh bot round. Re-run Step 1's gather; if it surfaced new actionable findings, triage them through Steps 2-5, then return to the top of this step. Every push repeats this re-verify and re-gather; the loop ends only when a gather adds nothing new, only acknowledgements, or no comments.

If Step 4 changed nothing because every finding was REFUTE or INTENTIONAL, there is no new push and no new round, so skip straight to Step 6.

## Step 6: Summarize

Close the round with a single triage-summary comment **on the PR conversation**, opened with the same attribution line and the `**rebut**` marker:

```sh
gh api "repos/$OWNER_REPO/issues/<pr>/comments" -F body=@/tmp/summary.md
```

It carries the per-finding verdict table mapping finding → FIX / REFUTE / INTENTIONAL / MINOR → evidence: a commit SHA for a fix, a concrete reason for a refute. It also carries the fix commit SHAs and the `ci-status.sh` result from Step 5.5, reported as "CI is green" only when it truly is (`ci: green`, exit 0), or "no CI configured" when the PR has none (`ci: none`). It ends with a clear "these threads are answered and safe to Resolve."

State the coverage explicitly, **"replied to every finding (N of N)"**, so the human's verification is a glance, not an audit. The human reviewer's job is exactly this check: every AI-reviewer finding has a reply that fixes, refutes, or defers it with a reason, and the summary comment exists; once they confirm it, they Resolve.

This posted comment is the closure artifact. It covers the **review summaries**, the top-level review bodies that are not inline threads you can reply to, and it gives a human the visible proof the round was triaged, so they do not re-invoke the skill and restart the loop. After posting it, hand the same table back to the caller.

## Across rounds: automate re-invocation, never pretend to watch

This skill triages the round in front of it now, plus any round your own fix-push provokes within the same invocation (Step 5.5). It does **not** watch the PR over time: a skill is one invocation with no background process, so any claim to "keep watching until the PR closes" would be fiction. A reviewer, bot or human, who comments tomorrow needs the skill invoked again.

To triage every future round automatically until the PR closes, re-invoke this skill from **outside** it, not from prose inside it: a GitHub Action on the `pull_request_review`, `pull_request_review_comment`, and `issue_comment` events that runs the agent headless, or an equivalent watch loop. Guard it so the fix-push's own review round cannot re-trigger it forever, and run it under a bot or app token rather than a personal one. See `references/continuous-triage.md` for a starting template.

## Red flags: STOP

| Thought                          | Reality                                                                                                                      |
| -------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| "It's CRITICAL, it must be real" | Severity is a heuristic. Verify it like any other.                                                                           |
| "Just apply the suggested diff"  | It may break a repo gate the bot can't see. Verify against the gate first.                                                   |
| "Dismiss it, the bot is noisy"   | A bare dismissal is not a refute. Cite the evidence.                                                                         |
| "Reply with no marker"           | It reads as the maintainer's own words. Open every reply with the Claude Code attribution line, then the `**rebut**` marker. |
| "Resolve the thread too"         | Resolving is the human's decision; this skill replies only.                                                                  |
