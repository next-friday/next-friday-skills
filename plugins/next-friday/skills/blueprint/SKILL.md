---
name: blueprint
description: "Use before any creative or implementation work — designing a feature, building a component, changing behavior, brainstorming, planning, refining requirements, or stress-testing an approach — and before writing any code or scaffolding. Triggers on requests like 'design X', 'let's build X', 'brainstorm this', 'plan this feature', 'how should we structure Y'."
license: MIT
compatibility: "Requires git, the GitHub CLI (gh) authenticated, and a GitHub remote"
argument-hint: "[what to design]"
---

# Blueprint

Turn ideas into fully formed designs through relentless collaborative dialogue, then record the approved design in the **GitHub issue** where the team works — the issue body holds the design and the implementation plan. Every piece of work is tracked by an issue and delivered by a pull request that closes it.

```text
blueprint
  └→ design interview → approved design
       └→ recorded in the GitHub issue body (design + plan)
            └→ implement skill: branch → gates → PR (Closes #issue)
```

<HARD-GATE>
Do NOT write any code, scaffold any project, or take any implementation action until you have presented a design, the user has approved it, and the design is recorded in the issue body. The terminal action of this skill is the implementation plan. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

<HARD-GATE>
Do NOT create or comment on any GitHub artifact until the design has CONVERGED — the user has approved it in chat and no open decisions remain. Recording is the product of an agreed design, not a scratchpad for a moving one. While requirements are still shifting, iterate in chat only. Recording early and then editing/deleting issues as the design changes is the failure this gate prevents.
</HARD-GATE>

## Language Rule

All **artifacts** are English: issue title, body, comments, labels, spec files, code, commits, PR. The chat conversation with the user may be in another language, but anything that lands on GitHub or in the repo is English.

**Artifacts are self-contained.** Never reference another repository inside an issue, spec, or PR — not even as inspiration ("modeled on repo X", "same as our other project"). A public or standalone reader has no access to those repos and a referenced repo may later be deleted, leaving a dangling pointer. Conventions discovered by reading other repos are applied silently: state the requirement directly, never its provenance.

## Scale the Process to the Change

Every **logical change** — the smallest set of edits that ships and reviews as one thing — gets an issue, an approval, and a PR. A logical change carries its own code, tests, docs, and config together in that one PR; they never split into separate PRs. **What scales is the depth of the design work, never the existence of the gate.**

| Tier         | Examples                                                           | Process                                                                                                                                                                                                                                                                                                                                              |
| ------------ | ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Trivial**  | typo, dependency bump, config value, copy change                   | Skip the interview and approaches. Write a 2-4 sentence design (what, why, risk), get one approval, record to the issue, hand off — the design approval also serves as the user review (the design approval and the review step are one). If the repo's template still applies, fill only the sections that are relevant and leave the rest minimal. |
| **Standard** | new feature, behavior change, refactor, bugfix with design choices | Full flow below: interview → approaches → design sections → approval.                                                                                                                                                                                                                                                                                |
| **Large**    | multiple subsystems, platform work                                 | Decompose into sub-issues first; each sub-issue then goes through Standard.                                                                                                                                                                                                                                                                          |

State your tier call and let the user veto it. Misjudged? **Escalate, never downgrade mid-flight:** the moment a "trivial" change sprouts a real decision (interface, data shape, user-visible trade-off), stop and run the Standard flow.

The "too simple to need a design" excuse stays banned — trivial work still gets its 2-4 sentences and an approval. "Simple" changes are where unexamined assumptions cause the most wasted work.

## Batch vs. split

The tier table scales DEPTH; this scales FAN-OUT — how many issues and PRs a session produces. Before opening a second issue or PR, ask whether the new change is RELATED to one already in flight: same surface, same goal, would a reviewer want to see them together. If related and the combined diff stays reviewable — roughly the 400-line ceiling the Amendments rule uses below — it is ONE issue and ONE PR, with one task and one Done per piece. Split into separate PRs only when the changes are UNRELATED, or when combined they would exceed that ceiling. Four PRs for one coherent improvement is fan-out cost — branch juggling, repeated CI, merge sequencing — not cleanliness.

## Checklist

