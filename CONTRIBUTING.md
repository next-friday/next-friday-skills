# Contributing

Thanks for your interest in contributing! This repo runs on its own workflow — the same one the plugin enforces.

## Workflow

1. **Open an issue first.** Every change starts as a GitHub issue — title follows the Hybrid Convention: `<type>(<scope>): <lowercase description>` (types: build, chore, ci, docs, feat, fix, perf, refactor, revert, setup, style, test).
2. **Get the design agreed** on the issue before writing anything. Revisions are append-only comments.
3. **Branch from the issue**: `gh issue develop <n> --checkout`. Never commit to `main`.
4. **Commit conventionally.** commitlint runs on every commit via husky: scope required, lowercase, subject ≤50 chars.
5. **Add a changeset** for behavior changes: `pnpm changeset`.
6. **Open a PR** with `Closes #<n>` in the body (never in the title). Squash merge only; one approving review required.

## Local development

```sh
pnpm install
claude --plugin-dir ./plugins/next-friday
```

Skill edits (`SKILL.md`) reload live in the session; run `/reload-plugins` for manifest changes.

## Releasing

Releases are human-triggered — no bot opens a version PR. When the accumulated changesets are ready to ship:

1. Open a release issue and branch from it (same flow as any change).
2. Run the release bump locally:

   ```sh
   pnpm release
   ```

   This applies the pending changesets: bumps `plugins/*/package.json`, generates each `CHANGELOG.md`, and syncs the version into `plugin.json`.

3. Commit the result, open a PR, let CI pass, and merge it. **Merging the version bump to `main` is the release.**
4. On merge, the `tag.yml` workflow detects the version change and creates the matching `v<version>` git tag and GitHub Release automatically.

There is no npm publish — the plugin is distributed through the Claude marketplace, and the tagged commit is the artifact.

## Code style

- **No prose code comments.** Intent lives in names, commit messages, PR descriptions, and the docs — not in inline comments that rot as the code changes. Enforced by `pnpm validate:comments` in CI.
- Allowed (not prose comments): shebangs (`#!`), YAML/JSON keys, license headers, and machine-meaningful directives (e.g. a lint-disable pragma).
- This is a repo-local convention. It is intentionally not baked into the `blueprint`/`implement` skills, which run in third-party repos and must match each target repo's own comment density.

## Skill conventions

- All artifacts are English: skill content, issues, commits, PRs.
- Skill frontmatter: `name` matches the directory; `description` states triggering conditions only — never the workflow itself.
- Versions are owned by each plugin's `package.json`; `scripts/sync-plugin-version.sh` propagates them to `plugins/<name>/.claude-plugin/plugin.json`. Never edit a manifest version by hand.
- We keep the skill set small and composable — fixes and sharpening beat new skills. Lessons from real usage get folded back into the skills in the same change that exposed them.

## Code of conduct

This project follows the [Code of Conduct](./CODE_OF_CONDUCT.md). By participating, you agree to uphold it.
