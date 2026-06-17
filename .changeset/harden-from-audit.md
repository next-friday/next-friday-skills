---
"@next-friday/next-friday": minor
---

Harden the workflow skills and their tooling from a full retrospective and audit.

- `blueprint` defines the unit of work as one logical change — code, tests, docs, and config in a single PR — with an explicit batch-vs-split rule, and tells sub-issues to branch independently off the default branch rather than stack under squash-merge.
- `implement` works independent tasks in dependency order without fanning one branch out to parallel subagents, hands off to `rebut` for the AI-review round instead of duplicating its triage, runs a language-appropriate loadability check on any changed file the repo's gates do not cover before committing, and reconfirms before outward writes when the session was scoped local-first.
- `rebut` attributes replies consistently and triggers right after a push where a reviewer is expected.
- `validate-skills.sh` gains portable, exact-token sibling and quote handling and no longer fails open on unrecognized hook commands; the unused `drill-skill.sh` is removed and `label-issue-by-type.sh` reads its type list from `.commitlintrc.json`.
