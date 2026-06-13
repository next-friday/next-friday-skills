# Next Friday Skills

[![skills.sh](https://skills.sh/b/next-friday/next-friday-skills)](https://skills.sh/next-friday/next-friday-skills)

Agent skills for shipping through GitHub like a disciplined team — every change flows **issue → branch → gates → pull request → green CI**.

Coding agents are fast. Fast at building the wrong thing, fast at committing straight to `main`, and fast at declaring "done" while CI burns. These skills fix that without taking over your process: your repo's own templates, title rules, commit style, and gates are **discovered, not assumed** — with graceful fallbacks when they don't exist.

## Installation

### Claude Code

The Next Friday marketplace provides next-friday and future Next Friday plugins for Claude Code.

- Register the marketplace:

  ```bash
  /plugin marketplace add next-friday/next-friday-skills
  ```

- Install the plugin from this marketplace:

  ```bash
  /plugin install next-friday@skills
  ```

Then ask your agent to build something. The skills trigger automatically — no commands to learn, no change to how you talk to your agent.

### Any agent (skills.sh)

To install the skills into Claude Code, Cursor, or any agent the [`skills`](https://skills.sh) CLI supports:

```bash
npx skills add next-friday/next-friday-skills
```

This copies `blueprint` and `implement` into your agent's skills directory.

## Why These Skills Exist

These skills fix the failure modes that show up again and again when agents ship real software.

### #1: The Agent Built The Wrong Thing

> "Optimism is an occupational hazard of programming: feedback is the treatment."
>
> Kent Beck, [Extreme Programming Explained](https://www.amazon.com/Extreme-Programming-Explained-Embrace-Change/dp/0321278658)

**The Problem.** The oldest failure mode in software is misalignment — and agents amplify it, because they start building immediately and optimistically.

**The Fix** is [`blueprint`](./plugins/next-friday/skills/blueprint/SKILL.md): a design interview — root context first, then questions batched by dependency level, each with a recommended answer — behind a hard gate, no code until you approve a written design. The "too simple to need a design" excuse is banned; trivial changes just get a proportionally tiny design (2-4 sentences, one approval).

### #2: The Work Left No Trail

**The Problem.** Agent output that lives in a chat scrollback is gone tomorrow. Your team can't review what they can't see, and next month nobody remembers why the code looks like this.

**The Fix**: [`blueprint`](./plugins/next-friday/skills/blueprint/SKILL.md) records every design where your team already works — a GitHub issue, filled from your repo's issue template. Revisions are append-only comments, so the audit trail survives. Plans land on the same issue. The PR closes it. One thread tells the whole story.

### #3: The PR Doesn't Actually Merge

> "Done means released."
>
> Jez Humble & David Farley, [Continuous Delivery](https://www.amazon.com/Continuous-Delivery-Deployment-Automation-Addison-Wesley/dp/0321601912)

**The Problem.** Local checks passed, but the PR title fails the org's commitlint, no issue is linked, and CI is red. The agent says "done"; the repo says otherwise.

**The Fix** is [`implement`](./plugins/next-friday/skills/implement/SKILL.md): branch from the issue, run every gate the repo defines, open the PR from the repo's template with `Closes #N`, then watch CI to green. Red CI means not done — it fixes the cause, never bypasses the gate.

### Summary

These skills condense how disciplined teams actually ship — design review, traceable decisions, gated delivery — into habits your agent applies on every change, scaled to the size of the change.

## The Basic Workflow

1. **blueprint** — Activates before any code is written. Interviews you through the decision tree, proposes 2-3 approaches, presents the design in reviewable sections, then records it as a GitHub issue and writes the implementation plan as an issue comment.

2. **implement** — Activates when an issue's design and plan are approved ("implement issue #12"). Branches from the issue, works task by task, runs the full gates, opens a templated PR, and watches CI until it's green.

When the design must live as a committed spec document instead of an issue body (a human developer implements it, or it's part of a project template), blueprint's **spec document mode** records it as a file linked from the tracking issue — same interview, different artifact.

Mandatory workflows, not suggestions — the hard gates are part of the skills.

## Reference

- **[blueprint](./plugins/next-friday/skills/blueprint/SKILL.md)** — Design interview → approved design recorded in a GitHub issue → implementation plan. The default flow, with tiered depth (trivial / standard / large).
- **[implement](./plugins/next-friday/skills/implement/SKILL.md)** — Approved issue → linked branch → gated commits → templated PR → CI watched to green.

## Requirements

- [Claude Code](https://code.claude.com/docs)
- [`gh` CLI](https://cli.github.com/), authenticated (`gh auth status`)
- A GitHub-hosted repository

## Updating

Updates are usually automatic. To update immediately:

```bash
/plugin update next-friday@skills
```

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). This project follows the [Contributor Covenant Code of Conduct](./CODE_OF_CONDUCT.md).

## License

MIT — see [LICENSE](./LICENSE).

## Community

Built by [Next Friday](https://github.com/next-friday).

- **Issues**: <https://github.com/next-friday/next-friday-skills/issues>
