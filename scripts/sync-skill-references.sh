#!/usr/bin/env bash
set -euo pipefail

[ -d plugins ] || exit 0

status=0

for skill in plugins/*/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  skilldir=$(dirname "$skill")
  pluginroot=$(dirname "$(dirname "$skilldir")")
  canonical="$pluginroot/references"
  target="$skilldir/references"

  refs=$(grep -oE '\$\{CLAUDE_SKILL_DIR\}/references/[A-Za-z0-9._-]+\.md' "$skill" 2>/dev/null \
    | sed 's#.*/##' | sort -u || true)

  [ -n "$refs" ] || continue

  mkdir -p "$target"
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    src="$canonical/$name"
    if [ ! -f "$src" ]; then
      echo "sync-skill-references: $skill references $name but $src is missing" >&2
      status=1
      continue
    fi
    cp "$src" "$target/$name"
  done <<EOF
$refs
EOF
done

exit "$status"
