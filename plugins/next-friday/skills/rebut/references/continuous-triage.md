# Continuous triage across review rounds

The `rebut` skill triages the review round in front of it now, plus any round its own fix-push provokes within the same run. It does **not** watch a pull request over time. A skill is a single agent invocation with no background process, so it cannot wake itself when a reviewer comments tomorrow.

To triage every future round automatically until the PR closes, re-invoke the skill from **outside** it. The reliable mechanism is a GitHub Action that runs the agent headless on review events. The template below is a starting point. Adapt it to how your team runs the agent in CI.

## What you need

- A bot or GitHub App identity with `contents: write` and `pull-requests: write`. Do not use the default `GITHUB_TOKEN`: a push made with it does not re-trigger workflows, and you want a non-personal author for the replies.
- The agent available in CI, with the `next-friday` plugin installed and an API key in `secrets`.
- A loop guard: the agent's own fix-push provokes a fresh review round, so the workflow must skip events its own identity caused, or it re-triggers forever.

## Example workflow

```yaml
name: Continuous rebut

on:
  pull_request_review:
    types: [submitted]
  pull_request_review_comment:
    types: [created]
  issue_comment:
    types: [created]

permissions:
  contents: read

jobs:
  triage:
    # Only on pull requests, and skip events the triage identity itself caused (loop guard).
    # YOUR_TRIAGE_APP[bot] = your GitHub App's name plus the "[bot]" suffix, e.g. "my-triage-app[bot]".
    if: >-
      (github.event.pull_request != null || github.event.issue.pull_request != null) &&
      github.actor != 'YOUR_TRIAGE_APP[bot]'
    runs-on: ubuntu-latest
    timeout-minutes: 15
    permissions:
      contents: write
      pull-requests: write
    steps:
      - uses: actions/create-github-app-token@<pin-to-a-full-sha>
        id: app-token
        with:
          app-id: ${{ vars.TRIAGE_APP_ID }}
          private-key: ${{ secrets.TRIAGE_APP_PRIVATE_KEY }}

      - uses: actions/checkout@<pin-to-a-full-sha>
        with:
          fetch-depth: 0
          token: ${{ steps.app-token.outputs.token }}

      - name: Triage the new review round with rebut
        env:
          GH_TOKEN: ${{ steps.app-token.outputs.token }}
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
          PR: ${{ github.event.pull_request.number || github.event.issue.number }}
        run: |
          # Put the working tree on the PR head so any fix-push targets the PR branch, not the default branch.
          gh pr checkout "$PR"
          # Install the plugin into the CI agent, then invoke rebut headless on this PR.
          npx -y skills add next-friday/next-friday-skills
          claude -p "Use the rebut skill to triage the latest review round on PR #${PR}."
```

## Caveats

- **Cost.** Every review event runs the agent. Scope the triggers, or gate on a label, if that is too much.
- **Security.** This puts an API key and a write-capable token in CI and lets an agent push commits. Review the loop guard and token scope before enabling it on a shared repo.
- **It is opt-in.** This template is not shipped as a live workflow in this repository; copy it into a consumer repo's `.github/workflows/` and adapt it.
