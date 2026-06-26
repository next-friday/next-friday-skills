#!/usr/bin/env bash
# ci-status.sh <pr>: probe a pull request's checks and classify them
# deterministically, so "no checks configured" is never mistaken for a failure.
# Prints the rows, then a final status line. Exit codes:
#   0  ci: green    every check concluded successfully
#   1  ci: failing  at least one check failed
#   2               bad argument, or checks could not be read (e.g. a transient
#                     gh/network/auth failure, distinct from "no checks")
#   3  ci: none     the PR has no checks configured (not a failure)
#   4  ci: pending  checks still running; caller should `gh pr checks <pr> --watch`, then re-probe
# Classification reads the state column, not gh's exit code, which varies by
# gh version. A failing check outranks a pending one. A read failure is never
# silently treated as "no checks".
set -euo pipefail

pr="${1:-}"
if ! [[ "$pr" =~ ^[0-9]+$ ]]; then
  echo "ci-status: usage: ci-status.sh <pr-number>" >&2
  exit 2
fi

# gh pr checks exits non-zero both when a check fails and when none exist, so the
# exit code alone cannot tell "no checks" from a transient gh/network/auth error.
# Capture stdout+stderr and the code, then decide from the content.
set +e
combined=$(gh pr checks "$pr" 2>&1)
code=$?
set -e

rows=$(printf '%s\n' "$combined" | awk -F'\t' 'NF >= 2 { print }')
if [ -z "$rows" ]; then
  # No data rows: distinguish gh's "no checks" message from a transient read error.
  if printf '%s\n' "$combined" | grep -qiE 'no checks reported|no checks on'; then
    echo "ci: none"
    exit 3
  fi
  echo "ci-status: could not read checks for PR $pr (gh exited $code):" >&2
  printf '%s\n' "$combined" >&2
  exit 2
fi

echo "$rows"
states=$(printf '%s\n' "$rows" | awk -F'\t' '{ print $2 }')

if printf '%s\n' "$states" | grep -qiE '^(fail|failing|failure|error|cancelled|canceled|timed_out)$'; then
  echo "ci: failing"
  exit 1
fi

if printf '%s\n' "$states" | grep -qiE '^(pending|in_progress|queued|waiting|requested)$'; then
  echo "ci: pending"
  exit 4
fi

echo "ci: green"
exit 0
