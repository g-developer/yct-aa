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
- Apply the Risk–Complexity Budget before proposing reliability machinery: name the product/SLO commitment, evidence, simplest acceptable failure, added state/operations/tests, observability-first option, decision, and residual risk.
- Treat L3/L4 as a demand for stronger proof, not automatic authorization for durable state, workers, retries, fallbacks, or protocol expansion.
- Run Steelman + Red Team adversarial plan review.
- Plans cite frozen work products by absolute path + SHA-256 instead of embedding complete programs/configs/transcripts (interface-level hunks up to ~30 lines are fine); embedded-source plan growth is plan-churn.
- Use Trust Boundary and Abuse Cases for sensitive surfaces.
- Use Expand–Migrate–Contract for schema, API, event, persisted-format, or config migrations.
- Use Test Strategy Selection: choose characterization, property, metamorphic, compatibility, fault-injection, or negative tests as the uncertainty requires.
- Require verification and rollback/recovery thinking.

Routing:

1. Use `planner-agent` for the implementation plan.
2. Use `plan-checker` for adversarial review.
3. If plan-checker returns `ACCEPT_WITH_CHANGES` or `BLOCKED`, incorporate every required change and rerun it scoped ONLY to the enumerated gaps (delta review; a full re-review requires material new evidence and must name it); only `ACCEPT` authorizes L3/L4 execution.
4. Only if the user explicitly requested security review: use `security-reviewer-agent` before execution when the plan changes a sensitive trust boundary.
5. Use `executor-agent` only after the plan is accepted, scope is bounded, and required pre-execution gates pass.
6. When security review was explicitly requested, use `security-reviewer-agent` again after implementation for sensitive diffs and negative-test evidence.
7. Use `verify-runner-agent` for required dynamic checks, then use `verify-agent` with runner and security results as evidence.

Delivery gate:

- Put the shared `Delivery` fields and the role's soft work budget in every packet.
- Accept only a complete final result or the `AGENTS.md` batch receipt. Partial plan/review/verification cannot emit `ACCEPT`, `PASS`, `NO_CRITICAL_FINDINGS`, or another completion verdict.
- Close the previous remainder before new scope; after two consecutive receipts for the same remainder, return `BLOCKED` or run a separate evidence task.
- Continue the same child only with a confirmed continuation handle; do not assume Agent Teams or `SendMessage`. Otherwise pass the receipt and ledger to a new bounded packet.
- After invalid writer delivery, freeze overlapping writers and reconcile the actual diff before execution resumes.

For L4 strategic planning or plan challenge, the parent may override the planner/checker invocation to Fable when available and justified; otherwise use their Opus defaults. Keep approved implementation on the scoped Sonnet executor and retain Opus/Fable verification around it.

Do not implement immediately if the decision is irreversible, destructive, or public-contract changing. Ask for explicit approval when required.
Rollback or recovery must not knowingly restore an exploitable or data-corrupting state.

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
  not overlap and writers stay single-owner. Record the lane inventory
  in the ledger before the stage's first spawn; a one-lane wave must
  name why the inventory is empty. Needing the user to demand more
  SubAgents is a routing defect — log it. Splitting one problem to fill
  slots remains forbidden.
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
- State closure before the next spawn: when a gate verdict lands, a
  writer is interrupted or killed, or a batch closes, record a one-line
  closure — verdict settled, disk state reconciled, plan file touched
  only if a stage's goal/scope/status changed — before spawning the
  next gate or writer on that thread. Re-gating a settled decision
  without new evidence, respawning over an unreconciled worktree, and
  plan edits that only narrate progress are one defect: unclosed state.
- Mechanical work rides the cheapest lane: polling, status reads, test
  runs, evidence collection, and file location belong to scripts or the
  lowest runner tier, never top-tier parent turns, which are reserved
  for adjudication, packet construction, and integration. A sustained
  mechanical exec streak in the parent thread is a routing defect —
  log it.

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
- Restorative writes (rollback, reverse patch, file restore) are
  hash-anchored on BOTH sides: before writing, verify the target's
  current hash equals the base the reverse patch was computed against;
  after writing, verify the intended postimage hash. Any mismatch stops
  the writer and freezes that file — never rebuild a reverse patch from
  remembered or stale line ranges, never stack corrective patches on an
  unverified base; recover forward from fresh evidence instead.

Model availability, fallback and budget:

- Capability probe: at session start, if account alias availability is unknown,
  the FIRST spawn of each pinned alias is the probe. Record results in a
  session model-availability table and consult it before every later spawn —
  an alias that failed once is never attempted again this session.
- Fallback chain: on a model/alias-unavailable spawn error, retry with an
  explicit per-call `model` override on the Agent tool, walking
  fable -> opus -> sonnet -> haiku -> inherit, ONE attempt per hop; the FINAL
  answer must name each failed spawn and the substitute model/tier that
  actually ran — silent substitution is a false report. Never claim the
  pinned alias ran after a downgrade; BLOCKED only after the chain is
  exhausted.
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
