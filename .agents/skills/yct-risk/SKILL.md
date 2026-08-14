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
3. If plan-checker returns `ACCEPT_WITH_CHANGES` or `BLOCKED`, incorporate every required change and rerun plan-checker scoped ONLY to the enumerated gaps (delta review; a full re-review requires material new evidence and must name it); only `ACCEPT` authorizes L3/L4 execution.
4. Only if the user explicitly requested security review: spawn `security-reviewer-agent` before execution when the plan changes a sensitive trust boundary.
5. Spawn `executor-agent` only after scope is bounded and required pre-execution gates pass.
6. When security review was explicitly requested, spawn `security-reviewer-agent` again after implementation for sensitive diffs and negative-test evidence.
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
- Plans cite frozen work products by absolute path + SHA-256 instead of embedding complete programs/configs/transcripts (interface-level hunks up to ~30 lines are fine); embedded-source plan growth is plan-churn.
- Rollback/recovery notes.
- Recovery must not knowingly restore an exploitable or data-corrupting state.
- Verification plan.

Completion gate: revised plan `ACCEPT` + required security findings resolved + required runner checks `PASS` + final `verify-agent` `PASS`.

After `ACCEPT` in a session that has already compacted or materially consumed its context, emit the session-handoff file and start execution in a fresh session instead of continuing on the near-full thread.

Model availability, fallback and budget:

- Capability probe: at session start, if account model availability is unknown,
  probe once (CLI model list if the runtime exposes one; otherwise the FIRST
  spawn of each pinned tier is the probe). Record results in a session
  model-availability table and consult it before every later spawn — a model
  that failed once is never attempted again this session.
- Fallback chain: on any spawn failure — model unavailable, entitlement, or
  quota/limit exhausted — walk the agent's
  `model_fallback_chain` comment in `.codex/agents/*.toml` (comment-form:
  Codex parses no custom role fields; the skill reads the comment)
  (defaults: adjudication gpt-5.6-sol -> gpt-5.6-terra -> gpt-5.6-luna;
  implementation gpt-5.6-terra -> gpt-5.6-luna; mechanical
  gpt-5.3-codex-spark -> gpt-5.6-luna -> gpt-5.6-terra), ONE attempt per hop;
  the FINAL answer must name each failed spawn and the substitute role/tier
  that actually ran — silent substitution is a false report. Never claim the
  pinned tier ran after a downgrade; BLOCKED only after the chain is
  exhausted.
- Tier-by-criticality (hard rule): L0/L1 and ALL mechanical operations —
  polling, status reads, test execution, evidence formatting, file location,
  migration-number checks, diff self-checks, trace updates — MUST take the
  lowest available tier or plain scripts, never a top-tier model.
  gpt-5.3-codex-spark's quota is metered separately: mechanical roles pin
  spark and spend that quota first; on quota exhaustion or context overflow
  (128k, CLI-only) they fall through the chain to gpt-5.6-luna. L2
  exploration/implementation/targeted review runs mid tier. ONLY architecture
  adjudication, adversarial plan review, conflict arbitration and final
  security audit may use the top tier.
- Quality floor: each agent may declare `model_floor` (also comment-form).
  Adjudication roles
  (planner/plan-checker/verify/security/code-review/semantic) floor at
  gpt-5.6-luna — a weak model rubber-stamping a review is worse than BLOCKED,
  so below the floor report BLOCKED instead of degrading silently; the
  operator may explicitly authorize a below-floor run, recorded in the trace.
  Execution/exploration roles floor at gpt-5.5 (independent verification
  guards them); mechanical roles may take the lowest available tier. Chain
  entries below an account's real catalog simply fail their hop and continue.
- A top-tier round that adds no new evidence to the ledger is a routing
  defect: log it and downgrade the next similar round.
