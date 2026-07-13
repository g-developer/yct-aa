---
name: yct-fix
description: Focused fix workflow for one failing test, stack trace, localized bug, small refactor, or narrow cleanup with clear done criteria.
argument-hint: [failure-output-or-task]
disable-model-invocation: true
---

# Focused Fix

Failure or task:
$ARGUMENTS

Assume this is L1/L2 unless evidence shows broader scope.

Rules:

- Anchor on exact failure output or requested behavior.
- If root cause, relevant files, failure input, expected behavior, or targeted command is missing, immediately use `/yct-aa` diagnostic orchestration and start with `explorer-agent` only; do not start any other agent or writer.
- Use Hypothesis–Falsification: observation, ranked hypotheses, prediction, falsifier, cheapest discriminating check, and result.
- Return to `focused-fixer-agent` only after evidence localizes the cause, expected scope is normally one to three files, risk remains L1/L2, and a targeted command is known; otherwise stay on bounded `/yct-aa` execution.
- Inspect nearby code and tests first.
- Minimize file count and diff size.
- Use `focused-fixer-agent` with an internal PDCA/test-first loop when the scope is bounded.
- Before writing, apply Test Strategy Selection for parser/state-machine/combinatorial, concurrent, or retry-driven input spaces. Record the invariant/oracle, selected technique, and rejected alternatives.
- For behavior-preserving refactors without coverage, add characterization tests before restructuring.
- Use `/yct-risk` discipline for auth, security/data boundaries, migrations, concurrency, public APIs, irreversible actions, or production behavior.
- After delegated source edits, use `verify-runner-agent` for the targeted command, then use `verify-agent` with runner results as evidence.
- Run the narrowest relevant verification.

Final output:

- Root cause.
- Change summary.
- Verification.
- Remaining uncertainty.

Model availability, fallback and budget:

- Role model pins (agent frontmatter) are ceilings, not guarantees. If a spawn
  fails with a model/alias-unavailable error, retry ONCE with an explicit
  per-call `model` override on the Agent tool, walking down
  fable -> opus -> sonnet -> inherit, and report the downgrade. Never retry the
  same unavailable alias, and never claim the pinned tier ran after a downgrade.
- Remember availability for the rest of the session: after one failure of an
  alias, spawn later agents of that tier directly on the working override.
- Within a role's ceiling, pick the model by task complexity and remaining
  budget: an L2 plan may run planner on `sonnet` via per-call override; reserve
  top-tier spend for L3/L4 adjudication, adversarial review and security.
