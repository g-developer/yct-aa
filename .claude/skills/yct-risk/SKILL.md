---
name: yct-risk
description: High-risk task workflow for auth, authorization, payments, data migrations, public APIs, concurrency, security, production behavior, or architecture decisions.
argument-hint: [task]
disable-model-invocation: true
---

# Risky Task Mode

Task:
$ARGUMENTS

Treat this as L3/L4 until proven otherwise.

Required discipline:

- Use First Principles with current reality and rejection criteria.
- Use a named MECE decomposition lens and report uncovered residue.
- Maintain Assumption and Invariant ledgers with evidence and verification fields.
- Classify consequential decisions as One-way/Two-way Doors; one-way doors require alternatives, approval, and recovery analysis.
- Run a Pre-mortem and FMEA-lite before implementation.
- Run Steelman + Red Team adversarial plan review.
- Use Trust Boundary and Abuse Cases for sensitive surfaces.
- Use Expand–Migrate–Contract for schema, API, event, persisted-format, or config migrations.
- Use Test Strategy Selection: choose characterization, property, metamorphic, compatibility, fault-injection, or negative tests as the uncertainty requires.
- Require verification and rollback/recovery thinking.

Routing:

1. Use `planner-agent` for the implementation plan.
2. Use `plan-checker` for adversarial review.
3. If plan-checker returns `ACCEPT_WITH_CHANGES`, incorporate every required change and rerun it; only `ACCEPT` authorizes L3/L4 execution.
4. Use `security-reviewer-agent` before execution when the plan changes a sensitive trust boundary.
5. Use `executor-agent` only after the plan is accepted, scope is bounded, and required pre-execution gates pass.
6. Use `security-reviewer-agent` again after implementation for sensitive diffs and negative-test evidence.
7. Use `verify-runner-agent` for required dynamic checks, then use `verify-agent` with runner and security results as evidence.

For L4 strategic planning or plan challenge, the parent may override the planner/checker invocation to Fable when available and justified; otherwise use their Opus defaults. Keep approved implementation on the scoped Sonnet executor and retain Opus/Fable verification around it.

Do not implement immediately if the decision is irreversible, destructive, or public-contract changing. Ask for explicit approval when required.
Rollback or recovery must not knowingly restore an exploitable or data-corrupting state.

Completion gate: revised plan `ACCEPT` + required security findings resolved + required runner checks `PASS` + final `verify-agent` `PASS`.

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
- A top-tier round that adds no new evidence to the ledger is a routing
  defect: log it and downgrade the next similar round.
