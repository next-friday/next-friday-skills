---
"@next-friday/next-friday": minor
---

blueprint now treats the GitHub issue body as the single source of truth: the design and the implementation plan live in the body and are rewritten as the design evolves, instead of accreting across append-only comments. The committed-file "Spec Document Mode" is removed, and implement reads the design and plan from the issue body.
