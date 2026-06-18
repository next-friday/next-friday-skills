---
"@next-friday/next-friday": minor
---

feat(skills): add shared script library and wire rebut

Introduce a portable shell-script library at `plugins/next-friday/scripts/` (bash + git + gh only, gh's built-in `--jq`, graceful degradation) with `preflight.sh` (gh-auth + GitHub-remote gate), `gather-review.sh` (paginated reviews + inline comments so findings are never fabricated or dropped), and `ci-status.sh` (deterministic green / failing / none classification). The `rebut` skill now invokes these at Preflight, Step 1, and Step 5.5 instead of inlining the commands. `validate-skills.sh` now asserts every `SKILL.md` `${CLAUDE_PLUGIN_ROOT}/scripts/*.sh` reference resolves to an executable script. First slice of the cross-skill scripting initiative.
