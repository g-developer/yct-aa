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
   Mainline-first: implement the smallest change that makes the target
   behavior work and verify it green BEFORE adding defensive branches,
   broader tests, or extra review rounds; never pre-build defenses or tests
   for unobserved failure modes. Risk–Complexity Budget still governs
   money/persistence/security paths, but its gates demand the minimal
   acceptable contract, not gold-plating.
3. Select only the methods whose task signals match the `AGENTS.md` method matrix; method dumping is a routing defect.
4. Put each selected method and its required output into the responsible agent packet.
5. Do not use subagents for L0 or clear L1 tasks unless they add concrete value.
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
8. Use write-capable agents only with clean-context task packets.
9. Require verification handoff from any write-capable agent.
10. After delegated source edits, use `verify-runner-agent` first when dynamic commands are needed, then use `verify-agent` with runner results as evidence.
11. Do not allow overlapping write-capable agents on the same files.
12. Treat a successful `Task` result identifying the configured child agent as the precondition for claiming delegation. If `Task` fails or no child identity is returned, report `BLOCKED`; do not simulate the child or silently execute its scope in the parent.
13. Put the shared `Delivery` fields in every worker packet and enforce the role's declared policy and soft work budget.
14. Accept only a complete final deliverable or the `AGENTS.md` batch receipt. Empty output, progress narration, tool logs, or malformed receipts do not advance the task.
15. Close the previous remainder before adding scope. After the same remainder survives two receipts, return `BLOCKED` or run a separate evidence/localization packet; never carry it a third time.
16. Continue a child only when the active Claude runtime returns a confirmed continuation handle. Do not assume Agent Teams or `SendMessage`; if continuation is unavailable, pass the receipt and ledger to a new bounded packet. After invalid write-agent delivery, freeze overlapping writers and reconcile the actual diff.

Routing:

- `CLAUDE.md` is the single owner of Claude agent/model mapping. Use its route table rather than duplicating the table here.
- Do not substitute built-in Explore for the configured `explorer-agent` inside this workflow.
- Preflight browser tooling before the configured browser route; without a browser tool, use public research or report the missing capability.

Risk override: auth, security/data boundaries, migrations, concurrency, public APIs, irreversible actions, or production behavior use `/yct-risk` discipline even when the requested diff is small.

When a plan or finding proposes retries/fallbacks, durable state, workers, leases/heartbeats, caches, ACKs, or schema/protocol fields, select the Risk–Complexity Budget. High criticality requires stronger evidence; it does not automatically justify more machinery. Classify findings as `must-fix`, `observe-first`, or `documented-defer`; theoretical findings are not requirements, while security/tenant/data-loss/duplicate-side-effect/unbounded-blocking paths cannot be deferred only because they are unlikely.

Recurring routing/instruction failures use Double-loop Learning through `semantic-review-agent`: correct both the immediate defect and the underlying rule or feedback gap.

Final response must start with the conclusion and include changed files, verification, and residual risk.

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
  `opus`/`xhigh`). Escalate via role choice so Claude/Codex twins stay
  symmetric, and preflight that `CLAUDE_CODE_SUBAGENT_MODEL` is unset:
  resolution is env > per-call `model` > frontmatter pin, so a stray global
  env value silently flattens every subagent to one model (bitten
  2026-08-13). Routine location/scoping scans stay mid tier.
- After the pass, re-extract once to confirm the set is empty, or report the
  residual set verbatim; progress is the shrinking enumerated set, never
  "one more blocker fixed".

Model availability, fallback and budget:

- Capability probe: at session start, if account alias availability is unknown,
  the FIRST spawn of each pinned alias is the probe. Record results in a
  session model-availability table and consult it before every later spawn —
  an alias that failed once is never attempted again this session.
- Fallback chain: on a model/alias-unavailable spawn error, retry at the next
  tier down, walking fable -> opus -> sonnet -> haiku -> inherit, ONE attempt
  per hop, preferring a role pinned at that tier so twins stay symmetric.
  Preflight: `CLAUDE_CODE_SUBAGENT_MODEL` must be unset - it outranks
  per-call and frontmatter pins and silently flattens all subagents to one
  model (bitten 2026-08-13). The FINAL answer must name each failed spawn
  and the substitute role/tier that actually ran — silent substitution is a
  false report. Never claim the pinned alias ran after a downgrade; BLOCKED
  only after the chain is exhausted.
- Tier claims need runtime evidence: report a child's tier as "ran" only when
  runtime evidence (subagent transcript model fields, result modelUsage)
  confirms it; when the runtime does not surface the child's actual model,
  report "requested X, actual unverified". "No downgrade" without evidence is
  a false report.
- Tier-by-criticality (hard rule): L0/L1 and ALL mechanical operations —
  polling, status reads, test execution, evidence formatting, file location,
  diff self-checks, trace updates — MUST take `haiku` or plain scripts, never
  opus/fable. L2 exploration/implementation/targeted review runs `sonnet`.
  ONLY architecture adjudication, adversarial plan review, conflict
  arbitration, final security audit and deep root-cause investigation
  (strategy-zero extraction, post-failure forensics) may use opus/fable.
- Quality floor: adjudication roles (planner/plan-checker/verify/security/
  code-review/semantic) floor at `sonnet` — never auto-degrade adjudication to
  `haiku`; below the floor report BLOCKED instead (operator may explicitly
  authorize, recorded in the trace). Mechanical/recording roles may go to
  `haiku`; execution/exploration roles floor at `sonnet` unless the packet
  explicitly allows `haiku` for trivial mechanical slices.
- A top-tier round that adds no new evidence to the ledger is a routing
  defect: log it and downgrade the next similar round.

Long goals (many-item contracts, e.g. GDR-01..24):

- Slice into bounded packets of 3-5 items, or 2-3 for L3/L4/high-uncertainty work; never hand one agent the whole span.
- Reuse the same agent instance only when the runtime returns a confirmed continuation handle. Otherwise start a new packet with the prior receipt and ledger.
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

Routing & budget trace:

- For every spawn, record in the session routing ledger: role, criticality,
  model requested vs actually used (downgrade y/n), and on completion its
  token usage plus the evidence delta it added.
- Review the ledger at each phase boundary: top-tier spend with no evidence
  delta, or repeated re-reads of the same files, must change the next round's
  routing (double-loop).
