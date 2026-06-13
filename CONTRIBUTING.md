# Contributing

Welcome! This guide walks you from zero to a merged pull request, one step at a time. You don't need prior context — follow it top to bottom.

This repo runs on its own workflow: **every change starts as an issue, lands on its own branch, and ships through a reviewed pull request.** There are no shortcuts, and that's the point — it's the same discipline the plugin teaches.

## Prerequisites

Install these three tools and verify each:

| Tool                  | Install                                              | Verify           |
| --------------------- | ---------------------------------------------------- | ---------------- |
| **Node.js** (≥ 20)    | <https://nodejs.org> or `nvm install 20`             | `node --version` |
| **pnpm** (9.x)        | `npm install -g pnpm`                                | `pnpm --version` |
| **GitHub CLI** (`gh`) | `brew install gh` (macOS) · <https://cli.github.com> | `gh --version`   |

Then sign in to GitHub from the terminal (a browser window guides you):

```sh
gh auth login
```

Check it worked:

```sh
gh auth status
```

You should see `Logged in to github.com`. If not, run `gh auth login` again.

## One-time setup

Clone the repo and install dependencies:

```sh
gh repo clone next-friday/next-friday-skills
cd next-friday-skills
pnpm install
```

`pnpm install` does two things: installs the dev tools, and wires up the git hook that checks your commit messages (husky). You only do this once.

## The contribution walkthrough

### Step 1 — Open an issue

Every change starts here. Go to the repo on GitHub, click **New issue**, pick a template (Bug, Feature, Design, or Task), and fill it in.

The **title** must follow the Hybrid Convention — the same shape as commit messages:

```text
type(scope): lowercase description
```

- `type` is one of: `build`, `chore`, `ci`, `docs`, `feat`, `fix`, `perf`, `refactor`, `revert`, `setup`, `style`, `test`
- `scope` is the area you're touching (e.g. `blueprint`, `implement`, `ci`, `repo`)
- the description is lowercase and starts with a verb

Good titles:

```text
feat(blueprint): support linear as a tracking backend
fix(implement): handle repos without a PR template
docs(repo): clarify the release steps
```

Bad titles (and why):

```text
Add Linear support          ← no type/scope, capitalized
feat: stuff                 ← no scope, vague
feat(blueprint): Add X.     ← capitalized, trailing period
```

Discuss the design in the issue first. If it changes, **add a comment** — never rewrite the issue body (the history matters).

### Step 2 — Branch from the issue

This links your branch to the issue automatically:

```sh
gh issue develop <issue-number> --checkout
```

For example, `gh issue develop 42 --checkout` creates and switches to a branch like `42-feat-support-linear`. **Never commit directly to `main`** — it's protected and will reject you.

### Step 3 — Make your change

Edit the files. To try a skill live in Claude Code while you work:

```sh
claude --plugin-dir ./plugins/next-friday
```

Edits to a skill's `SKILL.md` reload instantly in that session. For manifest changes, run `/reload-plugins`. To confirm both skills still load, ask the agent to list them — you should see `blueprint` and `implement`.

Before committing, run the same checks CI will run:

```sh
pnpm validate:markdown   # markdown is clean
pnpm validate:comments   # no prose code comments
pnpm validate:versions   # plugin.json version is in sync
claude plugin validate . # manifests and skill frontmatter are valid
```

### Step 4 — Commit

Stage only the files your change touched, then commit:

```sh
git add <the files you changed>
git commit -m "feat(blueprint): support linear as a tracking backend"
```

The commit message follows the same Hybrid Convention as the issue title. A git hook (commitlint) checks it the moment you commit. Rules:

- a valid `type` and a `scope` are both required
- everything lowercase
- the subject (the description after the colon) is **50 characters or fewer**

If your message breaks a rule, the commit is **rejected** with an explanation — fix the message and commit again. Never use `git add -A` / `git add .` (it sweeps in unrelated files), and never `--no-verify` (it skips the hook the gate exists to enforce).

### Step 5 — Add a changeset (only for behavior changes)

If your change affects how the plugin behaves (a `feat`, `fix`, `perf`, or `refactor`), record a changeset so it shows up in the next release:

```sh
pnpm changeset
```

