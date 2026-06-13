#!/usr/bin/env bash
set -euo pipefail

[ -d plugins ] || exit 0

for pkg in plugins/*/package.json; do
  [ -f "$pkg" ] || continue
  dir=$(dirname "$pkg")
  manifest="$dir/.claude-plugin/plugin.json"
  [ -f "$manifest" ] || continue
  version=$(jq -r '.version' "$pkg")
  current=$(jq -r '.version' "$manifest")
  if [ "$version" != "$current" ]; then
    tmp=$(mktemp)
    jq --arg v "$version" '.version = $v' "$manifest" >"$tmp"
    mv "$tmp" "$manifest"
    echo "synced $(basename "$dir"): plugin.json -> $version"
  fi
done
