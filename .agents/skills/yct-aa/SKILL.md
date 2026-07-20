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
3. Select only the methods whose task signals match the `AGENTS.md` method matrix; method dumping is a routing defect.
4. Put each selected method and its required output into the responsible agent packet.
5. Keep L0 and clear L1 work in the parent unless delegation adds concrete value.
6. Use read-only agents first when scope is unclear.
7. Pre-write finding freeze applies only to L2+ implementation or contract work
   after risk classification; L0 and clear L1 work remain exempt.
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
11. Treat a successful spawn response containing a child thread/agent ID as the precondition for any wait. Never call wait with an empty receiver set. If spawn fails or returns no child ID, return `BLOCKED` once with the tool error; do not simulate delegation or silently execute the child scope in the parent.
12. Put the shared `Delivery` fields in every worker packet and enforce the role's declared policy and soft work budget.
13. Accept only a complete final deliverable or the `AGENTS.md` batch receipt. Empty output, progress narration, tool logs, or malformed receipts do not advance the task.
14. Close the previous remainder before adding scope. After the same remainder survives two receipts, return `BLOCKED` or run a separate evidence/localization packet; never carry it a third time.
15. Reuse a child only when a confirmed continuation handle exists. Otherwise pass the receipt and evidence ledger to a new bounded packet. For invalid write-agent delivery, freeze overlapping writers and reconcile the actual diff first.

Routing:

- Exploration: `explorer-agent`.
- Planning: `planner-agent`.
- Plan review: `plan-checker`.
- Focused implementation: `focused-fixer-agent` by default.
- Near-instant text-only iteration: `spark-agent` only when Spark availability is known and speed is explicitly preferred; on model/entitlement failure reroute once to `focused-fixer-agent`.
- Bounded implementation: `executor-agent`.
- Mechanical edits: `batch-agent`.
- Static verification: `verify-agent`.
- Dynamic verification: `verify-runner-agent`.
- Correctness review: `code-reviewer-agent`.
- Security/data-boundary review: `security-reviewer-agent`.
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
- L3/L4 uses `planner-agent`, `plan-checker`, scoped execution, `security-reviewer-agent` when sensitive boundaries are involved, `verify-agent`, and dynamic verification as needed.
- Do not execute destructive, irreversible, or public-contract-changing work without explicit approval.
- For recurring routing/instruction failures, use Double-loop Learning through `semantic-review-agent`: fix the immediate defect and the underlying rule or feedback gap.

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

Routing & budget trace:

- For every spawn, record in the session routing ledger: role, criticality,
  model requested vs actually used (downgrade y/n), and on completion its
  token usage plus the evidence delta it added.
- Review the ledger at each phase boundary: top-tier spend with no evidence
  delta, or repeated re-reads of the same files, must change the next round's
  routing (double-loop).