It asks two things: the **bump type** (patch / minor / major — see [versioning](#versioning) below) and a one-line **summary**. It then writes a small markdown file under `.changeset/`. Commit that file with your change.

For `docs`, `chore`, `ci`, `style`, or `test` changes, you don't need a changeset — CI knows to skip the requirement for those.

### Step 6 — Push and open the pull request

Push your branch:

```sh
git push -u origin <your-branch-name>
```

Open the PR. Always pass `--head` explicitly so it attaches to the right branch:

```sh
gh pr create --head <your-branch-name> --title "feat(blueprint): support linear as a tracking backend" --body-file /tmp/pr-body.md
```

Two rules for the PR:

- The **title** follows the Hybrid Convention, with **no `#N` in it** — GitHub appends `(#PR)` automatically on merge, so an issue number in the title would duplicate.
- The **body** must contain `Closes #<issue-number>` on its own line, so merging closes the issue.

Fill in the PR template's checklist honestly — tick a box only when the work behind it is actually done.

### Step 7 — CI, review, and merge

When the PR opens, CI runs automatically — manifest validation, markdown, comment, and version checks, plus title and issue-link checks. Watch them:

```sh
gh pr checks <pr-number> --watch
```

- **A check is red** → fix the cause, push again, and the checks re-run. Don't ask for review with red CI.
- **All green** → the PR still needs **one approving review from a code owner** before it can merge (the repo requires it; no one merges their own unreviewed work).

Merge method is **squash only**. After merge, the branch is deleted automatically and the issue closes.

## Releasing

You never bump the version by hand. Whenever changesets land on `main`, the `release.yml` workflow (`changesets/action`) automatically opens or updates a **"version packages" PR** — so a pending release is always visible and impossible to forget.

To cut a release, a maintainer **merges that version PR**. On merge it:

1. bumps the version in `plugins/*/package.json`,
2. syncs that version into `plugin.json` (via `scripts/sync-plugin-version.sh`),
3. generates each `CHANGELOG.md`,
4. and `tag.yml` creates the matching `v<version>` git tag and GitHub Release.

**Merging the version PR is the release** — a deliberate human action, so you control the timing. You can also run `pnpm release` locally to do the same bump by hand; the workflow and the script share the one command. There is no npm publish — the plugin is distributed through the Claude marketplace, and the tagged commit is the artifact.

## Versioning

Versions follow [SemVer](https://semver.org) — `MAJOR.MINOR.PATCH`:

- **patch** (`0.1.0 → 0.1.1`): a bug fix, no behavior change for users
- **minor** (`0.1.0 → 0.2.0`): new functionality, backward compatible
- **major** (`0.1.0 → 1.0.0`): a breaking change

While the plugin is `0.x`, it's still stabilizing — even breaking changes bump the minor. The jump to `1.0.0` is a deliberate "this is stable" declaration, made when the skills have settled and seen real use. Changesets computes the next number for you; you only choose patch/minor/major.

## Conventions

### Code style

- **No prose code comments.** Intent lives in names, commit messages, PR descriptions, and the docs — not in inline comments that rot. This is enforced by `pnpm validate:comments` in CI.
- Allowed (not prose comments): shebangs (`#!`), YAML/JSON keys, license headers, and machine-meaningful directives (e.g. a lint-disable pragma).
- This is a repo-local convention. It is intentionally **not** baked into the `blueprint`/`implement` skills, which run in third-party repos and must match each target repo's own comment density.

### Skill conventions

- All artifacts are English: skill content, issues, commits, PRs.
- Skill frontmatter: `name` matches the directory; `description` states triggering conditions only — never the workflow itself.
- Versions are owned by each plugin's `package.json`; `scripts/sync-plugin-version.sh` propagates them to `plugins/<name>/.claude-plugin/plugin.json`. Never edit a manifest version by hand.
- We keep the skill set small and composable — fixes and sharpening beat new skills. Lessons from real usage get folded back into the skills in the same change that exposed them.

## Troubleshooting

| Symptom                                                       | Cause                                                                                     | Fix                                                                                      |
| ------------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| `git commit` is rejected with a commitlint error              | The message breaks the Hybrid Convention (missing scope, capitalized, subject > 50 chars) | Re-run `git commit` with a conforming message; read the error — it names the broken rule |
| CI check **"Changeset present for behavior changes"** is red  | A `feat`/`fix`/`perf`/`refactor` PR has no changeset                                      | `pnpm changeset`, commit the new file, push                                              |
| CI check **"Validate title references closed issues"** is red | The PR body has no `Closes #N`, or the title contains a `#N`                              | Add `Closes #<n>` to the body; remove any `#N` from the title                            |
| CI check **"Branch points at a real open issue"** is red      | The branch name doesn't start with an open issue number                                   | Branch with `gh issue develop <n> --checkout`                                            |
| `gh` commands fail with an auth error                         | Not signed in                                                                             | `gh auth login`, then `gh auth status` to confirm                                        |
| The PR can't merge though CI is green                         | It needs a code-owner approval                                                            | Request review; a maintainer approves, then squash-merge                                 |

## Code of conduct

This project follows the [Code of Conduct](./CODE_OF_CONDUCT.md). By participating, you agree to uphold it.