You MUST create a task for each of these items and complete them in order (**Trivial tier:** steps 2-4 collapse into the single short design message and step 5's separate temp-`.md` draft is skipped — the 2-4 sentence design posted in chat IS the draft, and its approval authorizes recording straight to the issue; steps 6, 7, and 8 still run, with step 7's self-review a quick re-read rather than a reviewer-subagent pass):

0. **Preflight `gh`** — run `"${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh"`; if it fails (gh missing/unauthenticated or no GitHub remote), STOP and tell the user (see Preflight) before any other `gh` call
1. **Explore project context** — check files, docs, recent commits, AND existing issues (`gh issue list`)
2. **Interview the decision tree** — resolve root context first, then question relentlessly in dependency order (batch tightly-coupled questions, each with a recommended answer) until shared understanding (see Interviewing below)
3. **Propose 2-3 approaches** — with trade-offs and your recommendation
4. **Present design** — in sections scaled to their complexity, get user approval after each section
5. **Stage the draft for review** — write the converged design to a temp `.md`, link it for the user (forwardable to a reviewer), and wait for their approval before creating the issue (see Draft Review)
6. **Record design** — to the GitHub issue body; the approved draft becomes the body (see Recording the Design)
7. **Self-review** — re-read the recorded design for placeholders, contradictions, ambiguity, scope; for a multi-component issue or any newly created Standard or Large issue also dispatch the reviewer subagent (see Self-Review), and surface any resulting change to the user
8. **Transition to implementation** — write the implementation plan; the **implement** skill ships it

**The terminal state is the implementation plan.** Do NOT jump to writing code, scaffolding, or opening a PR — produce the plan first.

## The Process

**Understanding the idea:**

- Check out the current project state first (files, docs, recent commits)
- Before asking detailed questions, assess scope: if the request describes multiple independent subsystems (e.g., "build a platform with chat, file storage, billing, and analytics"), flag this immediately. Don't spend questions refining details of a project that needs to be decomposed first.
- If the project is too large for a single design, help the user decompose into sub-projects: what are the independent pieces, how do they relate, what order should they be built? Then blueprint the first sub-project through the normal flow. Each sub-project gets its own design → plan → implementation cycle.
- For appropriately-scoped projects, interview the decision tree (below)

**Interviewing: resolve the decision tree:**

Interview the user relentlessly about every aspect of the design until you reach a shared understanding. Don't stop at a handful of questions — walk down each branch of the decision tree, resolving every decision that matters before moving on.

- **Root context — resolve FIRST, before any tooling or structure question.** Three questions gate everything else, and getting them late forces redesigns. Resolve all three before asking about test runners, build tools, or file layout — those decisions all depend on the answers: (1) **What is the real end goal / definition of done?** (2) **Does prior art exist** — is this new, or does it replace, migrate, or continue an existing implementation in this repo or elsewhere (if so, explore it)? (3) **What is the repo's nature and who consumes it** — standalone, open-source/public, internal, a library, a template? This determines portability, governance, and how self-contained the work must be.
- **Dependency order.** After root context, resolve decisions that other decisions depend on first. Don't ask about button colors before you know whether there's a button.
- **Batch tightly-coupled questions; keep branch-deciding ones separate.** Group questions that share the same dependency level into one message (each with its recommended answer, so the user can rubber-stamp the batch with one "yes"). Keep a question separate when its answer re-routes the rest of the tree. Prefer multiple choice; open-ended is fine.
- **Always recommend.** For every question, give your recommended answer and why. The user should be able to just say "yes" to your recommendation.
- **Explore, don't ask.** If a question can be answered by reading the codebase, recent commits, or existing issues, explore it yourself instead of asking. Only ask what the codebase can't tell you (intent, constraints, preferences, trade-offs).
- **Know when to stop.** The tree is resolved when every branch that affects the design has an answer and no new branches are opening. Then move to approaches.

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

**Presenting the design:**

- Once you believe you understand what you're building, present the design
- Scale each section to its complexity: a few sentences if straightforward, up to 200-300 words if nuanced
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense
- **Visuals:** when a question is easier shown than told (mockups, layouts, diagrams), offer visuals once for consent, then decide per question with one test — _would the user understand this better by seeing it than reading it?_ ("which wizard layout?" → yes; "what should this value default to?" → no). Present them as ASCII/markdown inline, Mermaid in the issue body (GitHub renders it), or HTML/SVG in a temp file the user can open

