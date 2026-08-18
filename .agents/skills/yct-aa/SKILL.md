---
name: yct-aa
description: Explicit auto-routing mode for non-trivial engineering tasks. Invoke with $yct-aa to classify risk, choose the smallest useful Codex subagent set and model tier, use clean-context packets, and independently verify delegated source edits. Do not use for trivial direct work or review-only requests.
---

# YCT Auto-agent Mode

Task:
$ARGUMENTS

This is explicit authorization to spawn appropriate Codex subagents.

Follow `AGENTS.md` and `.codex/agents/*.toml`.

Process:

1. Apply precedence: explicit mode, safety/risk override, task shape, needed phases, then verification.
2. Classify task criticality and use the smallest sufficient set of agents.
   Mainline-first: implement the smallest change that makes the target
   behavior work and verify it green BEFORE adding defensive branches,
   broader tests, or extra review rounds; never pre-build defenses or tests
   for unobserved failure modes. Risk–Complexity Budget still governs
   money/persistence/security paths, but its gates demand the minimal
   acceptable contract, not gold-plating.
3. Select only the methods whose task signals match the `AGENTS.md` method matrix; method dumping is a routing defect.
4. Put each selected method and its required output into the responsible agent packet.
5. Keep L0 and clear L1 work in the parent unless delegation adds concrete value.
6. Use read-only agents first when scope is unclear.
7. Pre-write finding freeze applies only to L3/L4 or contract work after risk
   classification; L0/L1 and ordinary L2 are exempt — L2 takes at most one
   read-only scan of the touched surface, then implements. No multi-agent
   audit rounds before mainline code exists.
   - Before spawning a writer, declare one named MECE review lens, its disjoint
     audit scopes, explicit exclusions, authoritative inputs, and adjacency
     cross-checks.
   - Complete the read-only audit pass across that inventory. Parallel audits
     may run only on disjoint scopes.
   - The parent reconciles all audit results into one evidence-backed,
     deduplicated finding set: findings, no-finding scopes, unresolved evidence,
     conflicts and their resolution, severity, Risk–Complexity Budget class
     (`must-fix`, `observe-first`, or `documented-defer`), and file/symbol
     anchors. This is
     the maximum finding set discoverable from the declared inventory at the
     evidence cutoff; do not claim completeness beyond that inventory.
   - Freeze that finding set before any source write. Every writer packet must
     cite the frozen set and its declared exclusions; writing may address only
     approved `must-fix` findings and the implementation plan. Preserve
     `observe-first` and `documented-defer` entries as residual-risk records,
     not hidden implementation requirements.
   - Material new evidence that changes a requirement, boundary, or declared
     scope reopens the read-only audit, requires reconciliation, and freezes a
     replacement finding set before further writes. Post-write verification is
     a separate acceptance pass, not a substitute for this gate.
8. Use write-capable agents only with complete clean-context packets and non-overlapping ownership.
9. Require a verification handoff from every write-capable agent.
10. After delegated source edits, run `verify-runner-agent` first when dynamic commands are required, then use `verify-agent` with runner results as evidence. Runner output supplements and never replaces static acceptance.
11. Treat a successful spawn response containing a child thread/agent ID as the precondition for any wait. Never call wait with an empty receiver set. If spawn fails or returns no child ID, return `BLOCKED` once with the tool error; do not simulate delegation or silently execute the child scope in the parent. Spawn workers as clean-context children only, never as full-history forks: spawn_agent rejects `agent_type` combined with a full-history fork ("Full-history forked agents inherit the parent agent type", verified 2026-08-13) — the packet, not forked history, carries the context.
12. Put the shared `Delivery` fields in every worker packet and enforce the role's declared policy and soft work budget.
13. Accept only a complete final deliverable or the `AGENTS.md` batch receipt. Empty output, progress narration, tool logs, or malformed receipts do not advance the task.
14. Close the previous remainder before adding scope. After the same remainder survives two receipts, return `BLOCKED` or run a separate evidence/localization packet; never carry it a third time.
15. Reuse a child only when a confirmed continuation handle exists. Otherwise pass the receipt and evidence ledger to a new bounded packet. For invalid write-agent delivery, freeze overlapping writers and reconcile the actual diff first.

