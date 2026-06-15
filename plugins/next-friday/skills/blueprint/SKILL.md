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

Every change — including a one-line fix — gets an issue, an approval, and a PR. **What scales is the depth of the design work, never the existence of the gate.**

| Tier         | Examples                                                           | Process                                                                                                                                                                                                                                                                                                                                              |
| ------------ | ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Trivial**  | typo, dependency bump, config value, copy change                   | Skip the interview and approaches. Write a 2-4 sentence design (what, why, risk), get one approval, record to the issue, hand off — the design approval also serves as the user review (the design approval and the review step are one). If the repo's template still applies, fill only the sections that are relevant and leave the rest minimal. |
| **Standard** | new feature, behavior change, refactor, bugfix with design choices | Full flow below: interview → approaches → design sections → approval.                                                                                                                                                                                                                                                                                |
| **Large**    | multiple subsystems, platform work                                 | Decompose into sub-issues first; each sub-issue then goes through Standard.                                                                                                                                                                                                                                                                          |

State your tier call and let the user veto it. Misjudged? **Escalate, never downgrade mid-flight:** the moment a "trivial" change sprouts a real decision (interface, data shape, user-visible trade-off), stop and run the Standard flow.

The "too simple to need a design" excuse stays banned — trivial work still gets its 2-4 sentences and an approval. "Simple" changes are where unexamined assumptions cause the most wasted work.

## Checklist

You MUST create a task for each of these items and complete them in order (**Trivial tier:** steps 2-4 collapse into the single short design message):

0. **Preflight `gh`** — run `gh auth status`; if `gh` is missing/unauthenticated or the repo has no GitHub remote, STOP and tell the user (see Preflight) before any other `gh` call
1. **Explore project context** — check files, docs, recent commits, AND existing issues (`gh issue list`)
2. **Interview the decision tree** — resolve root context first, then question relentlessly in dependency order (batch tightly-coupled questions, each with a recommended answer) until shared understanding (see Interviewing below)
3. **Propose 2-3 approaches** — with trade-offs and your recommendation
4. **Present design** — in sections scaled to their complexity, get user approval after each section
5. **Record design** — to the GitHub issue body (see Recording the Design)
6. **Self-review** — re-read the recorded design for placeholders, contradictions, ambiguity, scope; for a new or multi-component issue also dispatch the reviewer subagent (see Self-Review)
7. **User reviews the recorded design** — ask the user to review before proceeding
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
- **Visuals:** when a question is easier shown than told (mockups, layouts, diagrams), offer visuals once for consent, then decide per question — ASCII/markdown inline, Mermaid in the issue body (GitHub renders it), or HTML/SVG in a temp file the user can open

**Design for isolation and clarity:**

- Break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently
- For each unit, you should be able to answer: what does it do, how do you use it, and what does it depend on?
- Can someone understand what a unit does without reading its internals? Can you change the internals without breaking consumers? If not, the boundaries need work.

**Working in existing codebases:**

- Explore the current structure before proposing changes. Follow existing patterns.
- Where existing code has problems that affect the work, include targeted improvements as part of the design.
- Don't propose unrelated refactoring. Stay focused on what serves the current goal.

## Recording the Design

### Choose the recording mode

- **The GitHub issue body is the single source of truth** (sections below). The issue is where work is discussed, reviewed, and tracked, and the body holds both the design and the implementation plan.
- **Never write the design or plan to a committed repo file.** `/tmp` is used only as the buffer for `--body-file`; it is never a persisted artifact and never the handoff to the implement skill.

### Preflight

Run `gh auth status` first. If `gh` is missing or unauthenticated, STOP and tell the user — do NOT silently fall back to writing a local file. Ask them to authenticate or confirm an alternative. If the repo has no GitHub remote (GitLab, Bitbucket, plain git), STOP and ask the user how they track work; this skill is GitHub-specific.

### Title convention — discover, don't invent

Before titling the issue, check whether the repo enforces a convention: look for an issue-title or PR-title validation workflow in `.github/workflows/`, a commitlint config, or a documented rule in `CONTRIBUTING`. If a conventional-commit-style scheme is enforced (commonly `<type>(<scope>): <lowercase description>` with a defined type enum), issue titles MUST follow it. Otherwise mirror the repo's existing commit convention from `git log`; a plain descriptive English title is the last resort. Discover the convention by reading the repo — never assume one repo's scheme applies to another.

### Create vs. comment — ASK, don't guess

- **No relevant issue exists** → create one. Confirm before creating ("No existing issue found — create a new one titled `<X>`?").
- **A relevant issue exists** → comment the design onto it. The same structure rules apply to the comment body as to a new issue body: when a template/form defines sections, mirror them; and self-review reads the comment, not the original issue body.
- **Never auto-match an issue by title similarity.** If unsure which issue, ask the user for the number.

