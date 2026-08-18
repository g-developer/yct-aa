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

Blocked-gate adjudication and authorization asks:

- When a frozen artifact (contract, plan, gate) conflicts with verified
  runtime reality, the default recommendation is a narrow delta re-review
  amending the ARTIFACT — never mutating production/runtime to satisfy the
  document. Freezing makes an artifact authoritative, not factually
  correct; runtime evidence outranks it.
- Every authorization ask presents at least two options including the
  minimal-risk reversible one, with a ranked recommendation and its
  evidence; a single-option ask at a one-way door is a handoff defect.
- Execution prohibitions never prohibit recommendations: the message
  reporting a blocker must already carry the cheapest correct fix the
  evidence supports.
- A reversed recommendation is logged as a direction error with its root
  cause (double-loop), not minimized as "suboptimal".

Justified-change proof gate (proof precedes approval; depth scales with
reversibility, not uniformly):

- Reversible L0/L1: failure-evidence anchor + smallest change + targeted
  check is sufficient proof.
- Two-way-door L2: one proposal + one independent adversarial delta
  review.
- One-way door / production / frozen-contract change:
  1. Falsification-first: one agent tries to refute the minimal option
     (amend the artifact / observe / do nothing). If it survives
     refutation, adopt it — skip the panel.
  2. Otherwise 2-3 clean-context proposals under FORCED distinct lenses
     (minimal-change vs artifact-side vs runtime-side; one lens is always
     the reversible path). Same-prompt clones are not diversity.
  3. The parent synthesizes by evidence strength, never by vote count:
     consensus cannot override an invariant, a gate, or a failing test.
  4. Adversarial pass (plan-checker) on the synthesized winner with
     requirement->change traceability; any goal/invariant conflict
     auto-rejects regardless of agreement. ACCEPT required.
- The proof bundle (proposals, refutation result, trace map) is cited by
  path + hash in the authorization ask.

Continue-by-default (waiting is the exception):

- A round may end ONLY when the overall task is complete, a hard stop
  condition holds (user-only decision, missing authority/credentials,
  destructive action without approval, three failed fix strategies), or a
  soft-budget boundary forces a batch receipt — and the receipt names the
  next packet so work resumes immediately.
- Approved work is never a waiting point: work that is local, reversible,
  and already covered by an ACCEPT or a standing authorization executes in
  the SAME round. Status reports accompany continuation; they do not
  replace it.
- Single-consumption and production gates freeze only the gated action
  itself, never the local work that prepares or diagnoses it. After a
  failed gated attempt, pivot immediately to the diagnosis and local fixes
  the failure evidence already justifies.
- Ending a round with executable approved work remaining, to "await
  instructions" nobody was asked for, is a routing defect — log it in the
  ledger.
- Serial is likewise the exception for read-only work: at each stage or
  batch start, enumerate the independent read-only lanes (MECE — static
  review, evidence location, contract mapping, dynamic inventory) and
  launch them as ONE wave alongside the serial writer chain. Lanes must
  not overlap and writers stay single-owner. Serial-only routing is
  justified only when the lane inventory is genuinely empty; needing the
  user to demand more SubAgents is a routing defect — log it. Splitting
  one problem to fill slots remains forbidden.
- A round does not end while any SubAgent is in flight or a batch
  receipt is unclosed: answer an interposed user question, then RESUME
  the harvest-and-advance loop in the same round — progress answers and
  estimates are not terminal states. Never end on a promise tail ("will
  start / about to / currently running"): orchestration halts when the
  turn ends, and in-flight work sits unharvested until the user prods.
  Legal endings: all agents harvested, a true hard stop, a named
  user-only decision, or a delivered handoff. At each stage/wave closure
  emit a <=3-line milestone receipt (stage — in-flight — next action);
  it is contractual, not optional commentary.

Single-consumption attempt economy (a gated one-shot buys only what no
local check can prove):

- Before consuming a single-consumption / production / one-shot
  authorization, enumerate the COMPLETE conjunctive layer chain the
  attempt depends on (runtime identity, connection/transaction, clock and
  anchors, storage authority vs. overwritable projection, upstream
  point-in-time reconstructability, error classification — extend per
  task) and falsify each layer with the cheapest local check first. The
  gated attempt is the most expensive falsifier in the system; spending
  it on a hypothesis a local check could have killed is a routing defect.
- The execution packet states the predicted failure modes. A consumed
  attempt failing in an UNPREDICTED layer is a diagnosis-scope defect:
  log it and run a strategy-zero full-surface audit
  (`deep-investigator-agent`) that re-extracts the whole layer chain from
  the code path — not just the failing layer — before the next attempt is
  authorized. A second consecutive unpredicted-layer failure hard-blocks
  further attempts until that audit completes.
- A fix that turns one layer green is necessary, not sufficient: never
  promote it to complete root cause. After every gated failure, re-run
  the layer enumeration against the new evidence before proposing the
  next fix.

Idle-wait and kill discipline (an idle WAIT is not an idle WORKER):

- Two idle waits trigger a PROGRESS CHECK, not an automatic kill: inspect
  changed-state evidence first (target-file mtime/diff growth, artifact
  freshness, receipt heartbeat). A demonstrably progressing worker gets a
  longer bounded wait; only a stalled one is killed and re-scoped.
- Size the FIRST wait to the role's typical duration: adjudicators and
  planners run minutes, not tens of seconds. Batch status via one
  agent-list poll instead of stacked short waits; every wait return is
  a paid parent-tier turn.
- Write-capable workers are never blind-killed: a mid-flight kill leaves
  partial writes that cost a freeze-and-reconcile pass before any
  respawn. If a writer repeatedly outlives its wait budget, the packet
  was too big — re-slice the scope so writes land within the soft
  budget; a kill-respawn cycle re-issuing the same oversized packet is
  churn, not progress.
- Interrupting an adjudicator (plan-checker/verify) to demand a verdict
  yields no gate pass: accept only a complete delivery with its evidence
  body, or re-run the gate as a fresh narrower packet.

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