Routing:

- Exploration: `explorer-agent`.
- Planning: `planner-agent`.
- Plan review: `plan-checker`.
- Focused implementation: `focused-fixer-agent` by default.
- Near-instant text-only iteration: `spark-agent` when Spark is available — its quota is metered separately, so prefer spending it; on model/entitlement/quota failure reroute once to `focused-fixer-agent`.
- Bounded implementation: `executor-agent`.
- Mechanical edits: `batch-agent`.
- Static verification: `verify-agent`.
- Dynamic verification: `verify-runner-agent`.
- Correctness review: `code-reviewer-agent`.
- Security/data-boundary review (explicit user request only): `security-reviewer-agent`.
- External research: `research-agent`.
- Browser evidence: `browser-agent`.
- Prompt/rules maintenance: `semantic-review-agent`.
- Durable confirmed documentation: `docs-agent`.
- Confirmed status/decision recording: `alignment-recorder-agent`.
- Small read-only fallback only when no specialized route fits: `general-agent`.

Risk overlay:

- Auth, authorization, payments, secrets, injection, uploads, migrations, tenant/data boundaries, concurrency, public APIs, irreversible actions, or production behavior use L3/L4 discipline even when the requested diff is small.
- When a plan or finding proposes retries/fallbacks, durable state, workers, leases/heartbeats, caches, ACKs, or schema/protocol fields, select the Risk–Complexity Budget. High criticality requires stronger evidence; it does not automatically justify more machinery.
- Classify review findings as `must-fix`, `observe-first`, or `documented-defer`. A theoretical finding is not a product requirement, while security/tenant/data-loss/duplicate-side-effect/unbounded-blocking paths cannot be deferred only because they are unlikely.
- L3/L4 uses `planner-agent`, `plan-checker`, scoped execution, `security-reviewer-agent` only when the user explicitly requests security review, `verify-agent`, and dynamic verification as needed.
- Do not execute destructive, irreversible, or public-contract-changing work without explicit approval.
- For recurring routing/instruction failures, use Double-loop Learning through `semantic-review-agent`: fix the immediate defect and the underlying rule or feedback gap.

Conjunctive-gate debugging (multi-blocker failures):

- When a failure sits behind a gate that aggregates multiple independent
  blockers (hard_blockers, anomaly sets, validation chains), FIRST run one
  read-only extraction that enumerates the COMPLETE current blocker/reason
  set from the real decision object or log - then fix the enumerated set in
  one scoped pass. Never enter a fix-one-rerun-discover-next loop.
- Evidence extraction is strategy zero: it does not count against the
  three-strategy limit, and hypothesis fixes launched without the full
  enumeration in hand are a routing defect.
- Deep root-cause investigation - the strategy-zero extraction, forensics
  after a failed fix round, repeated-regression analysis - is
  adjudication-tier work: route it to `deep-investigator-agent` (pinned
  gpt-5.6-sol, xhigh). spawn_agent has no per-call model override
  (verified 2026-08-13), so tier escalation happens ONLY via role choice;
  routine location/scoping scans stay on the mid-tier explorer.
- After the pass, re-extract once to confirm the set is empty, or report the
  residual set verbatim; progress is the shrinking enumerated set, never
  "one more blocker fixed".

Final response:
- Conclusion.
- Changed files.
- Verification.
- Risks / not checked.

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
  spawn_agent has no per-call model parameter (verified 2026-08-13), so a
  fallback hop means re-routing to a role pinned at that tier, never passing
  an override. The FINAL answer must name each failed spawn and the
  substitute role/tier that actually ran — silent substitution is a false
  report. Never claim the pinned tier ran after a downgrade; BLOCKED only
  after the chain is exhausted.
