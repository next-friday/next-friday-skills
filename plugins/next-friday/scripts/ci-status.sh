#!/usr/bin/env bash
# ci-status.sh <pr> — probe a pull request's checks and classify them
# deterministically, so "no checks configured" is never mistaken for a failure.
# Prints the rows, then a final status line. Exit codes:
#   0  ci: green    — every check concluded successfully
#   0  ci: pending  — checks still running (caller should `gh pr checks <pr> --watch`, then re-probe)
#   1  ci: failing  — at least one check failed
#   3  ci: none     — the PR has no checks configured (not a failure)
#   2               — bad argument
# Classification reads the state column, not gh's exit code, which varies by
# gh version. A failing check outranks a pending one.
set -euo pipefail

pr="${1:-}"
if ! [[ "$pr" =~ ^[0-9]+$ ]]; then
  echo "ci-status: usage: ci-status.sh <pr-number>" >&2
  exit 2
fi

# gh pr checks exits non-zero when a check fails AND when none exist; capture
# the output regardless and decide from its content.
output=$(gh pr checks "$pr" 2>/dev/null) || true

if [ -z "$output" ]; then
  echo "ci: none"
  exit 3
fi

echo "$output"

states=$(printf '%s\n' "$output" | awk -F'\t' 'NF { print $2 }')

if printf '%s\n' "$states" | grep -qiE '^(fail|failing|failure|error|cancelled|canceled|timed_out)$'; then
  echo "ci: failing"
  exit 1
fi

if printf '%s\n' "$states" | grep -qiE '^(pending|in_progress|queued|waiting|requested)$'; then
  echo "ci: pending"
  exit 0
fi

echo "ci: green"
exit 0
