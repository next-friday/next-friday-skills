# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Claude Code plugin marketplace (`skills`). Plugins live in `plugins/*`; each contains `.claude-plugin/plugin.json` and `skills/<name>/SKILL.md`. The root `.claude-plugin/marketplace.json` lists every plugin. Content is markdown. There is no build step and no test runner; the `validate:*` scripts plus `claude plugin validate .` are the only checks.

The sole plugin is `next-friday`, three skills. **`blueprint`** turns an idea into an agreed GitHub issue whose body holds the design and the implementation plan; the issue is the single source of truth, with no committed spec/plan files. **`implement`** takes that approved issue and ships it as a PR with green CI, then hands off to `rebut`. **`rebut`** triages the AI code-review comments on that PR: verify each finding, then fix it or refute it with evidence. Keep the set small and composable, and sharpen what exists before adding more.

## Workflow

Follow [CONTRIBUTING.md](./CONTRIBUTING.md) exactly. It is the single source for the contribution workflow, commit/title conventions, and skill conventions. Non-negotiable for agents:

- This repo dogfoods its own `next-friday` plugin: issue first, branch from the issue, PR closes it. Never commit to `main`.
- Lessons from real usage get folded back into the skills in the same change that exposed them.

## Commands

```sh
pnpm install
pnpm changeset
pnpm release
pnpm validate:versions
pnpm validate:markdown
pnpm validate:comments
pnpm validate:skills
claude plugin validate .
claude --plugin-dir ./plugins/next-friday
```

`pnpm install` sets up devDependencies and the husky git hooks. `pnpm changeset` records a version bump and changelog entry; `pnpm release` applies the pending changesets and syncs each `plugin.json`. The four `validate:*` commands plus `claude plugin validate .` are the CI gates; run all of them before committing, since CONTRIBUTING.md Step 3 lists them as the pre-commit set. `claude --plugin-dir ./plugins/next-friday` loads the plugin in a local session; `SKILL.md` edits reload instantly, manifest edits need `/reload-plugins`.

Five gotchas not obvious from the file tree:

- **Shared script library.** Deterministic `gh`/git steps live in `plugins/next-friday/scripts/*.sh` as `preflight`, `gather-review`, `ci-status`, and `pr-template`, not in skill prose. This is the anti-hallucination spine: the skill describes intent, the script does the exact work. The three skills invoke them as `"${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh"`. Exit codes are part of the contract (e.g. `ci-status` 0=green / 1=failing / 2=read-error / 3=none / 4=pending); change a code and the calling SKILL.md changes with it. The scripts stay POSIX-portable and use `gh --jq` (no system `jq`). `plugins/next-friday/skills/rebut/references/continuous-triage.md` covers the one thing they can't: a skill is a single agent invocation, so triaging *future* review rounds needs an external trigger such as a GitHub Action, not the skill itself. It lives inside the skill so it ships on install.
- **Never hand-edit a `plugin.json` version.** `plugins/<name>/package.json` owns the version; `scripts/sync-plugin-version.sh` propagates it. `validate:versions` fails CI if they drift.
- **No prose code comments in this repo**, which `validate:comments` enforces. This is a repo-local rule. Do NOT bake it into the `blueprint`/`implement`/`rebut` skills: they run in third-party repos and must match each target repo's own comment density.
- **SessionStart hook.** `plugins/<name>/hooks/hooks.json` wires a `SessionStart` hook that injects a short reminder of the issue-driven workflow so the skills are reached for, not skipped. `validate:skills` checks the referenced hook script exists and is executable.
- **Stack-agnostic skills.** Name the universal substrate concretely: Git, GitHub, `gh`, the issue → branch → gates → PR → green CI spine. Keep specific review, CI, or automation tools generic and discovered at runtime: describe the role, not the brand, so the "discovered, not assumed" promise holds. A concrete tool name belongs only as a hedged example, written "such as ...".