- Tier claims need runtime evidence: report a child's tier as "ran" only when
  runtime evidence (rollout turn_context, status output) confirms it; when the
  runtime does not surface the child's actual model, report "requested X,
  actual unverified". "No downgrade" without evidence is a false report.
- Tier-by-criticality (hard rule): L0/L1 and ALL mechanical operations —
  polling, status reads, test execution, evidence formatting, file location,
  migration-number checks, diff self-checks, trace updates — MUST take the
  lowest available tier or plain scripts, never a top-tier model.
  gpt-5.3-codex-spark's quota is metered separately: mechanical roles pin
  spark and spend that quota first; on quota exhaustion or context overflow
  (128k, CLI-only) they fall through the chain to gpt-5.6-luna. L2
  exploration/implementation/targeted review runs mid tier. ONLY architecture
  adjudication, adversarial plan review, conflict arbitration, final
  security audit and deep root-cause investigation (strategy-zero
  extraction, post-failure forensics) may use the top tier.
- Parent-tier economy: the parent session's model is operator-selected
  (config.toml / `/model`); this skill cannot change it. A parent running a
  top adjudication tier (e.g. gpt-5.6-sol) must not inline work the route
  table assigns to cheaper tiers — implementation belongs to terra roles,
  mechanical chains (downloads, hashing, builds, batch re-runs, log scans) to
  spark roles or plain scripts. Parent inline turns are the most expensive
  tokens in the session; reserve them for adjudication, packet construction,
  and integration. Exception: L0/L1 single-file edits where packet overhead
  exceeds the edit. When the session model is a top tier and the round's work
  was routine, note it once in the final response so the operator can switch
  the session model down.
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

Long goals (many-item contracts, e.g. GDR-01..24):

- Slice into bounded packets of 3-5 items, or 2-3 for L3/L4/high-uncertainty work; never hand one agent the whole span.
- Reuse the same agent instance only when the platform returns a confirmed continuation handle. Otherwise start a new packet with the prior receipt and ledger.
- The next slice closes the previous remainder first; a second consecutive carry-over becomes `BLOCKED` or a separate evidence task.
- Maintain evidence/trace matrices incrementally - append delta rows per slice,
  never rebuild the full matrix from scratch.
- Do not re-read unchanged files across slices; cite prior slice anchors
  (file:line) instead.

Parallel exploration hygiene & evidence cache:

- Assign parallel explorers DISJOINT file scopes (MECE, each packet lists
  explicit "not-yours" exclusions); overlapping scopes pay twice for the same
  files.
- Cap each returned evidence summary (~120 lines, tables + file:line anchors);
  request gaps later instead of accepting full dumps.
- Maintain a session evidence ledger; later packets carry
  "already-established facts (do not re-derive)" with anchors, and agents only
  fill gaps.
- Before spawning a new explorer, check the ledger and reuse standing
  conclusions instead of re-deriving them.
- Every ledger entry carries its as-of anchor (commit/file state/time). Reuse
  it only after confirming the anchor still holds; a stale audit must not
  gate current work. Once a fact is adjudicated, execute its wiring before
  any further input auditing — a new audit round requires new evidence.

Scope freeze, autonomy budget, and status reporting:

- At task start, extend the finding freeze with one canonical scope manifest
  (item list + count + content hash). Every later packet and report cites that
  manifest instead of re-deriving membership; a scope change must be declared
  explicitly with a manifest diff. Mixing counts from different manifests in
  one report is a defect.
- An autonomous continuation round ("continue", overnight or unattended
  execution) must carry an explicit budget (time, tokens, or item count) and a
  checkpoint. At the budget, emit the status table and stop starting new work;
  standing authorization is not an unlimited budget.
- Report progress only as a fixed status table over the frozen manifest:
  total scope / fixed / evidence-pending / truly-insufficient / re-run /
  not-re-run, each row backed by verifiable evidence. Activity ("searching",
  "auditing", "in progress") is not progress and must not be reported as
  movement.

Session handoff (operator will continue in a NEW process - Codex, Claude, or other):

