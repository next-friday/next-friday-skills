#!/usr/bin/env bash
# pr-template.sh — locate and print the repo's pull-request template so the
# implement skill fills the real sections instead of inventing its own. Prints
# the template to stdout and its path to stderr. Exit 3 when the repo has no
# template, so the caller knows to fall back to a Summary / Changes / How to
# verify body. Pure find + cat; no parser, fully portable.
set -euo pipefail

# GitHub resolves the PR template from these locations; first match wins.
for f in \
  ".github/PULL_REQUEST_TEMPLATE.md" \
  ".github/pull_request_template.md" \
  "PULL_REQUEST_TEMPLATE.md" \
  "pull_request_template.md" \
  "docs/PULL_REQUEST_TEMPLATE.md" \
  "docs/pull_request_template.md"; do
  if [ -f "$f" ]; then
    echo "pr-template: using $f" >&2
    cat "$f"
    exit 0
  fi
done

# A PULL_REQUEST_TEMPLATE/ directory holds several named templates; list them
# rather than guess which one applies.
for d in ".github/PULL_REQUEST_TEMPLATE" "PULL_REQUEST_TEMPLATE" "docs/PULL_REQUEST_TEMPLATE"; do
  if [ -d "$d" ]; then
    echo "pr-template: multiple templates under $d — pick the one that fits:" >&2
    ls "$d"/*.md 2>/dev/null || true
    exit 0
  fi
done

echo "pr-template: no PR template found — fall back to Summary / Changes / How to verify, plus 'Closes #<n>'." >&2
exit 3
