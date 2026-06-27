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
They do not know your repo's local config, conventions, or tooling, so they flag
correct-for-your-repo patterns as bugs, confidently. **A bot's severity is not its correctness**:
a `CRITICAL` can be a false positive, and a nit can hide a real bug.

<HARD-GATE>
Never apply a suggestion and never refute one without first verifying the finding against the
CURRENT code (the verification discipline in `${CLAUDE_SKILL_DIR}/references/verification.md` binds this). Reproduce the claim, or run the gate, or read the convention, then decide.
</HARD-GATE>

<HARD-GATE>
Every reply carries a verdict backed by evidence: a commit SHA for a fix, or a concrete reason
for a refute such as the gate output, the convention, or the line that disproves it. Never post
"you're absolutely right" and never a bare dismissal.
</HARD-GATE>

<HARD-GATE>
Never claim the round is triaged from the post commands' own output. GitHub's secondary rate limit
silently drops replies posted back-to-back, so a printed success line is not proof a reply
persisted. Pace each post and capture the created reply id (`post-reply.sh`), then re-query and
assert `answered N / N` (`verify-coverage.sh`) before summarizing. While any finding is unanswered,
the round is NOT done: re-post the missing ones and re-verify. Coverage is proven by the re-query,
never asserted.
</HARD-GATE>

## Why AI reviewers get their own triage

- **Repo-blind.** The bot does not load your repo's local config — a linter, formatter, or
  type-checker config, whatever your stack uses — or your house rules. It will flag a pattern your
  own tooling REQUIRES. Real example (an ESLint repo): a reviewer marked `meta.defaultOptions` as
  CRITICAL "wrong", but the repo's `require-meta-default-options` lint rule forces it. Applying the
  suggestion would have broken that build. Blind-apply is as dangerous as blind-dismiss.
- **High false-positive rate.** Many findings are speculative or style-only. Some are real bugs
  the human missed. The job is to separate them with evidence, not vibes.
- **Confidently wrong.** Severity labels are heuristics. Verify a `CRITICAL` the same as a nit.

## When the reviewer is a human

The pipeline is the same for **every** reviewer, bot or human: verify against the current code → fix or push back with evidence → reply in-thread under the attribution line → prove coverage. A human contributor or reviewer is part of the triage loop too: when a person asks for a change, fix it and reply, with the same rigor and the same audit trail the human gate reads at merge. Only the **tone** changes, because a human knows the repo, posts fewer and higher-signal findings, and has a face that a blunt refutation can threaten. So when the reviewer is human:

- **Drop the bot framing.** Do not treat their review as repo-blind, high-false-positive noise; it usually is not.
- **Collaborate, do not curtly refute.** Verify, then fix what is right and push back on what is wrong with technical reasoning. Never performative agreement, never a curt "false positive" aimed at a colleague; state the reason in a non-curt, technically-reasoned tone.
- **Post the reply yourself, with the attribution line.** You triage human threads autonomously, same as bot threads: post through the triage account, opened with the attribution line so the reader sees an automated triage and not the maintainer's own peer review. The line that disconnects the comment from the maintainer is exactly what makes auto-posting to a human thread safe. Coverage counts human threads too (Step 5.5), so a human finding left unanswered keeps the round open.

The steps below apply to bots and humans alike; the attribution marker and auto-reply are used for both. The only per-reviewer adaptation is the tone above.

## Preflight

```sh
"${CLAUDE_SKILL_DIR}/scripts/preflight.sh"
```

`preflight.sh` confirms `gh` is authenticated and the repo has a GitHub remote. On a missing prerequisite it prints the fix on stderr and exits non-zero; relay that and stop. Identify the PR: the `[pr-number]` argument, else the PR for the current branch (`gh pr view --json number`).

## Step 1: Gather every finding

```sh
"${CLAUDE_SKILL_DIR}/scripts/gather-review.sh" <pr>
```