**Design for isolation and clarity:**

- Break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently
- For each unit, you should be able to answer: what does it do, how do you use it, and what does it depend on?
- Can someone understand what a unit does without reading its internals? Can you change the internals without breaking consumers? If not, the boundaries need work.

**Working in existing codebases:**

- Explore the current structure before proposing changes. Follow existing patterns.
- Where existing code has problems that affect the work, include targeted improvements as part of the design.
- Don't propose unrelated refactoring. Stay focused on what serves the current goal.

## Recording the Design

### Depth — make the body a precise spec

The recorded body is the spec the **implement** skill builds from, so it must carry the decisions, contracts, and verification an implementer needs — not a thin sketch. Scale depth to the tier: **Standard** and **Large** issues carry the elements below; **Trivial** keeps its 2-4 sentence design.

**Depth, not ceremony.** Include each element **only when it has content**. Never emit an empty heading as a ritual (`Global Constraints: none`, `Out of scope: nothing`) — that is the placeholder bloat the Self-Review below bans. Mandate the _check_, not a fixed set of headings.

Mandatory for Standard/Large — cheap, always carries information:

- **Decision log** — each material decision: choice + what it rules out + why; add an `Origin` note (user answer / constraint / review finding) only where the driver is non-obvious.
- **File map + reuse callout** — every file to create or modify with its single responsibility, plus what already exists to reuse rather than rewrite.
- **Verification** — concrete command(s) and the expected result that prove each Done criterion.
- **Out of scope** — deliberate skips, each with a one-line reason.

Conditional — include only when the change actually has it:

- **Contracts** (per-task Consumes / Produces, exact signatures + a usage example) — when the work has cross-task seams or a public surface.
- **Global constraints** — when the repo has binding project-wide rules (version floors, naming, platform) every task inherits; copy them verbatim from the repo's own source of truth (`CONTRIBUTING`, the template), never paraphrased.
- **Context / prior-art** — when an existing implementation is replaced, migrated, or continued.

These map onto the repo's issue template (as described below); they never replace it. Fold the decision log and contracts into the template's design/proposal field, the verification into its acceptance criteria, the skips into its out-of-scope field.

### Versioning the body

A reader must be able to return to an earlier design. Two layers cover it:

1. **Native edit history** — GitHub keeps the full edit history of an issue body, viewable in the web UI ("edited ▾"). This is the durable, team-visible backup and needs no extra work; it is also why the design lives in the body, never in a machine-local file a teammate cannot open.
2. **In-body version banner** — once the body has been revised after its first recording, add a banner at the very top of the body, above the first template heading (e.g. `### Goal`), not merely above the plan: `> v2 — <what changed and why>`. Follow it with a short **Revisions** list mapping each change to its trigger (a review finding, a user correction). A v1 body carries no banner.

### Draft Review (before the issue)

Before creating the issue, stage the converged design for the user to review:

- Write the agreed design to a temp Markdown file (`/tmp/<topic>-design.md`) and give the user the clickable path. They review it there, and may forward the file to a human reviewer before anything is recorded to GitHub.
- Wait for the user to approve the draft. Only then create the issue — it is recorded already carrying the approved design.
- The temp file is staging only: it is never committed, and never the handoff to the implement skill. The issue body remains the single source of truth.

### Choose the recording mode

- **The GitHub issue body is the single source of truth** (sections below). The issue is where work is discussed, reviewed, and tracked, and the body holds both the design and the implementation plan.
- **Never write the design or plan to a committed repo file.** `/tmp` is used only as the buffer for `--body-file`; it is never a persisted artifact and never the handoff to the implement skill.

### Preflight

Run `"${CLAUDE_PLUGIN_ROOT}/scripts/preflight.sh"` first — it verifies `gh` is authenticated and the repo has a GitHub remote, printing the fix and exiting non-zero otherwise. If it fails, STOP and tell the user — do NOT silently fall back to writing a local file. Ask them to authenticate or confirm an alternative. If the repo has no GitHub remote (GitLab, Bitbucket, plain git), the script flags it; STOP and ask the user how they track work — this skill is GitHub-specific.

