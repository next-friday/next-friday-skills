# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Claude Code plugin marketplace (`skills`). Plugins live in `plugins/*`; each contains `.claude-plugin/plugin.json` and `skills/<name>/SKILL.md`. The root `.claude-plugin/marketplace.json` lists every plugin. Content is markdown — there is no build step and no test runner; the `validate:*` scripts plus `claude plugin validate .` are the only checks.

The sole plugin is `next-friday`, three skills: **`blueprint`** turns an idea into an agreed GitHub issue whose body holds the design and the implementation plan — the issue is the single source of truth (no committed spec/plan files); **`implement`** takes that approved issue and ships it as a PR with green CI; **`rebut`** triages the AI code-review comments on that PR — verify each finding, then fix it or refute it with evidence. Keep the set small and composable — sharpen what exists before adding more.

## Workflow

Follow [CONTRIBUTING.md](./CONTRIBUTING.md) exactly — it is the single source for the contribution workflow, commit/title conventions, and skill conventions. Non-negotiable for agents:

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
claude plugin validate .
claude --plugin-dir ./plugins/next-friday
```

`pnpm install` sets up devDependencies and the husky git hooks. `pnpm changeset` records a version bump and changelog entry; `pnpm release` applies the pending changesets and syncs each `plugin.json`. The four `validate:*` / `claude plugin validate .` commands are the CI gates — run all of them before committing (CONTRIBUTING.md Step 3 lists them as the pre-commit set). `claude --plugin-dir ./plugins/next-friday` loads the plugin in a local session; `SKILL.md` edits reload instantly, manifest edits need `/reload-plugins`.

Two gotchas not obvious from the file tree:

- **Never hand-edit a `plugin.json` version.** `plugins/<name>/package.json` owns the version; `scripts/sync-plugin-version.sh` propagates it. `validate:versions` fails CI if they drift.
- **No prose code comments in this repo** (`validate:comments` enforces it) — but this is a repo-local rule. Do NOT bake it into the `blueprint`/`implement`/`rebut` skills: they run in third-party repos and must match each target repo's own comment density.