`gather-review.sh` prints a `REVIEWS` block holding each review's author, state, and body, and a `COMMENTS` block holding each inline comment's author, `path:line`, `id=<id>`, and body, via `gh`'s built-in `--jq`, so nothing is invented or dropped. List each finding with its author, `path:line`, comment `id` needed to reply, and body. Include the top-level review summaries and every inline comment. Miss none. Tag each thread's author as a bot, recognizable by the `[bot]` login suffix shown in the gathered output, or a human: both follow Steps 4-6, and a human thread additionally takes the tone adjustment in "When the reviewer is a human" above.

**Let the round settle before triaging.** Reviewers fire asynchronously: a second bot often lands its wave minutes after the first, so a gather run the instant the PR updates captures only the reviewers that have posted so far. After the first gather, let the round settle with `gh pr checks <pr> --watch || true`: it blocks until the PR's checks finish and behaves the same interactively and headless, and that is the window asynchronous reviewers post in (the `|| true` keeps a checkless PR's non-zero exit from reading as a failure). Then re-run `gather-review.sh`; if it surfaced new findings, the round is still arriving, so watch and re-gather again. (If the PR has no checks, `--watch` returns at once; and a review-only bot may register no check run at all, so in both cases pause briefly and re-gather regardless of check state. The across-rounds automation below is the real backstop for a reviewer that posts after this settles.) Begin triage only once a re-gather adds nothing new. This handles a multi-reviewer round as ONE triage pass instead of starting on reviewer A's findings while reviewer B is still mid-post, which forces a second full pass. The bound keeps this from waiting forever; the across-rounds automation in the last section is the durable answer for reviewers that post after the skill exits.

## Step 2: Verify each finding (the core of this skill)

For each finding, answer two questions against the **current** code, not the bot's framing:

1. **Does the problem reproduce?** Reproduce it as `${CLAUDE_SKILL_DIR}/references/debugging.md` describes: open the file at the line, trace the logic, construct the input
   the bot describes, and check the actual behavior. If it is a bug, it must be demonstrable.
