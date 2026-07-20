---
name: yct-aa
description: Explicit auto-routing mode for non-trivial engineering tasks. Invoke /yct-aa to apply AGENTS.md/CLAUDE.md routing, select the smallest useful Claude subagent/model set, use clean-context packets, and independently verify delegated source edits.
argument-hint: [task]
disable-model-invocation: true
---

# YCT Auto Agent

Task:
$ARGUMENTS

Follow `AGENTS.md` and `CLAUDE.md`.

Process:

1. Classify task criticality: L0 trivial, L1 focused, L2 multi-file, L3 risky, L4 strategic.
2. Use the lightest process that controls actual risk.
3. Select only the methods whose task signals match the `AGENTS.md` method matrix; method dumping is a routing defect.
4. Put each selected method and its required output into the responsible agent packet.
5. Do not use subagents for L0 or clear L1 tasks unless they add concrete value.
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
8. Use write-capable agents only with clean-context task packets.
9. Require verification handoff from any write-capable agent.
10. After delegated source edits, use `verify-runner-agent` first when dynamic commands are needed, then use `verify-agent` with runner results as evidence.
11. Do not allow overlapping write-capable agents on the same files.
12. Treat a successful `Task` result identifying the configured child agent as the precondition for claiming delegation. If `Task` fails or no child identity is returned, report `BLOCKED`; do not simulate the child or silently execute its scope in the parent.

Routing:

- `CLAUDE.md` is the single owner of Claude agent/model mapping. Use its route table rather than duplicating the table here.
- Do not substitute built-in Explore for the configured `explorer-agent` inside this workflow.
- Preflight browser tooling before the configured browser route; without a browser tool, use public research or report the missing capability.

Risk override: auth, security/data boundaries, migrations, concurrency, public APIs, irreversible actions, or production behavior use `/yct-risk` discipline even when the requested diff is small.

When a plan or finding proposes retries/fallbacks, durable state, workers, leases/heartbeats, caches, ACKs, or schema/protocol fields, select the Risk–Complexity Budget. High criticality requires stronger evidence; it does not automatically justify more machinery. Classify findings as `must-fix`, `observe-first`, or `documented-defer`; theoretical findings are not requirements, while security/tenant/data-loss/duplicate-side-effect/unbounded-blocking paths cannot be deferred only because they are unlikely.

Recurring routing/instruction failures use Double-loop Learning through `semantic-review-agent`: correct both the immediate defect and the underlying rule or feedback gap.

Final response must start with the conclusion and include changed files, verification, and residual risk.

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

Long goals (many-item contracts, e.g. GDR-01..24):

- Slice into bounded packets of 3-5 items; never hand one agent the whole span.
- Reuse the SAME agent instance for adjacent slices (continuation reuses its
  cached context); do not respawn per slice.
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
