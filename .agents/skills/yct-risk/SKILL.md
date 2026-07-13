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

Do not implement L4, destructive, irreversible, or public-contract-changing work until the user explicitly approves the reviewed plan.

Required content:
- First Principles: goal, current reality, verified facts, constraints, minimal solution, and rejection criteria.
- MECE lens, scopes, dependencies, deliberate cross-checks, and uncovered residue.
- Assumption ledger with evidence, confidence, falsifier, and failure impact.
- Invariant ledger with enforcement point, verification, and breakage risk.
- One-way/Two-way Door classification; one-way doors require alternatives, approval, and reversal/recovery analysis.
- Pre-mortem and FMEA-lite for credible failure modes, prevention, detection, tests, and recovery.
- Trust Boundary and Abuse Cases for sensitive surfaces.
- Expand–Migrate–Contract for schema, API, event, persisted-format, or config migrations.
- Test Strategy Selection appropriate to the uncertainty.
- Non-goals.
- Rollback/recovery notes.
- Recovery must not knowingly restore an exploitable or data-corrupting state.
- Verification plan.

Completion gate: revised plan `ACCEPT` + required security findings resolved + required runner checks `PASS` + final `verify-agent` `PASS`.

Model availability, fallback and budget:

- Role model pins are ceilings, not guarantees. If an agent spawn fails with a
  model-unavailable/entitlement error, retry ONCE with that agent's
  `model_fallback` from `.codex/agents/*.toml` (default `gpt-5.6-terra`), then
  report the downgrade in the final answer. Never retry the same unavailable
  model, and never claim the pinned tier ran after a downgrade.
- Remember availability for the rest of the session: after one failure of a
  pinned model, spawn later agents of that tier directly on the fallback.
- Within a role's ceiling, pick the model by task complexity and remaining
  budget: an L2 plan may run on the fallback tier; reserve top-tier spend for
  L3/L4 adjudication, adversarial review and security.
