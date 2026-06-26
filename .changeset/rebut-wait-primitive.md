---
"@next-friday/next-friday": patch
---

Give the rebut skill a runnable wait primitive. The "let the round settle" step said to "wait a bounded interval" without naming a command, and the obvious `sleep` is blocked in interactive Claude Code, so the wait was not reliably executable. It now names `gh pr checks <pr> --watch` — the same primitive Step 5.5 already uses — which blocks until the PR's checks finish, behaves the same interactively and headless, and covers the window asynchronous reviewers post in, with a brief-pause fallback when the PR has no checks.
