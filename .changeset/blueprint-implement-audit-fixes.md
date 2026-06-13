---
"@next-friday/next-friday": minor
---

Harden the blueprint and implement skills from a real end-to-end run and an expert audit, for safer worldwide use.

Blueprint:

- Rewrite the description to triggers-only so the skill body is read instead of a workflow summary being followed.
- Add a convergence gate: never create or comment a GitHub artifact until the design is approved in chat (stops early-recording churn).
- Add a "root context first" interview step (end goal, prior art, repo nature) before any tooling question.
- Require self-contained artifacts — never reference another repository inside an issue, spec, or PR.
- Relax one-question-per-message to batching tightly-coupled questions.
- Generalize org-specific assumptions (title convention discovery, the ~400-line figure as a heuristic).

Implement:

- Rewrite the description to triggers-only.
- Stop and hand off (never retry, force, or reroute) when a push or PR is blocked by a guard hook or policy.
- Treat protected/owner-owned files as deferrals documented in the PR, not writes to retry.
- Make gate discovery monorepo-aware: run gates in the package that owns the changed files and confirm they exercised the change.
- Document an opt-in, permission-preserving way to reduce prompts; the skill never weakens permissions or bypasses guards.

Both skills add `license` and `compatibility` frontmatter for spec compliance.
