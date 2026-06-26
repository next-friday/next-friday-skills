# Architecture

How the next-friday plugin is built, for contributors who extend it. [CONTRIBUTING](../CONTRIBUTING.md) covers the *process*: issue to merged pull request. This covers the *mechanism*: how the pieces fit and what holds them together.

## Repo shape and packaging

The root `.claude-plugin/marketplace.json` lists every plugin. Each plugin is one directory under `plugins/`:

```text
plugins/next-friday/
  .claude-plugin/plugin.json     manifest (name, version, description)
  skills/<name>/SKILL.md         one skill each: blueprint, implement, rebut
  skills/<name>/scripts/*.sh     per-skill helper scripts (generated; ship with the skill)
  scripts/*.sh                   canonical script library (the single source)
  hooks/                         hooks.json + the session-start script
```

**Two install models, and a skill must survive both.** As a plugin, the whole `plugins/next-friday/` tree is copied and `${CLAUDE_PLUGIN_ROOT}` points at its root. As a standalone skill through the `skills` CLI (`npx skills add`), only the directory holding a `SKILL.md` is copied, nothing beside it, and `${CLAUDE_PLUGIN_ROOT}` is never set. So a file a skill references at run time must live inside that skill's own directory. This is why each skill carries its own `scripts/` (see [The script library](#the-script-library)) instead of reaching up to the plugin-root `scripts/`: a path that works only under a plugin install is a dead link for someone who installed standalone, and the reverse.

There is no build step and no test runner. Content is markdown and portable bash. The gates are the five `validate:*` scripts plus `claude plugin validate .`.

## The anti-hallucination spine

A skill is two layers:

- **`SKILL.md` is intent**: prose the model reads. When to act, why, and what counts as done. Anything needing judgment lives here.
- **`scripts/*.sh` are the exact steps**: the deterministic `gh`/`git` work that must run identically every time and must never be improvised. Anything mechanical and outward-facing lives here.

The rule of thumb: if a step is deterministic and touches the outside world, such as reading a PR's checks, gathering its review comments, or locating a template, it belongs in a script. If it needs a decision, such as whether a finding is real or a design is right, it stays in the skill.

**The seam between the two layers is the exit code.** A script collapses a messy reality into a small set of numbered outcomes; the `SKILL.md` branches on those numbers. Change a code and you change the calling skill. They are one contract written in two files.

## The script library

The canonical scripts are the single source at `plugins/next-friday/scripts/`. Each skill that calls one carries its own copy under `skills/<name>/scripts/`, generated from the canonical source by `scripts/sync-skill-scripts.sh` (it scans each `SKILL.md` for `${CLAUDE_SKILL_DIR}/scripts/<name>.sh` references and copies in exactly those) and guarded by the `validate:scripts` gate, which fails CI if a copy drifts. The table below is descriptive; the `SKILL.md` references are what the sync keys on. A skill invokes its copy as `"${CLAUDE_SKILL_DIR}/scripts/<name>.sh"`: `${CLAUDE_SKILL_DIR}` is the directory holding the active `SKILL.md`, substituted by Claude Code into the skill body before the model runs it, and it resolves under both install models above, whereas `${CLAUDE_PLUGIN_ROOT}` is plugin-only. Which skill calls which:

| script               | blueprint | implement | rebut |
| -------------------- | :-------: | :-------: | :---: |
| `preflight.sh`       |     ✓     |     ✓     |   ✓   |
| `pr-template.sh`     |           |     ✓     |       |
| `ci-status.sh`       |           |     ✓     |   ✓   |
| `gather-review.sh`   |           |           |   ✓   |
| `post-reply.sh`      |           |           |   ✓   |
| `verify-coverage.sh` |           |           |   ✓   |

