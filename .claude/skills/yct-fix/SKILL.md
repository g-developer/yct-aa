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

- Capability probe: at session start, if account alias availability is unknown,
  the FIRST spawn of each pinned alias is the probe. Record results in a
  session model-availability table and consult it before every later spawn —
  an alias that failed once is never attempted again this session.
- Fallback chain: on a model/alias-unavailable spawn error, retry with an
  explicit per-call `model` override on the Agent tool, walking
  fable -> opus -> sonnet -> haiku -> inherit, ONE attempt per hop; report the
  tier actually used. Never claim the pinned alias ran after a downgrade;
  BLOCKED only after the chain is exhausted.
- Tier-by-criticality (hard rule): L0/L1 and ALL mechanical operations —
  polling, status reads, test execution, evidence formatting, file location,
  diff self-checks, trace updates — MUST take `haiku` or plain scripts, never
  opus/fable. L2 exploration/implementation/targeted review runs `sonnet`.
  ONLY architecture adjudication, adversarial plan review, conflict
  arbitration and final security audit may use opus/fable.
- Quality floor: adjudication roles (planner/plan-checker/verify/security/
  code-review/semantic) floor at `sonnet` — never auto-degrade adjudication to
  `haiku`; below the floor report BLOCKED instead (operator may explicitly
  authorize, recorded in the trace). Mechanical/recording roles may go to
  `haiku`; execution/exploration roles floor at `sonnet` unless the packet
  explicitly allows `haiku` for trivial mechanical slices.
- A top-tier round that adds no new evidence to the ledger is a routing
  defect: log it and downgrade the next similar round.
