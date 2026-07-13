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
7. Use write-capable agents only with complete clean-context packets and non-overlapping ownership.
8. Require a verification handoff from every write-capable agent.
9. After delegated source edits, run `verify-runner-agent` first when dynamic commands are required, then use `verify-agent` with runner results as evidence. Runner output supplements and never replaces static acceptance.
10. Treat a successful spawn response containing a child thread/agent ID as the precondition for any wait. Never call wait with an empty receiver set. If spawn fails or returns no child ID, return `BLOCKED` once with the tool error; do not simulate delegation or silently execute the child scope in the parent.

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
