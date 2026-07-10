---
name: yct-fix
description: Focused-fix workflow. Explicitly invoke with $yct-fix for one failing test, stack trace, localized bug, small refactor, or narrow cleanup.
---

# Focused Fix

Failure or task:
$ARGUMENTS

This is explicit authorization to use a focused write-capable agent when appropriate.

Process:

1. Anchor on exact failure output or requested behavior.
2. If root cause, relevant files, failure input, expected behavior, or targeted command is missing, immediately use `$yct-aa` diagnostic orchestration and start with `explorer-agent` only; do not start any other agent or writer.
3. Use Hypothesis–Falsification: observation, ranked hypotheses, prediction, falsifier, cheapest discriminating check, and result.
4. Return to the focused route only after evidence localizes the cause, expected scope is normally one to three files, risk remains L1/L2, and a targeted command is known; otherwise remain in bounded `$yct-aa` execution.
5. Before writing, apply Test Strategy Selection when the input space is parser/state-machine/combinatorial, concurrent, retry-driven, or otherwise not covered by one example. Record the invariant/oracle, selected technique, and rejected alternatives.
6. Spawn `focused-fixer-agent` for a small bounded diff and an internal PDCA/test-first loop.
7. For behavior-preserving refactors without coverage, add characterization tests before restructuring.
8. Use `spark-agent` only when Spark availability is known and near-instant text-only iteration is explicitly preferred; fall back once to `focused-fixer-agent` on model/entitlement failure.
9. Use `executor-agent` if the fix is bounded but exceeds focused-fixer constraints.
10. After delegated source edits, run `verify-runner-agent` for the targeted test/check, then use `verify-agent` with runner results as evidence.

Use `$yct-risk` discipline for auth, security/data boundaries, migrations, concurrency, public APIs, irreversible actions, or production behavior.
