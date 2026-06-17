---
"@next-friday/next-friday": minor
---

Make the skills global-ready: generic at the tool layer, human-aware, beginner-friendly, and honest about continuous triage.

- Keep the universal Git/GitHub/CI substrate concrete but describe specific review and CI tools generically, named only as hedged examples, per the "discovered, not assumed" promise.
- `rebut` now handles human reviewers, not only bots: the verification core applies to any reviewer, but for a human it collaborates instead of refuting and drafts replies rather than auto-posting.
- `rebut` states plainly that a skill cannot watch a PR over time and points to `docs/continuous-triage.md`, an opt-in GitHub Action template that re-invokes triage on each review round until the PR closes.
- README gains a plain-language "What this does for you" for newcomers; the agent-facing `SKILL.md` files stay precise.