- On request ("给个交接内容" or equivalent), write ONE frozen handoff file at
  the repo root: `HANDOFF-<task>-<yyyymmdd>.md`. Anchors only - no pasted
  file bodies, no history narration.
- Source of truth: mine the outgoing session's rollout JSONL (Codex:
  `~/.codex/sessions/<yyyy>/<mm>/<dd>/rollout-*-<thread-id>.jsonl`; Claude:
  `~/.claude/projects/<project>/<session-id>.jsonl`) with scripts or a
  low-tier agent, then cross-check against current repo/git state. Never
  build the handoff from the outgoing session's self-summary alone - a
  bloated or degraded session mis-summarizes itself; the JSONL is the
  lossless record. Extract from it: user directives still in force,
  adjudicated conclusions and their anchors, last delivered state, open
  receipts, unfinished work. The handoff may be produced by a DIFFERENT
  process than the one being replaced; only the generator reads the JSONL -
  the new session reads only the handoff file.
- Required content, in this order:
  1. Opening prompt: a paste-ready first message for the new session - route
     invocation, absolute path of this handoff file, criticality level, and
     the hard prohibitions.
  2. Adjudicated facts, each with an as-of anchor (commit / file:line /
     table+key / hash). The new session reuses them without re-derivation
     and re-verifies an anchor before relying on it.
  3. Frozen scope manifest (list + count + content hash) and the current
     status table over it (total / closed / evidence-pending /
     truly-insufficient).
  4. Remaining work in execution order, each item with its next concrete
     action and owner route.
  5. Prohibitions: every mistake the old session actually made, stated as a
     ban.
  6. Volatile evidence (paths under /tmp, running processes, un-archived
     artifacts) with the instruction to archive or re-hash FIRST.
- Conciseness contract: complete enough that the new session never re-derives
  an adjudicated fact or repeats closed work; short enough to read in one
  pass - tables over prose, target <=120 lines.
- The new session's first turn validates the anchors before acting; a stale
  anchor reopens only that one fact, never the whole investigation.

Review-loop and plan-artifact budget:

- After a plan-checker `BLOCKED` or `ACCEPT_WITH_CHANGES` round, the next
  checker packet scopes ONLY the enumerated gaps (carry the gap list in the
  packet); it re-verifies those fixes, not the whole plan. A full re-review
  requires material new evidence (e.g. a structural plan rewrite) and must
  name it. Defaulting to full re-review is a review-budget defect.
- Plan artifacts cite frozen work products by absolute path + SHA-256 instead
  of embedding them: complete programs, configs, or long command transcripts
  do not belong in the plan body (interface-level hunks up to ~30 lines are
  fine). A plan that grows by embedded source is plan-churn, not progress.

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

Routing & budget trace:

- For every spawn, record in the session routing ledger: role, criticality,
  model requested vs actually used (downgrade y/n), and on completion its
  token usage plus the evidence delta it added.
- The ledger is an append-only FILE in the workspace (e.g. ROUTING_LEDGER.md
  beside IMPLEMENTATION_PLAN.md), one line per spawn — never in-thread-only
  notes: an in-thread ledger dies at context compaction and the spawn count
  becomes unreconstructable. Handoff files cite this ledger by path.
- The ledger covers INLINE parent turns too: a parent turn that runs a
  mechanical chain (3+ repeatable commands — hashing, inspects, syntax
  checks, batch re-runs, log scans) is logged as a routing defect, and the
  NEXT such chain must be delegated to a mechanical role or plain script
  before running. Single probe commands are exempt.
- At a passed major gate (plan ACCEPT, phase switch) in a session that has
  already compacted or materially consumed its context, proactively emit the
  frozen handoff file and recommend starting the next phase in a fresh
  session; rolling a new phase onto a near-full thread by inertia is a
  routing defect.
- Review the ledger at each phase boundary: top-tier spend with no evidence
  delta, or repeated re-reads of the same files, must change the next round's
  routing (double-loop).
