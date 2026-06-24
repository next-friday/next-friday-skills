#!/usr/bin/env bash
# post-reply.sh <pr> <comment-id> <body-file>: post ONE threaded reply to an
# inline review comment, paced under GitHub's secondary rate limit, and confirm
# it persisted by reading the created reply's id back from the API response
# rather than trusting a shell exit code. Prints the created reply id on stdout.
# Retries with backoff when a post is throttled or errors. Exit codes:
#   0  posted; the created reply id is on stdout
#   1  every attempt failed (the reply was NOT posted)
#   2  bad arguments, or the repo could not be resolved
# Pacing is deliberate: replies posted back-to-back trip the secondary limit and
# vanish silently, the exact failure this guards against. Override the pace and
# attempt count with REBUT_POST_PACE_SECONDS and REBUT_POST_ATTEMPTS.
set -euo pipefail

pr="${1:-}"
comment_id="${2:-}"
body_file="${3:-}"
if ! [[ "$pr" =~ ^[0-9]+$ ]] || ! [[ "$comment_id" =~ ^[0-9]+$ ]] || [ -z "$body_file" ]; then
  echo "post-reply: usage: post-reply.sh <pr-number> <comment-id> <body-file>" >&2
  exit 2
fi
if [ ! -f "$body_file" ]; then
  echo "post-reply: body file not found: $body_file" >&2
  exit 2
fi

owner_repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) || true
if [ -z "$owner_repo" ]; then
  echo "post-reply: cannot resolve the GitHub repo; run preflight first (is gh authenticated, with a github remote?)." >&2
  exit 2
fi

# ponytail: fixed pace + doubling backoff; tune via env if a repo trips a stricter limit.
pace="${REBUT_POST_PACE_SECONDS:-3}"
attempts="${REBUT_POST_ATTEMPTS:-5}"

reply_id=""
delay="$pace"
for ((attempt = 1; attempt <= attempts; attempt++)); do
  sleep "$delay"
  set +e
  out=$(gh api "repos/$owner_repo/pulls/$pr/comments/$comment_id/replies" -F body=@"$body_file" --jq .id 2>&1)
  code=$?
  set -e
  if [ "$code" -eq 0 ] && [[ "$out" =~ ^[0-9]+$ ]]; then
    reply_id="$out"
    break
  fi
  echo "post-reply: attempt $attempt/$attempts to reply to comment $comment_id failed (gh exited $code): $out" >&2
  delay=$((delay * 2))
done

if [ -z "$reply_id" ]; then
  echo "post-reply: gave up after $attempts attempts; reply to comment $comment_id was NOT posted." >&2
  exit 1
fi

echo "$reply_id"
