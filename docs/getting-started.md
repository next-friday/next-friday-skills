# Getting Started

Your first issue → pull request → green CI cycle with the next-friday skills, start to finish.

## Before you start

You need three things in place. If any is missing, the [README](../README.md#installation) covers setup:

- The **next-friday plugin installed** in your coding agent, such as Claude Code. See the [install steps](../README.md#installation).
- The **`gh` CLI authenticated**. Check with `gh auth status`.
- A **GitHub-hosted repository** to work in.

That is the whole setup. You drive everything in plain language, and the skills supply the discipline. They usually trigger on their own. You rarely name one, though you always can if it does not catch.

**The shape of every change.** One spine, from idea to merged:

`issue → branch → gates → pull request → green CI → triage`

The **gates** and **CI** are whatever your repo already runs: linters, type checks, tests. If it runs none, there is simply nothing to wait on. Three skills cover the spine:

- **blueprint** turns your idea into an approved GitHub issue holding the design and the plan.
- **implement** ships that issue as a pull request and watches CI to green.
- **rebut** triages any AI code-review comments that land on the pull request, when your repo runs a review bot.

## Your first cycle

Pick a real change. The running example here is **"add rate limiting to the public API"**, small enough to finish but big enough to have a design worth discussing. Substitute your own.

### 1. Describe it: blueprint designs with you

Tell your agent what you want, in plain language:

> "Add rate limiting to our public API."

**blueprint** activates before any code. It reads your repo for context, then interviews you. Questions are batched by dependency, each with a recommended answer, so you can reply in shorthand:

> "1: per-API-key, 2: 100 req/min, 3: 429 with Retry-After"

It proposes two or three approaches, presents the design in reviewable sections, and waits. Nothing is built yet. When you approve, just say so in chat. It then records the design as a **GitHub issue**, filled from your repo's issue template, and writes the implementation plan into that same issue body. One link now holds the whole design.

You approve once. The issue is the source of truth; there is no spec file to keep in sync.

### 2. Build it: implement ships the PR

Point implement at the issue blueprint just created. Here it is `#42`, though yours will differ:

> "Implement issue #42."

**implement** takes over the mechanical discipline:

- Branches from the issue, linked so the PR will close it.
- Works task by task from the plan, in small steps.
- Runs **every gate your repo defines**, such as linters, type checks, tests, and commit-message rules, all discovered from your repo, not assumed.
- Opens a **pull request** from your repo's template, with `Closes #42`.
- Watches CI. **Red CI means not done.** It fixes the cause and pushes again, never bypasses the gate.

You get a green pull request that closes the issue, and you did not type a single git command.

### 3. Triage the review: rebut answers the bots

Once the PR is open, an AI code reviewer such as CodeRabbit or Gemini Code Assist, if your repo runs one, posts findings: real bugs mixed with false positives. **rebut** activates on that round:

- Verifies **each** finding against the real code.
- Fixes the ones that reproduce.
- Refutes the false positives with evidence, in-thread.
- Replies to every comment, marked as automated triage, so a human can see the round was handled.

Verification decides, not the severity label the bot attached.

That is one full cycle: **idea → approved issue → green PR → triaged review.** Merge when you are happy with it.

## When something snags

First-run friction is almost always one of these:

- **The skill did not trigger.** Phrase the request in terms of building or shipping ("design…", "implement issue #N", "open a PR"). If it still does not catch, name it: "Use blueprint to design this."
- **`gh` is not authenticated.** blueprint, implement, and rebut check first and stop early. Run `gh auth status`, then `gh auth login`.
- **No issue or PR template in your repo.** The skills fall back to a sensible default and keep going. You do not need to create one first.
- **CI is red.** implement treats that as not done: it reads the failing job and fixes the cause, rather than marking the work complete.
- **No AI reviewer on the PR.** rebut only has work when a review bot comments. None configured means nothing to triage, and the cycle is still complete at green CI.
- **You want changes after the design is recorded.** Say so. blueprint rewrites the issue body, and GitHub keeps the full edit history.

## Where to go next

- **[README](../README.md)**: the failure modes these skills fix, plus a per-skill reference.
- **[blueprint](../plugins/next-friday/skills/blueprint/SKILL.md) · [implement](../plugins/next-friday/skills/implement/SKILL.md) · [rebut](../plugins/next-friday/skills/rebut/SKILL.md)**: what each skill does in full, with its tiers and gates.
- **[Continuous triage](../plugins/next-friday/skills/rebut/references/continuous-triage.md)**: a skill handles the review round in front of it. To triage every future round until the PR closes, wire up the GitHub Action template here.
- **[CONTRIBUTING](../CONTRIBUTING.md)**: if you want to extend or sharpen the skills themselves.
