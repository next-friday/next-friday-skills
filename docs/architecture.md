# Architecture

How the next-friday plugin is built, for contributors who extend it. [CONTRIBUTING](../CONTRIBUTING.md) covers the *process*: issue to merged pull request. This covers the *mechanism*: how the pieces fit and what holds them together.

## Repo shape and packaging

The root `.claude-plugin/marketplace.json` lists every plugin. Each plugin is one directory under `plugins/`:

```text
plugins/next-friday/
  .claude-plugin/plugin.json   manifest (name, version, description)
  skills/<name>/SKILL.md        one skill each: blueprint, implement, rebut
  scripts/*.sh                  the shared script library
  hooks/                        hooks.json + the session-start script
```

**The packaging unit is the plugin directory.** On install, the whole `plugins/next-friday/` tree is copied, and nothing outside it. A file a skill references must live inside the plugin, or it resolves to a dead link for everyone who installed it; a path that works in this repo is not enough.

There is no build step and no test runner. Content is markdown and POSIX shell. The gates are the four `validate:*` scripts plus `claude plugin validate .`.

## The anti-hallucination spine

A skill is two layers:

- **`SKILL.md` is intent**: prose the model reads. When to act, why, and what counts as done. Anything needing judgment lives here.
- **`scripts/*.sh` are the exact steps**: the deterministic `gh`/`git` work that must run identically every time and must never be improvised. Anything mechanical and outward-facing lives here.

The rule of thumb: if a step is deterministic and touches the outside world, such as reading a PR's checks, gathering its review comments, or locating a template, it belongs in a script. If it needs a decision, such as whether a finding is real or a design is right, it stays in the skill.

**The seam between the two layers is the exit code.** A script collapses a messy reality into a small set of numbered outcomes; the `SKILL.md` branches on those numbers. Change a code and you change the calling skill. They are one contract written in two files.

## The script library

Every skill invokes a script as `"${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh"`, an absolute path the plugin loader fills in at the installed plugin root when a skill runs. It is unset if you run a script by hand from the repo. Which skill calls which:

| script             | blueprint | implement | rebut |
| ------------------ | :-------: | :-------: | :---: |
| `preflight.sh`     |     ✓     |     ✓     |   ✓   |
| `pr-template.sh`   |           |     ✓     |       |
| `ci-status.sh`     |           |     ✓     |   ✓   |
| `gather-review.sh` |           |           |   ✓   |

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

## Skill anatomy

A skill is a `SKILL.md` plus optional helper files under a `references/` subdirectory.

**Frontmatter.** `name` must equal the directory name. `description` states triggering conditions only: *when* to reach for the skill, never the workflow itself, because that text is what the agent matches against to decide. `validate:skills` enforces both, plus a length cap on the description.

**Reference resolution**, two forms, both checked by `validate:skills`:

- **Sibling files under `references/`**, for example `references/continuous-triage.md`, named by that relative path from the `SKILL.md`. They ship because they live inside the plugin. The validator confirms each referenced file resolves, and that no file under `references/` sits unreferenced as dead weight.
- **Scripts**, named as `"${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh"`. The validator confirms each resolves to an executable.

**The SessionStart hook.** `hooks/hooks.json` wires `hooks/session-start` to run on `startup`, `clear`, and `compact`. The script emits one `additionalContext` string, the field a SessionStart hook returns to the agent, pointing it at blueprint / implement / rebut, so the workflow is reached for rather than skipped. Keep it a pointer, never a copy of the skill bodies. `validate:skills` confirms the hook script exists and is executable.

**Composition.** The three skills form one spine: **blueprint** (idea → approved issue holding design and plan) → **implement** (issue → green pull request) → **rebut** (triage the AI review). The issue body is the source of truth the whole way through; each skill hands the next a concrete artifact, not a chat scrollback.

## Extending safely

### Stay stack-agnostic

The skills run in *other people's* repositories. Name only the universal substrate concretely: Git, GitHub, `gh`, and the issue → branch → gates → pull request → green CI spine. Keep review bots, CI systems, and issue trackers generic and discovered at runtime: describe the role, not the brand. A concrete tool name appears only as a hedged example, written "such as …". Repo-local conventions, like this repo's no-prose-comments rule, must never leak into a skill body.

### Add or change a script

1. POSIX `bash`, `set -euo pipefail`, `gh --jq` only.
2. Document the exit-code contract in the header. That is the interface.
3. `chmod +x` it.
4. Reference it from the `SKILL.md` as `"${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh"` and branch on its exit codes.
5. Change a code's meaning and you update every calling `SKILL.md` in the same change.
6. Run `validate:skills`. It fails if a referenced script is missing or not executable.

### Add or change a skill

- `name` equals the directory; `description` is triggers only.
- Put helper prose and templates under `references/`, and reference them so they aren't flagged as dead weight.
- Prefer sharpening an existing skill to adding a new one, so the set stays small and composable. Fold lessons from real use back into the skill in the same change that exposed them.

### The gates that guard you

These are `pnpm` scripts. Run them as `pnpm validate:skills`, and so on:

- `validate:markdown`: markdown is clean.
- `validate:comments`: no prose code comments (repo-local).
- `validate:versions`: each `plugin.json` version matches its `package.json`. It runs `sync-plugin-version.sh`, then fails on any diff.
- `validate:skills`: the name, description, reference, and hook contracts above.
- `claude plugin validate .`: manifests and skill frontmatter.

Each plugin's `package.json` owns its version number; `scripts/sync-plugin-version.sh` propagates it into the manifest. Never hand-edit a manifest version. CONTRIBUTING owns the full commit → changeset → release flow; this list is only what the gates structurally enforce.