Constraints every script keeps: portable `bash` under `set -euo pipefail`, with no GNU-only tools and `gh`'s built-in `--jq` rather than system `jq`, and a documented exit-code contract in its header comment. The header *is* the interface. Read it before calling, because **the codes are local to each script**: `1` means *failing checks* in `ci-status.sh` but *hard failure* in `preflight.sh` and `gather-review.sh`. Don't assume a number carries the same meaning across the library.

### `preflight.sh` (no arguments)

The gate before any outward action. Checks, in order: `gh` installed, `gh` authenticated, `git` installed, inside a work tree, a `github.com` remote. Prints `preflight: ok` and exits `0`. Any failure prints the missing piece plus its fix on stderr and exits `1`, so the skill can tell the user instead of guessing.

### `ci-status.sh <pr>`

Probe a pull request's checks and classify them deterministically, so "no checks configured" is never mistaken for a failure. It reads the state column, not `gh`'s own exit code, which varies by version. Prints the rows, then a final `ci: <status>` line. Exit codes:

- `0` green: every check concluded successfully
- `1` failing: at least one check failed, and failing outranks pending
- `2`: bad argument, or checks could not be read. This is a transient `gh`/network/auth failure, distinct from "none"
- `3` none: the PR has no checks configured; not a failure
- `4` pending: checks still running; watch with `gh pr checks <pr> --watch`, then re-probe

### `gather-review.sh <pr>`

Print every review summary and every inline review comment on a pull request, so triage works from the findings that exist instead of fabricated or dropped ones. It prints two blocks. The `=== REVIEWS ===` block holds `[login] state` plus body, and the `=== COMMENTS ===` block holds `[login] path:line id=<id>` plus body. The `id=` is what lets `rebut` reply in the exact thread. Results are paginated; a null inline line renders as an empty field, never an error. Exits `2` on a bad argument, `1` if the repo can't be resolved. Run preflight first.

### `pr-template.sh` (no arguments)

Locate and print the repo's pull-request template so `implement` fills the real sections instead of inventing its own. stdout is the template body; stderr is the path used. It searches GitHub's own resolution order: `.github/`, the root, `docs/`, then a `PULL_REQUEST_TEMPLATE/` directory, which is listed rather than guessed. Exits `0` when found, `3` when none, so the caller falls back to a Summary / Changes / How to verify body plus `Closes #<n>`.

### `post-reply.sh <pr> <comment-id> <body-file>`

Post one threaded reply to an inline review comment, paced under GitHub's secondary rate limit, and confirm it persisted by reading the created reply id back from the API rather than trusting a shell exit code. Retries with backoff when a post is throttled; pace and attempt count are env-tunable. stdout is the created reply id. Exit codes:

- `0` posted: the reply id is on stdout
- `1` every attempt failed: the reply was not posted, so the caller must not move on
- `2`: bad arguments, or the repo could not be resolved

Posting one reply at a time through this script is why a tight reply loop no longer drops replies silently.

### `verify-coverage.sh <pr>`

Re-query a pull request after triage and assert that every inline bot finding received a reply from the triage account (the account whose `gh` token posts the replies: the authenticated user, or a bot/machine account), so a silently dropped reply can never pass as "all threads answered". Prints one row per finding (`answered` or `MISSING`), then a final `answered N / M` line. Exit codes:

- `0`: every finding has a reply, including the case of none to answer
- `1`: at least one finding is unanswered
- `2`: bad argument, or the repo or account could not be resolved

This is the gate `rebut` checks before it claims a round is done; the count comes from the re-query, never from the post commands' own output.

## Skill anatomy

A skill is a `SKILL.md` plus optional helper files under a `references/` subdirectory.

**Frontmatter.** `name` must equal the directory name. `description` states triggering conditions only: *when* to reach for the skill, never the workflow itself, because that text is what the agent matches against to decide. `validate:skills` enforces both, plus a length cap on the description.

**Reference resolution**, two forms, both checked by `validate:skills`:

