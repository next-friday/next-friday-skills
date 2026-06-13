#!/usr/bin/env bash
set -euo pipefail

title="${PR_TITLE:-}"
body="${PR_BODY:-}"

if [[ -z "$title" ]]; then
  echo "::error::PR_TITLE is empty" >&2
  exit 2
fi

if [[ "$title" =~ \#[0-9]+ ]]; then
  echo "::error::PR title must not reference an issue number; GitHub appends (#PR) on squash merge." >&2
  echo "::error::Got: $title" >&2
  exit 1
fi

if ! grep -qiE '(close|closes|closed|fix|fixes|fixed|resolve|resolves|resolved) #[0-9]+' <<<"$body"; then
  echo "::error::PR body must close at least one issue (one 'Closes #N' per line)." >&2
  exit 1
fi

echo "PR title and references OK"
