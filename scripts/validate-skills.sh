#!/usr/bin/env bash
set -euo pipefail

status=0

fail() {
  echo "::error::$1" >&2
  status=1
}

for skill in plugins/*/skills/*/SKILL.md; do
  [ -f "$skill" ] || continue
  dir=$(dirname "$skill")
  base=$(basename "$dir")

  name=$(sed -n 's/^[[:space:]]*name:[[:space:]]*//p' "$skill" | head -1 | tr -d '"' | tr -d "'")
  if [ "$name" != "$base" ]; then
    fail "$skill: name '$name' does not match directory '$base'"
  fi

  desc=$(sed -n 's/^[[:space:]]*description:[[:space:]]*//p' "$skill" | head -1)
  case "$desc" in
    ">" | "|" | ">-" | "|-" | ">+" | "|+")
      fail "$skill: description uses a YAML block scalar; use a single-line quoted description"
      continue
      ;;
  esac
  if [ "${#desc}" -ge 2 ]; then
    first=${desc:0:1}
    last=${desc: -1}
    if [ "$first" = '"' ] && [ "$last" = '"' ]; then
      desc=${desc#\"}
      desc=${desc%\"}
    elif [ "$first" = "'" ] && [ "$last" = "'" ]; then
      desc=${desc#\'}
      desc=${desc%\'}
    fi
  fi
  if [ -z "$desc" ]; then
    fail "$skill: missing description"
  else
    if [ "${#desc}" -gt 1024 ]; then
      fail "$skill: description is ${#desc} chars, over the 1024 limit"
    fi
    if [ "${desc#Use }" = "$desc" ]; then
      fail "$skill: description must state triggers only and begin with 'Use ' such as 'Use when ...'"
    fi
  fi

  while IFS= read -r ref; do
    [ -n "$ref" ] || continue
    if [ ! -f "$dir/$ref" ]; then
      fail "$skill: references '$ref' but it is missing from $dir"
    fi
  done < <(grep -oE '[A-Za-z0-9._-]+-prompt\.md' "$skill" | sort -u || true)

  refs=$(grep -oE '[A-Za-z0-9._-]+\.md' "$skill" | sort -u || true)
  for sibling in "$dir"/*.md; do
    [ -f "$sibling" ] || continue
    sname=$(basename "$sibling")
    [ "$sname" = "SKILL.md" ] && continue
    printf '%s\n' "$refs" | grep -qxF "$sname" || fail "$skill: sibling '$sname' is never referenced, so it is dead weight"
  done
done

for manifest in plugins/*/hooks/hooks.json; do
  [ -f "$manifest" ] || continue
  root=$(dirname "$(dirname "$manifest")")
  while IFS= read -r cmd; do
    [ -n "$cmd" ] || continue
    if [ "${cmd#*'${CLAUDE_PLUGIN_ROOT}/'}" = "$cmd" ]; then
      fail "$manifest: hook command references no \${CLAUDE_PLUGIN_ROOT} path, cannot verify: $cmd"
      continue
    fi
    rel=${cmd#*CLAUDE_PLUGIN_ROOT\}/}
    rel=${rel%%\"*}
    rel=${rel%% *}
    if [ ! -x "$root/$rel" ]; then
      fail "$manifest: hook command '$rel' is missing or not executable under $root"
    fi
  done < <(jq -r '.hooks // {} | to_entries[] | .value[]?.hooks[]?.command // empty' "$manifest")
done

if [ "$status" -eq 0 ]; then
  echo "Skills valid."
fi
exit "$status"
