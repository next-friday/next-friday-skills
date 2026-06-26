---
"@next-friday/next-friday": patch
---

Fix five defects found auditing the skills and their scripts. The rebut Step 6 summary command used an undefined `$OWNER_REPO` and now uses gh's native `repos/{owner}/{repo}` placeholders, so the closure comment posts instead of 404ing. `verify-coverage.sh` no longer crashes on a review comment whose author account was deleted (`.user.login` is null-guarded before `endswith`). `ci-status.sh` only reports `ci: none` when there are genuinely no check rows, instead of when any check's description merely contains the words "no checks." `preflight.sh` anchors its GitHub-remote match so a host like `mygithub.com` no longer passes. And an implement example that wrote `gh issue develop --list` without the required issue number now matches the canonical `gh issue develop <n> --list`.