### Title convention — discover, don't invent

Before titling the issue, check whether the repo enforces a convention: look for an issue-title or PR-title validation workflow in `.github/workflows/`, a commitlint config, or a documented rule in `CONTRIBUTING`. If a conventional-commit-style scheme is enforced (commonly `<type>(<scope>): <lowercase description>` with a defined type enum), issue titles MUST follow it. Otherwise mirror the repo's existing commit convention from `git log`; a plain descriptive English title is the last resort. Discover the convention by reading the repo — never assume one repo's scheme applies to another.

### Create vs. update — ASK, don't guess

- **No relevant issue exists** → create one. Confirm before creating ("No existing issue found — create a new one titled `<X>`?"). One yes authorizes that one issue, not a batch; and an earlier constraint such as local-only or draft-only outranks a later broad "do it all" — reconfirm before widening the scope of outward writes.
- **A relevant issue exists** → update its body with the approved design (`gh issue edit <n> --body-file`). The same structure rules apply: when a template/form defines sections, mirror them; self-review reads the updated body. Comments stay a discussion log, not where the design lives.
- **Never auto-match an issue by title similarity.** If unsure which issue, ask the user for the number.

### Use the repo's issue template

Issue structure comes from the repo's own template, which differs per repo. **Always check `.github/ISSUE_TEMPLATE/` first — when a template exists, using it is MANDATORY.** Never invent your own structure over the repo's template.

- **Template exists** → you MUST use it: read the template file yourself and fill its sections with the agreed design (pick the right one if there are several; map the design onto its sections). If it contains a checklist, fill in what's known and leave the rest for the execution phase. Mechanics only: do NOT pass `--template` to `gh issue create` — it is mutually exclusive with `--body`/`--body-file` and drops into an interactive editor an agent cannot drive. Deliver the filled template via `--body-file` instead; the issue content must follow the template's structure exactly.
- **YAML issue forms** (`*.yml` with a `body:` field list, the modern format) cannot be driven via the CLI at all — parse the form schema yourself and emulate it: each field's `label` becomes a `### <Label>` heading in the body, in form order, required fields always filled (this matches how GitHub renders submitted forms). Respect the form's `title:` pattern and apply its `labels:` with `--label`.
- **No template in the repo** → only then use a plain issue body, and mention to the user once that the repo has no issue template.

Always write the body to a temp file and pass `--body-file` — design bodies contain backticks, quotes, and `$` that break inline `--body` shell quoting.

```sh
gh issue create --title "<concise English title>" --body-file /tmp/issue-body.md
gh issue edit <n> --body-file /tmp/issue-body.md   # update an existing issue's body
```

Write the filled body (template-based or plain) to the temp file first. Add `--label <x>` for any template- or scope-derived labels — but only labels that already exist (see Labels below). Follow the form's `title:` pattern when one is defined.

### Labels, assignees, reviewers, sub-issues

