---
name: yct-fix
description: Focused fix workflow for one failing test, stack trace, localized bug, small refactor, or narrow cleanup with clear done criteria.
argument-hint: [failure-output-or-task]
disable-model-invocation: true
---

# Focused Fix

Failure or task:
$ARGUMENTS

1. Anchor on the exact failure output or requested observable behavior.
2. If the cause is unknown, run the cheapest discriminating check. Use
   `explorer-agent` only when the relevant code path cannot be localized from
   the supplied evidence; do not open a planning or review chain for a clear
   L1 fix.
3. Write only after the cause, expected behavior, allowed files, and a meaningful
   check are known. Use `focused-fixer-agent` for a localized one-to-three-file
   change and `executor-agent` when the bounded change is wider.
4. Apply AGENTS.md §3 change admission to the requested fix or refactor.
5. Prefer one high-information check and a real integration/end-to-end path
   when available. Use property, metamorphic, or characterization coverage only
   when the input space or behavior uncertainty requires it. Do not add tests
   whose oracle is incidental prompt, source, log, heading, or prose text.
6. Do not add hashes, frozen contracts/baselines, gates, retries/fallbacks,
   state, fake infrastructure, broad abstractions, or unrelated cleanup.
7. After delegated source edits, inspect the actual diff and run the targeted
   command when needed. Add an independent static verifier only when the edit is
   non-trivial, risky, or has uncertain wiring.

A focused worker's `BLOCKED`, reroute, or three-attempt stop ends only that
packet. Preserve its evidence and continue the parent goal through a new safe
route when one exists; never repeat the unchanged attempt.

Use `/yct-risk` safety discipline for auth, data/security boundaries,
migrations, concurrency, public APIs, irreversible actions, or production
behavior, but select only phases justified by a current risk.

Final output: root cause, changed files, behavior, verification, and remaining
uncertainty.
