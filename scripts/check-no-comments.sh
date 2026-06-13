#!/usr/bin/env bash
set -euo pipefail

status=0

scan() {
  local label="$1" pattern="$2"
  shift 2
  local hits
  hits=$(grep -rnE "$pattern" "$@" 2>/dev/null | grep -vE '^[^:]+:[0-9]+:[[:space:]]*#!' || true)
  if [ -n "$hits" ]; then
    echo "::error::Prose comments are not allowed ($label). Intent belongs in names, commits, PRs, and docs:" >&2
    echo "$hits" >&2
    status=1
  fi
}

scan "yaml" '^[[:space:]]*#([^!]|$)' .github/workflows
scan "shell" '^[[:space:]]*#([^!]|$)' .github/scripts scripts
scan "js" '^[[:space:]]*(//|/\*|\*[^/])' scripts

if [ "$status" -eq 0 ]; then
  echo "No prose comments found."
fi
exit "$status"
