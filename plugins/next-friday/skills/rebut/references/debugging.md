# Debugging discipline

When a check, gate, or claimed behavior fails, debug by method, not guess-and-retry. Each skill applies this to its own failure surface.

- **Reproduce it.** Read the actual error and run the failing check yourself; do not work from a remembered or assumed failure. If you cannot reproduce it on command, you cannot prove you fixed it.
- **Make it fail reliably.** The feedback loop is the real work: get to a single command that fails now and will pass once fixed. Until you have it, you are guessing.
- **Isolate by one variable.** Change ONE thing and re-run; a burst of simultaneous changes hides which one mattered. Bisect the diff or the input to localize the cause.
- **Form one falsifiable hypothesis before touching code:** "the cause is X because Y", and then test that prediction. A hypothesis you cannot state is a vibe; sharpen it or discard it.
- **Fix the root cause, not the symptom.** A guard added only where the error surfaced leaves every sibling path broken; fix it where all paths route through.
- **Stop after about three non-converging attempts.** Repeated failure, especially surfacing somewhere new each time, means the approach is wrong, not that the next attempt is the one. Step back, question the design, and surface it to the user.
