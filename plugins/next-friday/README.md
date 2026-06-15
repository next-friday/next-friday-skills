# Next Friday

Issue-driven development workflow for Claude Code. Two skills that chain into one pipeline:

```text
blueprint ──→ approved issue + plan ──→ implement ──→ PR, green CI
```

| Skill       | When                                                                                                                                        |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `blueprint` | Design interview → approved design recorded in the GitHub issue body (design + implementation plan).                                        |
| `implement` | The issue is approved — branch from it, code task by task, pass all gates, open PR, watch CI to green.                                      |

The process scales to the change: trivial work (typo, dependency bump) takes a 2-4 sentence design and one approval; it never skips the issue, the approval, or the PR.

## Requirements

- `gh` CLI, authenticated (`gh auth status`)
- A GitHub-hosted repo. Repo-local `.github/` issue/PR templates and enforced title conventions are discovered and used automatically when present, with graceful fallbacks when they are not.

## Install

```text
/plugin marketplace add next-friday/next-friday-skills
/plugin install next-friday@skills
```

See the [repository README](../../README.md#installation) for full details.

## Local development

From the repository root:

```sh
claude --plugin-dir ./plugins/next-friday
```

Edits to `skills/*/SKILL.md` reload live; run `/reload-plugins` for anything else.
