# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Claude Code plugin marketplace (`skills`). Plugins live in `plugins/*`; each contains `.claude-plugin/plugin.json` and `skills/<name>/SKILL.md`. The root `.claude-plugin/marketplace.json` lists every plugin. Content is markdown — there is no build step.

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
claude --plugin-dir ./plugins/next-friday
```

`pnpm install` sets up devDependencies and the husky git hooks. `pnpm changeset` records a version bump and changelog entry; `pnpm release` applies the pending changesets and syncs each `plugin.json`. The `validate:*` scripts are the CI gates (manifests and skill frontmatter are checked by `claude plugin validate` in the `Validate / plugins` job). `claude --plugin-dir ./plugins/next-friday` loads the plugin in a local session.