### Use the repo's issue template

Issue structure comes from the repo's own template, which differs per repo. **Always check `.github/ISSUE_TEMPLATE/` first — when a template exists, using it is MANDATORY.** Never invent your own structure over the repo's template.

- **Template exists** → you MUST use it: read the template file yourself and fill its sections with the agreed design (pick the right one if there are several; map the design onto its sections). If it contains a checklist, fill in what's known and leave the rest for the execution phase. Mechanics only: do NOT pass `--template` to `gh issue create` — it is mutually exclusive with `--body`/`--body-file` and drops into an interactive editor an agent cannot drive. Deliver the filled template via `--body-file` instead; the issue content must follow the template's structure exactly.
- **YAML issue forms** (`*.yml` with a `body:` field list, the modern format) cannot be driven via the CLI at all — parse the form schema yourself and emulate it: each field's `label` becomes a `### <Label>` heading in the body, in form order, required fields always filled (this matches how GitHub renders submitted forms). Respect the form's `title:` pattern and apply its `labels:` with `--label`.
- **No template in the repo** → only then use a plain issue body, and mention to the user once that the repo has no issue template.

Always write the body to a temp file and pass `--body-file` — design bodies contain backticks, quotes, and `$` that break inline `--body` shell quoting.

```sh
gh issue create --title "<concise English title>" --body-file /tmp/issue-body.md
gh issue comment <n> --body-file /tmp/design-comment.md
```

Write the filled body (template-based or plain) to the temp file first. Add `--label <x>` for any template- or scope-derived labels — but only labels that already exist (see Labels below). Follow the form's `title:` pattern when one is defined.

### Labels, assignees, reviewers, sub-issues

- **Label by scope** — apply the labels that match the work's area/size. Only pass `--label` for labels that already exist (check `gh label list`); to add a new label, ask the user first — never create labels unprompted in a shared repo.
- **Invite the relevant people** — assign/mention those who should read what's planned (`--assignee`, or `@mention` in the body). Determine who from CODEOWNERS or by asking the user — never guess.
- **The body is the living design** — when the design changes before approval, rewrite the body (`gh issue edit <n> --body-file`) to the best current whole-picture version; GitHub preserves the body's edit history. Comments are for discussion, questions, and a decision log — never where the design accretes.
- **Sub-issues** — when the scope is large, split it into sub-issues (one shippable piece each) and link them from the parent body as a task list (`- [ ] #<n>`). Each sub-issue gets its own branch and PR later.
- **Amendments vs. restructure** — body rewrites refine the design _before approval_. Re-estimate the delivery after each revision: the moment accumulated scope would exceed one reviewable PR (a useful heuristic is roughly 400 changed lines — adjust to the repo's norms), STOP amending and restructure — convert the issue into a tracking epic with a sub-issue task list, one shippable piece each, ordered by what unblocks what. Restructure happens BEFORE implementation starts, never after PRs are open.

### Self-Review

After recording the design, re-read it with fresh eyes:

1. **Placeholder scan:** Any "TBD", "TODO", incomplete sections, or vague requirements? Fix them.
2. **Internal consistency:** Do any sections contradict each other? Does the architecture match the feature descriptions?
3. **Scope check:** Focused enough for a single implementation plan, or does it need decomposition?
4. **Ambiguity check:** Could any requirement be interpreted two ways? Pick one and make it explicit.

Fix issues by **updating the issue body** (`gh issue edit <n> --body-file`) so the body always holds the complete current design; GitHub preserves the edit history. For multi-component designs or any newly created issue, also dispatch the reviewer subagent in `spec-issue-reviewer-prompt.md` for a deeper pass; skip it only for small single-component additions to an existing issue.

### User Review Gate

After the self-review passes, ask the user to review:

> "Design recorded at `<issue URL>`. Please review it and let me know if you want changes before we write the implementation plan."

Wait for the user. If they request changes, append a revision comment and re-run the self-review. Only proceed once the user approves.

### Implementation handoff

After the user approves, write the implementation plan and record it in the **issue body**, after the design — never a committed repo file. The body then holds the complete design + plan as one artifact; comments stay a discussion log.

A good plan: bite-sized ordered tasks (a few minutes each), exact files per task, actual code/tests per step (no placeholders), checkbox steps (`- [ ]`), DRY / YAGNI / TDD, frequent commits.

```sh
# rewrite the body to design + plan (multi-line bodies break inline quoting)
gh issue edit <n> --body-file /tmp/issue-body.md
```

Once the plan is in the issue body, the execution phase (branch → code → full gates → commit → PR closing the issue) is handled by the **implement** skill.