- **Sibling files under `references/`**, for example `references/continuous-triage.md`, named by that relative path from the `SKILL.md`. They ship because they live inside the plugin. The validator confirms each referenced file resolves, and that no file under `references/` sits unreferenced as dead weight.
- **Scripts**, named as `"${CLAUDE_SKILL_DIR}/scripts/<name>.sh"` and carried in the skill's own `scripts/` directory (generated from the canonical source). The validator confirms each resolves to an executable inside the skill.

**The SessionStart hook.** `hooks/hooks.json` wires `hooks/session-start` to run on `startup`, `clear`, and `compact`. The script emits one `additionalContext` string, the field a SessionStart hook returns to the agent, pointing it at blueprint / implement / rebut, so the workflow is reached for rather than skipped. Keep it a pointer, never a copy of the skill bodies. `validate:skills` confirms the hook script exists and is executable.

**Composition.** The three skills form one spine: **blueprint** (idea → approved issue holding design and plan) → **implement** (issue → green pull request) → **rebut** (triage the AI review). The issue body is the source of truth the whole way through; each skill hands the next a concrete artifact, not a chat scrollback.

## Extending safely

### Stay stack-agnostic

The skills run in *other people's* repositories. Name only the universal substrate concretely: Git, GitHub, `gh`, and the issue → branch → gates → pull request → green CI spine. Keep review bots, CI systems, and issue trackers generic and discovered at runtime: describe the role, not the brand. A concrete tool name appears only as a hedged example, written "such as …". Repo-local conventions, like this repo's no-prose-comments rule, must never leak into a skill body.

### Add or change a script

1. Add or edit the canonical copy under `plugins/next-friday/scripts/`. Portable `bash`, `set -euo pipefail`, `gh --jq` only.
2. Document the exit-code contract in the header. That is the interface.
3. `chmod +x` it.
4. Reference it from the `SKILL.md` as `"${CLAUDE_SKILL_DIR}/scripts/<name>.sh"` and branch on its exit codes.
5. Run `scripts/sync-skill-scripts.sh`; it reads the `${CLAUDE_SKILL_DIR}/scripts/<name>.sh` reference you added in step 4 and copies the script into each referencing skill's `scripts/`. Commit the generated copies.
6. Change a code's meaning and you update every calling `SKILL.md` in the same change.
7. Run `validate:scripts` (the copies match the source) and `validate:skills` (every referenced script resolves to an executable inside the skill).

### Add or change a skill

- `name` equals the directory; `description` is triggers only.
- Put helper prose and templates under `references/`, and reference them so they aren't flagged as dead weight.
- Prefer sharpening an existing skill to adding a new one, so the set stays small and composable. Fold lessons from real use back into the skill in the same change that exposed them.

### The gates that guard you

These are `pnpm` scripts. Run them as `pnpm validate:skills`, and so on:

- `validate:markdown`: markdown is clean.
- `validate:comments`: no prose code comments (repo-local).
- `validate:versions`: each `plugin.json` version matches its `package.json`. It runs `sync-plugin-version.sh`, then fails on any diff.
- `validate:scripts`: each skill's generated `scripts/` match the canonical source. It runs `sync-skill-scripts.sh`, then fails on any drift.
- `validate:references`: each skill's shared `references/` copies match the canonical source at `plugins/next-friday/references/`. It runs `sync-skill-references.sh` — which scans each `SKILL.md` for `${CLAUDE_SKILL_DIR}/references/<name>.md` and copies in the matching canonical docs, additively, so a skill's own unique references are left untouched — then fails on any drift.
- `validate:skills`: the name, description, reference, and hook contracts above.
- `claude plugin validate .`: manifests and skill frontmatter.

Each plugin's `package.json` owns its version number; `scripts/sync-plugin-version.sh` propagates it into the manifest. Never hand-edit a manifest version. CONTRIBUTING owns the full commit → changeset → release flow; this list is only what the gates structurally enforce.
