---
"@next-friday/next-friday": patch
---

Stop `rebut` from silently dropping review replies. The skill posted replies in a tight loop and trusted each post command's own success line, so GitHub's secondary rate limit could drop most replies while the run still reported "all threads answered". Two new scripts back the reply step: `post-reply.sh` paces each post and confirms it persisted by reading the created reply id back from the API response (retrying with backoff when throttled), and `verify-coverage.sh` re-queries the PR after triage to assert every bot finding got a reply from the triage account, printing `answered N / M` and failing when any finding is unanswered. A new HARD-GATE forbids claiming the round is done from post output alone, and the async guidance now makes the continuous-triage automation the recommended default for any PR that draws more than one reviewer.
