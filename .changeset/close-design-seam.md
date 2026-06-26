---
"@next-friday/next-friday": patch
---

Close the blueprint to implement seam. blueprint now defines a Trivial-tier plan as a single line — a Done criterion plus its Verification command — and implement accepts that one line as a valid plan instead of bouncing a Trivial change for lacking a task list or headers. implement's issue-number gate now accepts an issue this same session created via blueprint as an explicit hand-off, while still rejecting an inferred number (the highest, the most recent, or "the one we were discussing"), so the same-session design-to-build handoff no longer forces a re-type.
