#!/usr/bin/env bash
set -euo pipefail

title="${1:-${ISSUE_TITLE:-}}"

if [[ -z "$title" ]]; then
  echo "::error::Usage: $0 <issue-title>" >&2
  exit 2
fi

allowed_types='build|chore|ci|docs|feat|fix|perf|refactor|revert|setup|style|test'
pattern="^(${allowed_types})\\([a-z0-9][a-z0-9_/-]*\\): [a-z].{4,119}$"

if ! [[ "$title" =~ $pattern ]]; then
  echo "::error::Issue title does not follow the Hybrid Convention." >&2
  echo "::error::Expected: <type>(<scope>): <lowercase description>" >&2
  echo "::error::Allowed types: ${allowed_types//\|/, }" >&2
  echo "::error::Got: $title" >&2
  exit 1
fi

if [[ "$title" == *"+"* ]]; then
  echo "::error::Issue title uses '+' shorthand; write 'and' or commas." >&2
  exit 1
fi

echo "Issue title OK: $title"
