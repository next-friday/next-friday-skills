# Verification discipline

Done is proven by fresh evidence, never by the action's own success line. This is the discipline the skills share; each applies it to its own gates.

## Claim only from fresh evidence

Before claiming a gate passed, a build is green, a reply posted, or the work done: run the exact check THIS turn, read its full output and exit code, and only then claim it. If you have not run the check in this message, you cannot say it passes. Ban "should pass", "looks right", "seems fine" before the evidence. A command's own printed success line is not proof the effect persisted; re-query the real state whenever the action can silently fail.

## Verify against the current code

Never apply, refute, or act on a claim without checking it against the CURRENT code, not its framing and not your memory. Reproduce it, or run the relevant gate, or read the documented convention, then decide.

## Evidence over performance

Every verdict carries concrete evidence: a command's output, a commit SHA, the line that disproves the claim. Never "you're absolutely right", never a bare dismissal. Performative agreement is not verification.

## Red-green for a fix

A regression test is proven only red-green: write the failing test first and watch it fail for the right reason; for an existing fix, revert it and watch the test go red, then restore it and watch it pass. A test you never watched fail proves nothing, and "I tested it by hand" did not happen unless it is a committed, repeatable check.
