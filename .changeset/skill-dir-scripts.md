---
"@next-friday/next-friday": patch
---

Ship each skill's helper scripts with the skill so they work under a standalone `skills` CLI install, not only a plugin install. The skills referenced their helpers as `${CLAUDE_PLUGIN_ROOT}/scripts/<name>.sh` from the plugin root; a standalone install copies only the skill's own directory and never sets `${CLAUDE_PLUGIN_ROOT}`, so every call broke. Helpers are now referenced via `${CLAUDE_SKILL_DIR}/scripts/<name>.sh` (resolves under both install paths) and each skill carries its own `scripts/` directory. The canonical scripts stay the single source at `plugins/next-friday/scripts/`; `scripts/sync-skill-scripts.sh` generates the per-skill copies and the new `validate:scripts` gate fails CI on drift.
