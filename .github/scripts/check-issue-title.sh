#!/usr/bin/env bash
set -euo pipefail

title="${1:-${ISSUE_TITLE:-}}"

if [[ -z "$title" ]]; then
  echo "::error::Usage: $0 <issue-title>" >&2
  exit 2
fi

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
allowed_types=$(jq -r '.rules["type-enum"][2] | join("|")' "$root/.commitlintrc.json")
if [[ -z "$allowed_types" ]]; then
  echo "::error::Could not read type-enum from .commitlintrc.json" >&2
  exit 2
fi
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
