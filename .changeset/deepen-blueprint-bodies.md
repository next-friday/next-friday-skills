---
"@next-friday/next-friday": minor
---

feat(blueprint): deepen issue bodies into precise specs

Blueprint now records a depth set (decision log, file map + reuse callout, verification, out-of-scope) for Standard/Large issues, with conditional contracts, global constraints, and prior-art added only when they carry content — never as empty headings. The handoff replaces the absolute "code in the PR" rule with a code-sketch policy (sketch only to pin ordering, an exact shape, a hard algorithm, or a public-API surface) and adds per-task Consumes/Produces contracts, a Verification line, and task right-sizing. A two-layer body-versioning rule (GitHub native edit history plus an in-body version banner) lets readers return to an earlier design. Trivial-tier behavior is unchanged.
