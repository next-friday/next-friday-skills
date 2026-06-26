#!/usr/bin/env bash
# preflight.sh: verify the environment a next-friday skill needs before any
# outward action: gh installed + authenticated, inside a git repo with a GitHub
# remote. Prints "preflight: ok" and exits 0 on success; on any failure prints
# what is missing plus the fix on stderr and exits 1, so the skill can recover
# (tell the user) instead of guessing.
set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "preflight: gh not found; install the GitHub CLI, then run 'gh auth login'." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "preflight: gh is not authenticated; run 'gh auth login'." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1; then
  echo "preflight: git not found; install git." >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "preflight: not inside a git repository." >&2
  exit 1
fi

if ! git remote -v | grep -qE '[@/]github\.com[:/]'; then
  echo "preflight: no GitHub remote; these skills are GitHub-specific; add a github.com remote or track this work elsewhere." >&2
  exit 1
fi

echo "preflight: ok"
