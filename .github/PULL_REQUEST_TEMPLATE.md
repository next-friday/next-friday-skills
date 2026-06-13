# Pull Request

<!--
Conditional sections below carry the suffix "(when touched)". Remove any
conditional section that does not apply to this pull request rather than
filling it with placeholder text such as "N/A" or "none".

Conditional sections in this template:
- Skills (when touched)
- Manifests (when touched)
- Docs (when touched)
-->

## Title Format

`type(scope): subject` — validated by [`.commitlintrc.json`](../.commitlintrc.json) (scope required, lowercase, subject within the configured length limit).

- The title carries no `#N` reference. GitHub auto-appends `(#<this-PR>)` to the squash-merge commit subject; adding `(#N)` in the title produces a duplicate on `main`.
- Issue closures go in the body, one `Closes #N` per line.

Examples:

- `feat(next-friday): add release-notes skill`
- `fix(blueprint): handle repos without issue templates`
- `docs(repo): clarify installation steps`

---

Closes #

## Summary

Two or three bullets describing what changed and the rationale.

## Type of Change

- [ ] feat — new functionality
- [ ] fix — bug fix
- [ ] refactor — internal change with no behavioural change
- [ ] chore — tooling, dependencies, or configuration
- [ ] docs — documentation only
- [ ] setup — scaffolding or infrastructure wiring
- [ ] ci — CI/CD workflow change
- [ ] perf — performance improvement
- [ ] style — formatting (no meaning change)
- [ ] test — adding or correcting tests
- [ ] revert — reverts a previous commit

## Test Plan

Pre-merge verification. Tick each item once verified.

- [ ] Manifests are valid JSON with required fields (`.claude-plugin/marketplace.json`, `plugins/*/.claude-plugin/plugin.json`)
- [ ] Skill frontmatter is valid (`name` matches directory, `description` present)
- [ ] `bash scripts/sync-plugin-version.sh` leaves no diff (versions in sync)
- [ ] `claude --plugin-dir ./plugins/next-friday` loads the skills
- [ ] Changeset added (`pnpm changeset`) — or this change is docs/chore-only

## Skills (when touched)

- [ ] Frontmatter `description` states triggering conditions only — never the workflow itself
- [ ] Sibling cross-references still resolve (`blueprint` ↔ `implement`)
- [ ] Companion files referenced from the skill exist
- [ ] Shell examples use `--body-file` for multi-line bodies (inline `--body` breaks quoting)

## Manifests (when touched)

- [ ] Marketplace `source` paths resolve and entry `name` matches the plugin manifest
- [ ] Version edited only via changesets — never by hand in `plugin.json`

## Docs (when touched)

- [ ] README stays user-facing; contributor content lives in CONTRIBUTING.md
- [ ] Relative links resolve on disk
- [ ] Display text uses "Next Friday" (with space); machine identifiers unchanged
- [ ] No prose code comments added (intent in names, commits, PRs, docs)

## Risks

Identified risks, partial deliveries, or scenarios that may break under specific conditions.
