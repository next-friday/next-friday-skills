---
"@next-friday/next-friday": patch
---

Factor the rules and disciplines the skills share into canonical references, so they are stated once instead of copy-pasted and cannot drift. A new `sync-skill-references.sh` mirrors the script-sync pattern (additive: it refreshes shared copies, never touches a skill's own references) with a `validate:references` CI gate. `references/shared-tracker-safety.md` now holds the shared-tracker authorization rules that blueprint and implement both enforce; each skill keeps its own critical inline gate (implement its issue-number and claim checks, blueprint its convergence and premise gates) and points at the shared doc for the common rules. `references/verification.md` and `references/debugging.md` hold the verification and debugging disciplines that implement and rebut share; each skill references them by name and keeps only its own application layer. No authorization gate is removed or weakened.
