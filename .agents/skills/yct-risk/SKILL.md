---
name: yct-risk
description: Risky-task workflow. Explicitly invoke with $yct-risk for auth, authorization, payments, migrations, public APIs, concurrency, production behavior, or architecture decisions.
---

# Risky Task Mode

Task:
$ARGUMENTS

Treat as L3/L4 until evidence shows otherwise.

This is explicit authorization to spawn appropriate subagents.

Required routing:

1. Spawn `planner-agent` for first-principles planning.
2. Spawn `plan-checker` for adversarial plan review.
3. If plan-checker returns `ACCEPT_WITH_CHANGES`, incorporate every required change and rerun plan-checker; only `ACCEPT` authorizes L3/L4 execution.
4. Spawn `security-reviewer-agent` before execution when the plan changes a sensitive trust boundary.
5. Spawn `executor-agent` only after scope is bounded and required pre-execution gates pass.
6. Spawn `security-reviewer-agent` again after implementation for sensitive diffs and negative-test evidence.
7. Spawn `verify-runner-agent` for required tests/build/lint/typecheck or smoke checks, then spawn `verify-agent` with runner and security results as evidence.
8. Spawn `research-agent` or `browser-agent` if external/current/runtime evidence is required.

Delivery gate:

- Put the shared `Delivery` fields and the role's soft work budget in every packet.
- Accept only a complete final result or the `AGENTS.md` batch receipt. Partial plan/review/verification cannot emit `ACCEPT`, `PASS`, `NO_CRITICAL_FINDINGS`, or another completion verdict.
- Close the previous remainder before new scope; after two consecutive receipts for the same remainder, return `BLOCKED` or run a separate evidence task.
- Continue the same child only with a confirmed continuation handle; otherwise pass the receipt and ledger to a new bounded packet.
- After invalid writer delivery, freeze overlapping writers and reconcile the actual diff before execution resumes.

Do not implement L4, destructive, irreversible, or public-contract-changing work until the user explicitly approves the reviewed plan.

Required content:
- First Principles: goal, current reality, verified facts, constraints, minimal solution, and rejection criteria.
- MECE lens, scopes, dependencies, deliberate cross-checks, and uncovered residue.
- Assumption ledger with evidence, confidence, falsifier, and failure impact.
- Invariant ledger with enforcement point, verification, and breakage risk.
- One-way/Two-way Door classification; one-way doors require alternatives, approval, and reversal/recovery analysis.
- Pre-mortem and FMEA-lite for credible failure modes, prevention, detection, tests, and recovery.
- Risk–Complexity Budget for any proposed reliability machinery: product/SLO commitment, evidence, simplest acceptable failure, added state/operations/tests, observability-first option, decision, and residual risk.
- Treat L3/L4 as a demand for stronger proof, not automatic authorization for durable state, workers, retries, fallbacks, or protocol expansion.
- Trust Boundary and Abuse Cases for sensitive surfaces.
- Expand–Migrate–Contract for schema, API, event, persisted-format, or config migrations.
- Test Strategy Selection appropriate to the uncertainty.
- Non-goals.
- Rollback/recovery notes.
- Recovery must not knowingly restore an exploitable or data-corrupting state.
- Verification plan.

Completion gate: revised plan `ACCEPT` + required security findings resolved + required runner checks `PASS` + final `verify-agent` `PASS`.

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