2. **Is the suggestion correct for THIS repo?** Run the relevant gate the repo defines (its linter,
   type-checker, or tests, whichever exist). Check the documented convention. A fix that passes the bot but fails a repo gate is wrong here.

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
- **Land the whole round in ONE commit and push, never one per finding.** Verify and fix each finding
  one at a time as in Step 2, but stage every fix and commit them together, then push once, under the
  **maintainer's** account, the same account that owns the PR and posts the replies. A per-finding
  push turns one review cycle into several: each push re-runs CI and re-triggers every bot, so five
  fixes become five CI runs and five re-review waves. One commit per round is one CI run and one
  re-review wave. Capture that single SHA; every fix reply in Step 5 cites it. If that push is rejected as non-fast-forward because the remote branch moved on (a release bot's bump or a PR "Update branch" merge added commits during the round), recover, do not stop: `git fetch` then `git rebase origin/<branch>`, re-run the gates, and push again, never `--force`; the rebase rewrites the commit, so re-capture the new SHA and cite that one in the Step 5 replies, not the stale pre-rebase one.

## Step 5: Reply in each thread

Reply to the original comment so it threads inline, never a top-level PR comment.

**Open every reply with the same attribution line, on every thread, without exception.** You post
through the maintainer's `gh` token, so GitHub shows their avatar and a reader assumes they wrote
it. The attribution line names the agent and disconnects the comment from the maintainer,
so automated triage is never mistaken for the maintainer's own review:

> 🤖 Automated triage by Claude Code, posted through the maintainer's account, not a personal review.

When the repo has a bot or machine account, post under that identity instead so the author itself is
non-personal; the attribution line is the fallback for a personal token.

Write the body to a file. The attribution line makes the body multi-line, which breaks inline
`-f body="..."` quoting. A fix reply:

```text
> 🤖 Automated triage by Claude Code, posted through the maintainer's account, not a personal review.

**rebut** fixed in <sha>: <one line on the change>.
```

A refute states the evidence:

```text
> 🤖 Automated triage by Claude Code, posted through the maintainer's account, not a personal review.

**rebut** not changing this: <concrete reason, e.g. a repo lint rule requires it; the gate passes>.
```

Post each reply with `post-reply.sh`, one finding at a time:

```sh
"${CLAUDE_SKILL_DIR}/scripts/post-reply.sh" <pr> <comment_id> /tmp/reply.md
```

`post-reply.sh` paces the post under GitHub's secondary rate limit, then confirms it persisted by
reading the created reply id back from the API response, retrying with backoff when a post is
throttled. It prints the reply id and exits 0 on success; exit 1 means the reply was **not** posted
(do not move on, fix and re-run), exit 2 is a bad argument. Do not hand-roll the raw `gh api
.../replies` call in a loop: back-to-back posts trip the rate limit and vanish, the exact failure
this script exists to prevent. One finding, one `post-reply.sh` call, in sequence.

**Reply-only, never Resolve.** Post replies through the API; never click "Resolve conversation". The green Resolve button is the human reviewer's, and it is how they *verify* this skill's work: they read each thread, confirm a reply is present, confirm the summary comment exists, and only then resolve. If the skill resolves, the human cannot tell whether they or the agent closed the thread, the exact confusion that makes them re-check or re-run the triage. This skill's entire output is replies plus one summary comment; the Resolve button stays theirs.

**Leave no thread blank.** Every finding gathered in Step 1 gets a reply: a `FIX` with its SHA, or a `REFUTE` / `INTENTIONAL` / `MINOR` with its reason. A finding with no response, from a bot or a human, is indistinguishable from un-triaged work: a reviewer cannot tell whether the skill ran, so they re-invoke it and the round loops. Silence is never a verdict. Disagreeing with a finding still requires a stated reason, never an empty thread.

## Step 5.5: Assert coverage, re-verify CI, then catch the round your fix-push provoked

Before summarizing:

- **Assert coverage (always).** After posting, re-query the PR and confirm every finding, bot or human, got a reply from the triage account:

  ```sh
  "${CLAUDE_SKILL_DIR}/scripts/verify-coverage.sh" <pr>
  ```

  It prints one row per finding (`answered` / `MISSING`) then `answered N / M`. Exit 0 means every finding has a reply (the round is covered); exit 1 lists each `MISSING` finding, so re-post those with `post-reply.sh` and re-run until it reports `answered N / N`; exit 2 is a read/argument error, which is not coverage, so surface it. This runs whatever the verdicts were, including an all-REFUTE round where no fix was pushed: a dropped refute reply is as invisible as a dropped fix reply. Never proceed to Step 6 while any finding is `MISSING`.
- **Re-verify CI.** When checks are still settling, wait with `gh pr checks <pr> --watch`, then classify with `"${CLAUDE_SKILL_DIR}/scripts/ci-status.sh" <pr>`: `ci: green` (exit 0) is clear; `ci: failing` (exit 1) blocks, so debug it; `ci: none` (exit 3) means no CI configured, which is NOT a failure, so note it and move on, exactly as the **implement** skill handles it; `ci: pending` (exit 4) means re-run `--watch`, then re-probe; a read error (exit 2) is not "green", so surface it. Confirm green with your own eyes; never assert it without the script's evidence. If Step 4 changed nothing because every finding was REFUTE or INTENTIONAL, there is no new push, so this CI re-verify and the round-catch below have nothing to re-trigger; the coverage assertion above still runs.
- **Catch the new round.** The fix-push provokes a fresh bot round, and a **second reviewer** that was still queued at first gather (e.g. one bot posts minutes after another) lands its findings after this pass began. Re-run Step 1's gather; if it surfaced new findings, triage them through Steps 2-5, re-run the coverage assertion, then return to the top of this step. Every push repeats this re-verify and re-gather; the loop ends only when a gather adds nothing new, only acknowledgements, or no comments. If instead the same finding keeps reopening, or about three rounds pass without converging, STOP and surface it to the user rather than looping on: repeated non-convergence means the fix or the bot's expectation is wrong, not that the next round settles it. A single invocation cannot catch a reviewer that comments after it exits: for any PR that draws **more than one reviewer**, the continuous-triage automation below is the recommended default, not an afterthought.

## Step 6: Summarize

Close the round with a single triage-summary comment **on the PR conversation**, opened with the same attribution line and the `**rebut**` marker:

```sh
gh api "repos/{owner}/{repo}/issues/<pr>/comments" -F body=@/tmp/summary.md
```

It carries the per-finding verdict table mapping finding → FIX / REFUTE / INTENTIONAL / MINOR → evidence: a commit SHA for a fix, a concrete reason for a refute. It also carries the fix commit SHAs and the `ci-status.sh` result from Step 5.5, reported as "CI is green" only when it truly is (`ci: green`, exit 0), or "no CI configured" when the PR has none (`ci: none`). It ends with a clear "these threads are answered and safe to Resolve."

State the coverage explicitly, **"replied to every finding (N of N)"**, taken from the `answered N / N` line that `verify-coverage.sh` printed in Step 5.5, never a count done by hand; that script counts every top-level inline finding, bot and human alike, so the N already folds in any human reviewer's threads. Post this comment only once that script has reported full coverage; if it still shows any `MISSING`, the round is not done and there is nothing to summarize yet. So the human's verification is a glance, not an audit. The human reviewer's job is exactly this check: every finding has a reply that fixes, refutes, or defers it with a reason, and the summary comment exists; once they confirm it, they Resolve.

This posted comment is the closure artifact. It covers the **review summaries**, the top-level review bodies that are not inline threads you can reply to, and it gives a human the visible proof the round was triaged, so they do not re-invoke the skill and restart the loop. After posting it, hand the same table back to the caller.

## Across rounds: automate re-invocation, never pretend to watch

This skill triages the round in front of it now, plus any round your own fix-push provokes within the same invocation (Step 5.5). It does **not** watch the PR over time: a skill is one invocation with no background process, so any claim to "keep watching until the PR closes" would be fiction. A reviewer, bot or human, who comments tomorrow needs the skill invoked again.

To triage every future round automatically until the PR closes, re-invoke this skill from **outside** it, not from prose inside it: a GitHub Action on the `pull_request_review`, `pull_request_review_comment`, and `issue_comment` events that runs the agent headless, or an equivalent watch loop. Guard it so the fix-push's own review round cannot re-trigger it forever, and run it under a bot or app token rather than a personal one. See `references/continuous-triage.md` for a starting template.

**For any PR that draws more than one reviewer, treat this automation as the recommended default, not an optional extra.** Reviewers fire asynchronously: one bot can post minutes after another, often after a fix-push, so its findings land after a single manual invocation has already exited and reported done. A one-shot run covers only the reviewers present while it ran; the event-driven re-invocation is what guarantees the later round is triaged at all. Run the skill by hand for a quick single-reviewer pass; wire the automation when a PR is expected to attract a second.

## Red flags: STOP

| Thought                                              | Reality                                                                                                                                                                                                                                    |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| "It's CRITICAL, it must be real"                     | Severity is a heuristic. Verify it like any other.                                                                                                                                                                                         |
| "Just apply the suggested diff"                      | It may break a repo gate the bot can't see, and the diff itself can be malformed — on one occasion a real suggestion injected an unrelated path into the prose. Verify against the current file and apply the point, not the literal diff. |
| "Dismiss it, the bot is noisy"                       | A bare dismissal is not a refute. Cite the evidence.                                                                                                                                                                                       |
| "A scanner flagged `--force` or a dangerous pattern" | A skill or doc that *names* a dangerous command to forbid it ("never `--force`") trips string-matching scanners. Verify what the line actually does before treating a scanner hit as a real finding.                                       |
| "The bot replied 'thanks, addressed'"                | An acknowledgement is a round-end signal, not a new finding. Do not reply to an ack; a reply to an ack is what loops the round forever.                                                                                                    |
| "Reply with no marker"                               | It reads as the maintainer's own words. Open every reply with the Claude Code attribution line, then the `**rebut**` marker.                                                                                                               |
| "Posts all printed success"                          | A printed line is not a persisted reply; the rate limit drops them silently. Re-query with `verify-coverage.sh`.                                                                                                                           |
| "Posting in a loop is faster"                        | Back-to-back posts trip the secondary limit and vanish. Pace one at a time via `post-reply.sh`, which confirms each id.                                                                                                                    |
| "Resolve the thread too"                             | Resolving is the human's decision; this skill replies only.                                                                                                                                                                                |