- **Label by scope** — apply the labels that match the work's area/size. Only pass `--label` for labels that already exist (check `gh label list`); to add a new label, ask the user first — never create labels unprompted in a shared repo.
- **Invite the relevant people** — assign/mention those who should read what's planned (`--assignee`, or `@mention` in the body). Determine who from CODEOWNERS or by asking the user — never guess.
- **The body is the living design** — when the design changes before approval, rewrite the body (`gh issue edit <n> --body-file`) to the best current whole-picture version; GitHub preserves the body's edit history. Comments are for discussion, questions, and a decision log — never where the design accretes.
- **Sub-issues** — when the scope is large, split it into sub-issues (one shippable piece each) and link them from the parent body as a task list (`- [ ] #<n>`). Each sub-issue gets its own branch **off the default branch** and its own PR, and integrates independently — do not stack one sub-issue's branch on another's. Order them by what unblocks what; under squash-merge especially, sequence them — land one, open the next from the merged default — rather than stacking, which forces duplicate-content rebases.
- **Amendments vs. restructure** — body rewrites refine the design _before approval_. Re-estimate the delivery after each revision: the moment accumulated scope would exceed one reviewable PR (a useful heuristic is roughly 400 changed lines — adjust to the repo's norms), STOP amending and restructure — convert the issue into a tracking epic with a sub-issue task list, one shippable piece each, ordered by what unblocks what. Restructure happens BEFORE implementation starts, never after PRs are open.

### Self-Review

After recording the design, re-read it with fresh eyes:

1. **Placeholder scan:** Any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
2. **Internal consistency:** Do any sections contradict each other? Does the architecture match the feature descriptions?
3. **Scope check:** Focused enough for a single implementation plan, or does it need decomposition?
4. **Ambiguity check:** Could any requirement be interpreted two ways? Pick one and make it explicit.

Fix issues by **updating the issue body** (`gh issue edit <n> --body-file`) so the body always holds the complete current design; GitHub preserves the edit history. For multi-component designs or any newly created Standard or Large issue, also dispatch the reviewer subagent in `spec-issue-reviewer-prompt.md` for a deeper pass; skip it for a Trivial-tier change and for small single-component additions to an existing issue.

### Confirm the recorded design

The user already approved the design as a draft (see Draft Review), so the recorded issue should match what they signed off on. After the self-review and reviewer subagent pass:

> "Design recorded at `<issue URL>` — it matches the draft you approved. I'll write the implementation plan next; tell me if anything needs to change first."

If the self-review or reviewer surfaced any change, point it out explicitly and wait for the user. Apply requested changes by updating the issue body (`gh issue edit <n> --body-file`), then proceed.

### Implementation handoff

After the user approves, write the implementation plan and record it in the **issue body**, after the design — never a committed repo file. The body then holds the complete design + plan as one artifact; comments stay a discussion log.

Write the plan at **task altitude**: state what each task does, which files it touches, and how it's proven. Derivable code is produced test-first in the PR, not pre-baked into the issue, so the body stays readable — **include a full code sketch only** where exact code pins something a signature or prose cannot: an ordering that must not change, an exact data shape, a hard algorithm, or a public-API surface. Otherwise state the contract, not the code.

**Plan header** — open with:

- `**Goal:**` one sentence on what this builds.
- `**Architecture:**` 2-3 sentences on the approach.
- `**Tech Stack:**` the key technologies.
- a line naming the **implement** skill as the executor, with `- [ ]` checkbox steps.

**File map first** — before decomposing, list every file to create or modify with its single responsibility. Files that change together live together; split by responsibility, not by technical layer.

**Right-size each task** — a task is the smallest unit that carries its own test cycle and is worth a fresh reviewer's gate. Fold setup, config, scaffolding, and docs into the task whose deliverable needs them; split only where a reviewer could reject one task while approving its neighbor.

**Ordered tasks** — each task is a checkbox carrying:

- a title and a `**Files:**` block (Create / Modify `path:lines` / Test);
- where the task has seams, a **Consumes / Produces** line naming the exact signatures it takes from earlier tasks and the names/types later tasks rely on — an implementer seeing only this task learns the neighboring contracts here;
- the task's intent, an explicit **Done** criterion (a passing gate, a green test, an observable behavior), and the **Verification** that proves it — the exact command and its expected result;
- for code work, the behavior to test and the key names/signatures it introduces. The test-first code is written during implementation (the implement skill enforces it); a full code sketch appears only under the policy above.

**No placeholders** — these are plan failures, never write them: "TBD/TODO/implement later"; "add appropriate error handling / handle edge cases" without saying what; "write tests for the above" without naming them; "similar to Task N" (state it directly); references to types or functions no task defines. Every task names concrete files and a checkable Done.

**Plan self-review** — before handing off, re-read the plan:

1. **Spec coverage:** every design requirement maps to a task — list any gap.
2. **Placeholder scan:** none of the failures above remain.
3. **Name consistency:** a name introduced in an early task is used identically later (a function called `clearLayers()` in one task and `clearFullLayers()` in another is a bug).

Then, for a new or multi-task plan, dispatch the reviewer subagent in `plan-issue-reviewer-prompt.md` for a Buildability pass; fix what it finds by updating the issue body.

```sh
# rewrite the body to design + plan (multi-line bodies break inline quoting)
gh issue edit <n> --body-file /tmp/issue-body.md
```

Once the plan is in the issue body, the execution phase (branch → code → full gates → commit → PR closing the issue) is handled by the **implement** skill.
