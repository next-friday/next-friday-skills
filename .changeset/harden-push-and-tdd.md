---
"@next-friday/next-friday": patch
---

Close two robustness gaps in the implement and rebut skills found while dogfooding the flow. A push rejected as non-fast-forward — because the remote branch was advanced by a teammate, a release bot's version bump, or a PR "Update branch" merge — now has explicit recovery guidance (`git fetch` then `git rebase` onto the updated tip, then push again, never `--force`), kept distinct from a policy-blocked push, which still stops. And the implement skill's test-first mandate now carves out a change with no executable behavior, such as a documentation or prose edit, which has no failing test to write and is verified through the lint or structural gate instead.
