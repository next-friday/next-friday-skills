---
"@next-friday/next-friday": patch
---

Guard shared trackers against autonomous artifact creation. `blueprint` and `implement` now assume the GitHub tracker is shared by parallel agents unless the user says otherwise: they require an explicit per-artifact confirmation before creating or claiming any issue, branch, or PR; refuse to infer an issue target from a bare `/implement` or topic resemblance; and never touch an artifact the session did not create. The `SessionStart` hook is reworded to be advisory and subordinate to the user's instructions, CLAUDE.md, and saved feedback rather than unconditionally pushing issue/PR creation.
