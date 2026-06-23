---
"@next-friday/next-friday": patch
---

fix(skills): ship skill helper files so installs resolve them

`rebut` referenced `docs/continuous-triage.md`, which lived at the repository root, outside the packaged plugin, so every install resolved a dead link. The reviewer-subagent prompts that `blueprint` dispatches sat as loose files in the skill root. Move all of them under each skill's `references/` directory and repoint every reference. `validate-skills.sh` now resolves `references/<file>.md` paths so every referenced helper is gated at its real location, and its dead-weight scan covers `references/` so an unreferenced helper cannot ship unnoticed.
