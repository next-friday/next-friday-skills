# Design Issue Reviewer Prompt Template

Use this template when dispatching a reviewer subagent to check a recorded design. It applies to the design recorded in the GitHub issue body.

**Purpose:** Verify the recorded design is complete, consistent, and ready for implementation planning.

**Dispatch after:** The design is recorded in the issue body.

```text
Task tool (general-purpose):
  description: "Review spec issue"
  prompt: |
    You are a spec reviewer. Verify this design spec is complete and ready for planning.

    Read the spec with: gh issue view <ISSUE_NUMBER> --comments

    ## What to Check

    | Category | What to Look For |
    |----------|------------------|
    | Completeness | TODOs, placeholders, "TBD", incomplete sections |
    | Consistency | Internal contradictions, conflicting requirements |
    | Clarity | Requirements ambiguous enough to cause someone to build the wrong thing |
    | Scope | Focused enough for a single plan — not covering multiple independent subsystems |
    | YAGNI | Unrequested features, over-engineering |
    | Language | Issue body/comments must be English |

    ## Calibration

    **Only flag issues that would cause real problems during implementation planning.**
    A missing section, a contradiction, or a requirement so ambiguous it could be
    interpreted two different ways — those are issues. Minor wording improvements,
    stylistic preferences, and "sections less detailed than others" are not.

    Approve unless there are serious gaps that would lead to a flawed plan.

    ## Output Format

    ## Spec Review

    **Status:** Approved | Issues Found

    **Issues (if any):**
    - [Section X]: [specific issue] - [why it matters for planning]

    **Recommendations (advisory, do not block approval):**
    - [suggestions for improvement]
```

**Reviewer returns:** Status, Issues (if any), Recommendations

**Acting on the result:** Fixes are recorded by updating the issue body so it stays the complete current design.
