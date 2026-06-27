#!/usr/bin/env bash
# verify-coverage.sh <pr>: re-query a pull request after triage and assert that
# every inline finding, from any reviewer (bot or human), received a reply from
# the triage account, so a silently dropped reply can never pass as "all threads
# answered". Prints one row per finding (answered / MISSING) then a final
# "answered N / M" line. Exit codes:
#   0  every finding has a reply (N == M, including M == 0)
#   1  at least one finding is unanswered
#   2  bad argument, or the repo/account could not be resolved
# A finding is any top-level inline comment (no in_reply_to_id) from any reviewer
# except the triage account's own comments (the replier cannot be a findee); a
# reply is a comment whose in_reply_to_id points at a finding and whose author IS
# the triage account. Uses gh's built-in --jq, no system jq required.
set -euo pipefail

pr="${1:-}"
if ! [[ "$pr" =~ ^[0-9]+$ ]]; then
  echo "verify-coverage: usage: verify-coverage.sh <pr-number>" >&2
  exit 2
fi

owner_repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) || true
# Triage identity: under a GitHub App token `gh api user` (a user-to-server
# endpoint) returns 403, so accept the app's `slug[bot]` login via
# REBUT_TRIAGE_LOGIN and fall back to the authenticated user only for a
# personal token.
me="${REBUT_TRIAGE_LOGIN:-}"
if [ -z "$me" ]; then
  me=$(gh api user --jq .login 2>/dev/null) || true
fi
if [ -z "$owner_repo" ] || [ -z "$me" ]; then
  echo "verify-coverage: cannot resolve the GitHub repo or the triage account; set REBUT_TRIAGE_LOGIN (e.g. the app's slug[bot]) under an App token, or run preflight for a personal token." >&2
  exit 2
fi

findings=$(gh api --paginate "repos/$owner_repo/pulls/$pr/comments" \
  --jq '.[] | select(.in_reply_to_id == null and (.user.login // "") != "'"$me"'") | "\(.id)\t\(.path):\(.line // "")\t\(.user.login)"')

replied=$(gh api --paginate "repos/$owner_repo/pulls/$pr/comments" \
  --jq '.[] | select(.in_reply_to_id != null and .user.login == "'"$me"'") | .in_reply_to_id')

total=0
answered=0
missing=0
while IFS=$'\t' read -r id loc login; do
  [ -n "$id" ] || continue
  total=$((total + 1))
  if printf '%s\n' "$replied" | grep -qx "$id"; then
    echo "answered  $loc ($login) id=$id"
    answered=$((answered + 1))
  else
    echo "MISSING   $loc ($login) id=$id"
    missing=$((missing + 1))
  fi
done <<EOF
$findings
EOF

echo "answered $answered / $total"
[ "$missing" -eq 0 ] || exit 1
