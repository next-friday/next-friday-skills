#!/usr/bin/env bash
set -euo pipefail

skill=${1:-}
shift || true
prompt=${*:-}

if [ -z "$skill" ] || [ -z "$prompt" ]; then
  echo "usage: drill-skill.sh <skill-name> <prompt>" >&2
  exit 2
fi

if ! command -v claude >/dev/null 2>&1; then
  echo "claude CLI not found, skipping the trigger drill." >&2
  exit 0
fi

out=$(claude -p "$prompt" --output-format json 2>/dev/null || true)

if printf '%s' "$out" | grep -qE '"name"[[:space:]]*:[[:space:]]*"Skill"' \
  && printf '%s' "$out" | grep -qF "$skill"; then
  echo "PASS: '$skill' triggered for: $prompt"
else
  echo "FAIL: '$skill' did not trigger for: $prompt" >&2
  exit 1
fi
