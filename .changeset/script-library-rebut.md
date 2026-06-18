---
"@next-friday/next-friday": minor
---

feat(skills): add shared script library and wire rebut

Introduce a portable shell-script library at `plugins/next-friday/scripts/` (bash + git + gh only, gh's built-in `--jq`, graceful degradation) with `preflight.sh` (gh-auth + GitHub-remote gate), `gather-review.sh` (paginated reviews + inline comments so findings are never fabricated or dropped), and `ci-status.sh` (deterministic green / failing / none classification). The `rebut` skill now invokes these at Preflight, Step 1, and Step 5.5 instead of inlining the commands. `validate-skills.sh` now asserts every `SKILL.md` `${CLAUDE_PLUGIN_ROOT}/scripts/*.sh` reference resolves to an executable script.

Also hardens `rebut` triage coverage — a lesson surfaced while triaging this PR: no gathered finding is left without a reply (silence reads as un-triaged and makes a human re-invoke the skill, looping), and Step 6 now posts a triage-summary comment on the PR conversation that closes the review summaries and gives a human visible proof the round was handled.

Adds `pr-template.sh` (locate and print the repo's PR template) and wires all three skills to the library: `blueprint` and `implement` call `preflight.sh`, `implement` also calls `pr-template.sh` and `ci-status.sh`, and `rebut` uses all three. `title-lint.sh` and `issue-template.sh` were deliberately dropped — they parse local commitlint/YAML config that needs a non-portable `jq`/`yq`, and the model reads such config more robustly than a bash grep-hack would, so scripting them adds fragility, not anti-hallucination value.
