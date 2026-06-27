---
"@next-friday/next-friday": minor
---

rebut now auto-posts triage replies to human reviewer and contributor threads, not only bot threads. Every reviewer flows through the same pipeline (verify against the current code, fix or push back with evidence, reply in-thread under the attribution line, then prove coverage), differing only in tone: a human gets a non-curt, technically-reasoned reply instead of a blunt refutation. The "draft and hand to the maintainer" carve-out for humans is removed; the attribution line is what makes auto-posting to a human thread safe. `verify-coverage.sh` now counts every top-level inline finding regardless of author (excluding only the triage account's own comments), so a dropped reply to a human thread keeps the round open just as a dropped bot reply does.
