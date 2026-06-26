# Shared-tracker safety

The GitHub tracker — issues, pull requests, branches — is SHARED by parallel agents and people unless the user says otherwise; you are not its sole owner. These rules bind every outward write a skill makes to that tracker. Each skill states its own critical gate inline; this document is the canonical statement of the rules the skills share, so they cannot drift apart.

## Per-artifact authorization

Create or mutate no issue, PR, or branch, and post no comment, label, or assignment, without an explicit, per-artifact "yes" naming THAT artifact in this session. One "yes" authorizes one named artifact, never a batch: a fan-out such as an epic plus its sub-issues, or several PRs, needs a separate "yes" for each named member, listed first so the user sees the whole set. A design, draft, or plan approval is NOT a write authorization; content approval and write authorization are separate, and the second still has to be asked for.

## No foreign artifacts

Touch no issue, branch, or PR this session did not itself create, unless the user hands you its number. Same-account authorship is not ownership; a title or topic resemblance to the request is not authorization; never auto-match an artifact to the request by similarity. When unsure which artifact is meant, ask the user for the number rather than guessing. Before the first outward write on an artifact, confirm it is unclaimed and yours.

## Precedence and scope

Explicit user instructions, CLAUDE.md, and saved feedback outrank a skill. A scope the user set — local-only, draft-only, a specific issue — binds; a later broad "do it all" or "work in parallel" sets the goal, not the blast radius, and never lifts an earlier specific constraint, so reconfirm before widening. A saved "solo sandbox, skip the ceremony" note applies ONLY when the repo is confirmed solo; in a tracker that may be shared, default to confirm-and-do-not-touch-foreign-artifacts and ask.

## When in doubt

If you are unsure about ownership, or whether a write was authorized, STOP and ask. The cost of asking is a sentence; the cost of a wrong write on a shared tracker is another agent's or another person's work.
