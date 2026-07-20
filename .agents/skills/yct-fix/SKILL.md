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
   A failing theoretical edge-case test does not authorize new runtime state, retries, fallbacks, workers, or protocol fields without the Risk–Complexity Budget evidence gate.
6. Spawn `focused-fixer-agent` for a small bounded diff and an internal PDCA/test-first loop.
7. For behavior-preserving refactors without coverage, add characterization tests before restructuring.
8. Use `spark-agent` only when Spark availability is known and near-instant text-only iteration is explicitly preferred; fall back once to `focused-fixer-agent` on model/entitlement failure.
9. Use `executor-agent` if the fix is bounded but exceeds focused-fixer constraints.
10. After delegated source edits, run `verify-runner-agent` for the targeted test/check, then use `verify-agent` with runner results as evidence.

Delivery gate:

- Put the shared `Delivery` fields and the role's soft work budget in every packet.
- `focused-fixer-agent` and `spark-agent` are one-shot: if the change does not fit, return `BLOCKED` and reroute to `executor-agent`; do not open a continuation batch.
- Accept only a complete final result or the `AGENTS.md` batch receipt. The runner records one command family before the verifier consumes it.
- After invalid writer delivery, freeze overlapping writers and reconcile the actual diff before retrying or rerouting.

Use `$yct-risk` discipline for auth, security/data boundaries, migrations, concurrency, public APIs, irreversible actions, or production behavior.

Model availability, fallback and budget:

- Capability probe: at session start, if account model availability is unknown,
  probe once (CLI model list if the runtime exposes one; otherwise the FIRST
  spawn of each pinned tier is the probe). Record results in a session
  model-availability table and consult it before every later spawn — a model
  that failed once is never attempted again this session.
- Fallback chain: on a model-unavailable/entitlement error, walk the agent's
  `model_fallback_chain` from `.codex/agents/*.toml`
  (default gpt-5.6 -> gpt-5.6-terra -> gpt-5.6-luna), ONE attempt per hop;
  report the tier actually used. Never claim the pinned tier ran after a
  downgrade; BLOCKED only after the chain is exhausted.
- Tier-by-criticality (hard rule): L0/L1 and ALL mechanical operations —
  polling, status reads, test execution, evidence formatting, file location,
  migration-number checks, diff self-checks, trace updates — MUST take the
  lowest available tier or plain scripts, never a top-tier model. L2
  exploration/implementation/targeted review runs mid tier. ONLY architecture
  adjudication, adversarial plan review, conflict arbitration and final
  security audit may use the top tier.
- Quality floor: each agent may declare `model_floor`. Adjudication roles
  (planner/plan-checker/verify/security/code-review/semantic) floor at
  gpt-5.6-luna — a weak model rubber-stamping a review is worse than BLOCKED,
  so below the floor report BLOCKED instead of degrading silently; the
  operator may explicitly authorize a below-floor run, recorded in the trace.
  Execution/exploration roles floor at gpt-5.5 (independent verification
  guards them); mechanical roles may take the lowest available tier. Chain
  entries below an account's real catalog simply fail their hop and continue.
- A top-tier round that adds no new evidence to the ledger is a routing
  defect: log it and downgrade the next similar round.
