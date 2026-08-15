# Changelog

## v4.10

Runner-execution and ledger-durability fixes, derived from an observed L3 production-release Codex session (14 subagents, 2 execution-quality failures, one polluted shared test database): a runner script died on the zsh read-only variable `status` before pytest ever started, another runner drafted a forbidden `docker rm` branch, and the default test port silently pointed at a two-day-old shared PostgreSQL that exhausted `max_locks_per_transaction` before any business assertion.

- Made the routing ledger compaction-proof in both `yct-aa` skills: the ledger is an append-only workspace file (e.g. `ROUTING_LEDGER.md` beside `IMPLEMENTATION_PLAN.md`), one line per spawn, cited by path from handoff files — in-thread-only ledgers die at context compaction and leave the spawn count unreconstructable.
- Added a stateful-target identity preflight to both `verify-runner-agent` contracts: for databases/queues/caches, assert target-instance identity and freshness first (container name, start time, or dedicated port); a default-port shared instance is contamination and returns `BLOCKED` before any business assertion.
- Added an execution-evidence rule to both `verify-runner-agent` contracts: `PASS`/`FAIL` requires the framework's own summary anchor (pytest collected/passed line, go test `ok`, jest `Tests:`) in the captured output; a bare exit code is not execution evidence — fix the invocation once, otherwise `BLOCKED` with raw output.
- Added shell discipline to both `verify-runner-agent` contracts: shell steps run as explicit bash (shebang or `bash -c`), never the caller's default shell, eliminating the zsh reserved-variable failure class.
- Deliberately not generalized (single occurrence, caught by existing gates): executor assertion reversal (independent verification worked as designed) and the unexecuted forbidden `docker rm` draft (recorded as observations under the generalization budget).
- Added a blocked-gate adjudication rule to all four `yct-aa`/`yct-risk` skills (operator-directed generalization of an observed L3 handoff defect where a session recommended recreating a production container to satisfy a factually wrong frozen contract, as the only option): frozen-artifact-vs-runtime conflicts default to amending the artifact via narrow delta re-review; every authorization ask carries at least two options including the reversible path with a ranked recommendation; execution prohibitions never prohibit recommendations; a reversed recommendation is logged as a direction error, not minimized.
- Added a tiered justified-change proof gate to the same four skills: L0/L1 needs only a failure-evidence anchor plus targeted check; L2 needs one proposal plus one adversarial delta review; one-way/production/frozen-contract changes run falsification-first on the minimal option, then 2-3 clean-context proposals under forced distinct lenses (one lens always the reversible path), evidence-strength synthesis (consensus never overrides an invariant, gate, or failing test), and a plan-checker adversarial pass with requirement traceability; proof bundles are cited by path + hash in the authorization ask. Chosen over vote/consensus schemes (e.g. Raft-style majority) because agent votes carry correlated error and the pack resolves disagreement by evidence strength, not averaging.
- Added a continue-by-default rule to the same four skills (observed defect: a session holding five plan-check-ACCEPTed local work items ended its round with a status report to "await instructions" nobody asked for): a round ends only on task completion, a hard stop condition, or a budget-forced receipt naming the next packet; approved local reversible work executes in the same round with reports accompanying, not replacing, continuation; single-consumption/production gates freeze only the gated action itself, never the local diagnosis and preparation the failure evidence already justifies.

## v4.9

Codex permission-profile migration plus session-economy hard gates, derived from an observed 2026-08-14 Codex yct-aa session where the top tier consumed ~97% of daily cost: the mechanical-tier quota went unused while the parent inlined mechanical chains, three plan-checker rounds each re-reviewed the full plan, and the plan file grew past 3,000 lines by embedding complete programs.

- Migrated all 18 `.codex/agents/*.toml` role files from the retired `sandbox_mode`/`[sandbox_workspace_write]` mechanism to Codex permission profiles (officially mutually exclusive with the old sandbox fields): 11 read-only roles now pin `default_permissions = ":read-only"`, and 7 writer roles pin `default_permissions = "yct-writer"` with a self-contained in-file `[permissions.yct-writer]` profile (extends `:workspace`, network disabled), preserving the old offline workspace-write boundary. `tests/verify_pack.sh` swaps its codex-cli field whitelist accordingly and now gates every Codex role on declaring one of the two profiles, with writer roles required to carry the network-disabled yct-writer shape. Verified against codex-cli 0.147: role-layer `default_permissions` accepted (doctor clean) and both profile semantics confirmed via zero-token `codex sandbox` probes (read-only: read OK/write denied; yct-writer: workspace write OK/network blocked).
- Added a review-loop budget to both `yct-aa` and both `yct-risk` skills: after a plan-checker `BLOCKED`/`ACCEPT_WITH_CHANGES` round, the rerun packet scopes only the enumerated gaps (delta review); defaulting to full re-review is a review-budget defect requiring named new evidence.
- Added a plan-artifact rule to the same four skills: plans cite frozen work products by absolute path + SHA-256 instead of embedding complete programs/configs/transcripts (interface-level hunks up to ~30 lines exempt); embedded-source plan growth is plan-churn.
- Closed the routing-ledger blind spot in both `yct-aa` skills: the ledger now covers inline parent turns — a parent turn running a mechanical chain (3+ repeatable commands) is logged as a routing defect and the next such chain must be delegated to a mechanical role or script.
- Added a proactive phase-boundary handoff trigger to both `yct-aa` skills and both `yct-risk` skills: at a passed major gate (plan ACCEPT, phase switch) in a session that has compacted or materially consumed its context, emit the frozen handoff file and start the next phase in a fresh session instead of rolling onto the near-full thread.

## v4.8

Anti-runaway budgets, derived from a forensic audit of a 21-day GPT-5.6 Codex session (over-generalized fixes, slot-filling agent fan-out, plan-file churn, repeated review loops, scope-count drift, unbounded autonomous rounds).

- Added a generalization budget to the shared Risk–Complexity Budget: smallest recurrence-preventing fix first; shared mechanisms/operators/recovery layers only after the same root cause is observed twice; recurring mistakes go to a local do-not ledger instead of growing the contract.
- Added parallelism and agent lifecycle rules to orchestration: parallelism equals independent critical-path tasks, idle capacity is legitimate, one audit/challenge agent per question, immediate harvest, kill after two idle waits.
- Added a review budget to verification: one acceptance pass plus one re-check per change; re-verify only the fixed issue; passed gates are settled without new evidence.
- Demoted `IMPLEMENTATION_PLAN.md` from progress channel to plan artifact; plan-file churn without code or evidence movement is a routing defect.
- Required packet authors to translate user directives into packet fields instead of forwarding ritual text verbatim into every worker.
- Extended both `yct-aa` skills with a canonical scope manifest (list + count + hash, explicit manifest-diff on scope change), an explicit budget and checkpoint for autonomous continuation rounds, and fixed-status-table progress reporting where activity does not count as progress.
- Codex 0.147 compatibility: converted the custom `model_fallback`, `model_fallback_chain`, and `model_floor` fields in all 17 `.codex/agents/*.toml` role files to comments — newer Codex rejects role files containing unknown fields ("Ignoring malformed agent role definition"), which silently disabled every YCT role. The fallback/floor values remain in-file as documentation for the skill-driven fallback procedure.
- Hardened `tests/verify_pack.sh` against platform schema drift: role toml top-level and sandbox fields are now checked against the codex-cli field whitelist (unknown fields FAIL, mirroring Codex's ignore-whole-file behavior), and pinned Codex models are cross-checked against `~/.codex/models_cache.json` when present (a missing slug WARNs, catching retired models such as bare `gpt-5.6`).
- Updated the four Codex shortcut skills to state that `model_fallback_chain`/`model_floor` are comment-form declarations read by the skill, not parsed toml fields.
- Raised the `AGENTS.md` byte budget once (26000 -> 26400) to restore working headroom after the v4.8 additions left 10 bytes; future contract additions must displace equal bytes rather than grow the budget.
- Made `security-reviewer-agent` explicit-opt-in by operator decision: it no longer runs as part of default L3/L4 or review routing and is spawned only when the user explicitly requests a security review. Updated `AGENTS.md`, `CLAUDE.md`, both role definitions, the config template registration, and the `yct-aa`/`yct-risk`/`yct-review` skills on both platforms; when it does run, blocker/high findings still block completion.
- Added evidence-freshness and wiring-first rules from an observed recurring session defect (a stale audit reused as current evidence; repeated input re-auditing while confirmed wiring sat unexecuted): `AGENTS.md` now states an audit conclusion is evidence only at its recorded anchor and must be revalidated after state changes, and that already-adjudicated wiring executes before any further input auditing; both `yct-aa` skills stamp evidence-ledger entries with an as-of anchor and the same wiring-first ordering.
- Remapped the retired bare `gpt-5.6` pins per operator approval: adjudication roles (planner, plan-checker, security-reviewer, verify, semantic-review) pin `gpt-5.6-sol`; executor, browser, and code-reviewer pin `gpt-5.6-terra`; mechanical roles (spark, batch, alignment-recorder, general, verify-runner) pin `gpt-5.3-codex-spark` to spend its separately metered quota first, chaining to `gpt-5.6-luna` then `gpt-5.6-terra` (spark is 128k-context and CLI-only). `gpt-5.6-luna` stays chain-only with no primary pin. Updated the verify model contract and all four Codex skills: the fallback trigger now covers any spawn failure including quota exhaustion, and the tier rule states the spark-first economy. Live probe `codex exec -m gpt-5.3-codex-spark` succeeded before the remap.
- Absorbed the operator's recurring per-session directive into durable rules: workers must not redefine metrics or acceptance criteria (AGENTS.md 9), and the Cleanup verification dimension now checks that diagnostic bypasses or privilege grants are absent (AGENTS.md 12). Funded by equal-byte wording trims; AGENTS.md stays under the 26,400-byte gate. Project-specific clauses (MECE fix partitions, funnel conservation, mature-case non-regression, RED-to-GREEN exact affected set) moved to the target repository's own AGENTS.md instead of this pack.
- Added a parent-tier economy rule to the Codex yct-aa skill: the parent session's model is operator-selected and the skill cannot change it, so a parent on a top adjudication tier must not inline cheaper-tier work (implementation -> terra roles, mechanical chains -> spark roles or scripts), reserving parent turns for adjudication, packet construction, and integration, and noting a top-tier-on-routine-work session once so the operator can switch the session model down. Ports the Claude-side parent-tier economy (claude-model-routing.md) to Codex, where no equivalent rule existed. Skill files carry no byte gate; AGENTS.md untouched.

## v4.7

- Replaced prompt-only final-delivery advice with a shared bounded-batch receipt contract across all 17 Claude and 17 Codex roles: role policy, soft work budget, previous-remainder-first sequencing, final-verdict gating, repeated-carry stop, changed-state reconciliation, and capability-checked continuation.
- Removed the unconditional Claude `SendMessage` recovery assumption; Agent Teams and same-agent continuation are now optional runtime capabilities, with receipt-ledger handoff as the portable fallback.
- Added cross-platform static regression checks for delivery-policy parity, budget presence, one-shot rerouting, write handoffs, command receipts, and partial-review final-verdict exclusion.
- Added a compact task-signal method matrix to `AGENTS.md` and a single detailed owner in `docs/METHODS.md`.
- Restored executable First Principles, MECE, Assumption/Invariant Ledger, PDCA, Pre-mortem, FMEA-lite, adversarial review, decision-record, and negative-testing contracts while keeping the shared `AGENTS.md` within its compact static budget.
- Added Hypothesis–Falsification debugging, Steelman + Red Team, Trust Boundary + Abuse Cases, Bidirectional Traceability + Adjacency Scan, One-way/Two-way Door classification, Expand–Migrate–Contract, Test Strategy Selection, OODA, Evidence Triangulation, and Double-loop Learning.
- Added Risk–Complexity Budget and observability-first reliability: must-handle safety/product paths, evidence-based deferral of theoretical multi-failure findings, admission gates for new runtime/protocol machinery, bounded retry ownership, lifecycle conditions, and separate treatment of code-quality refactors.
- Wired task-appropriate methods into matching Codex and Claude explorer, fixer, planner, plan-checker, executor, reviewer, verifier, security, research, docs, alignment, and semantic-review roles.
- Updated `yct-aa`, `yct-risk`, `yct-fix`, and `yct-review` on both platforms to select and transmit method contracts without method ceremony.
- Added Claude-specific method-to-role mapping while keeping detailed definitions tool-neutral.
- Expanded routing fixtures from 15 to 28 cases with structured `expected_methods` coverage, including duplicate side effects, SLO reconnects, evidence-free reliability maximalism, and refactor/mechanism separation.
- Added static cross-platform method-parity tests and method over-trigger safeguards.
- Added clean-context qualitative comparison evidence for auth-risk and unknown-parser scenarios; used evaluator findings to close security timing/composite gates and diagnostic/test-strategy regression locks.
- Upgraded fixtures to closed-world per-case criticality, route, trigger-evidence, forbidden-method, and gate contracts; removed the arbitrary method-count ceiling.
- Added structured selected-method fields to the clean-context packet and planner-produced executor/verifier packets.
- Completed detailed output contracts for First Principles, trust-boundary detection/response, Double-loop Learning, and forward/reverse trace matrices.
- Fixed the installer to recognize valid leading-indented Codex `[agents]` and `[agents."role"]` tables, with a real-home-discovered regression fixture covering merge, warnings, role preservation, and TOML parsing.
- Added a live-dispatch fail-closed guard: Codex cannot wait before receiving a child ID, Claude cannot claim delegation without an identified `Task` child, and neither parent may simulate a failed child route.
- Made `tests/verify_pack.sh` ignore `.git/**` so the package verifier passes from a real Git checkout as well as from a plain unpacked package directory.

## v4.6

- Reduced the always-loaded shared `AGENTS.md` contract and moved platform mappings back to their platform owners.
- Added explicit route precedence so risk-sensitive work overrides focused-fix routing.
- Updated Codex demanding roles to GPT-5.6 and fast portable roles to GPT-5.6 Terra.
- Added a portable Codex `focused-fixer-agent`; retained Spark only as an optional ChatGPT Pro preview route.
- Added explicit Codex role registrations and installer merging for missing role tables.
- Made all shortcut skills explicit-only on Claude and Codex.
- Required static verification after delegated source edits; dynamic runner output now supplements rather than replaces acceptance.
- Unified browser agents as read-only evidence collectors with tool preflight.
- Added fail-closed marker validation, first-state backup preservation, and Codex depth/thread warnings to the installer.
- Changed different-path duplicate agent identities to fail closed unless `--replace-conflicts` is explicit.
- Preserved legal inline Codex role registrations without adding duplicate tables.
- Made unsupported inline, dotted, quoted, or noncanonical Codex `agents` declarations fail before target writes.
- Rejected symlinked installer write targets and added a no-change regression test.
- Made `yct-direct` strictly no-agent; unsafe escalation now requires a new explicit user invocation.
- Closed Codex auto-routing for durable docs, alignment recording, and specialized-route fallback tasks.
- Clarified that Claude browser preflight must verify child-profile tool exposure, not only parent-session availability.
- Classified the routing eval JSON as an unexecuted fixture contract rather than live dispatch proof.
- Added deterministic package/installer checks and a routing evaluation set.

## v4.5

- Rechecked the package from a clean-context validation perspective.
- Added Codex `project_doc_max_bytes = 65536` handling to reduce truncation risk when YCT guidance is merged with existing global AGENTS guidance.
- Updated installer to insert top-level `project_doc_max_bytes` into existing `~/.codex/config.toml` when missing, without replacing existing config.
- Updated installer to merge YCT guidance into `AGENTS.override.md` whenever that file exists, including empty files.
- Refined installer comments to avoid GNU/BSD portability ambiguity.
- Clarified Claude small-fix routing: prefer `focused-fixer-agent`; keep `spark-agent` only as a legacy explicit compatibility worker.
- Updated Claude shortcut skills to route focused fixes to `focused-fixer-agent`.
- Updated notes to describe capability alignment instead of mechanical Codex-to-Claude mirroring.
- Revalidated install simulation, TOML/frontmatter/skill checks, merge/idempotence behavior, and zip integrity.

## Earlier iterations

- Added shared `AGENTS.md` operating contract.
- Added Codex and Claude agent sets.
- Added clean-context contracts, verification handoff packets, verifier/runner split, reviewer agents, and shortcut skills.
- Renamed shortcut skills to the `yct-*` namespace.
- Added merge-safe user-level installer for macOS and Linux.
- Added backup behavior for same-name files.
- Preserved existing skills, agents, and rules during install.

## 2026-07-13 token-economy & final-delivery hardening (from etf-skill L3 session double-loop review)

Observed in a real L3 run: evidence-heavy subagents (explorer/planner/plan-checker/
verify/code-reviewer) repeatedly hit their small `maxTurns` mid-exploration and returned
process narration ("Let's check X next") or empty finals, costing ~8 parent resume
round-trips and roughly 30% duplicated reasoning spend across ~2M subagent tokens.

- All 17 Claude agents + 17 Codex agents: injected a "Final-delivery contract" —
  final message must be the complete deliverable (never a progress note), batch
  independent tool calls, reserve last turns for the report, emit report-with-gaps
  when budget runs out, lean output (tables + file:line anchors, no pasted bodies).
- Turn budgets raised for evidence-heavy Claude roles: explorer 12→18,
  plan-checker 10→16, planner 12→18, verify 16→20, code-reviewer 14→18,
  research 14→18.
- `.claude/rules/subagent-orchestration.md`: parent-side economy — resume the SAME
  instance via SendMessage on truncated finals (never respawn), path anchors instead
  of pasted bodies in packets, one instance per multi-round review loop.
- `.claude/rules/claude-model-routing.md`: parent-tier economy — fable/opus parents
  must not do inline work the route table assigns to sonnet/haiku workers.

## 2026-07-13 model fallback, dynamic selection & long-goal economy (from external Codex-session review)

Observed on a ChatGPT account without gpt-5.6: eight Codex agents pinned to
gpt-5.6 (planner/verify/plan-checker/executor/code-reviewer/security/semantic/
browser) failed to launch with no downgrade path, burning dead calls; routing
was per-role static, not availability/budget-aware; long many-item goals
(GDR-01..24) re-read context and rebuilt evidence matrices per round.

- Codex agents pinned to gpt-5.6: added `model_fallback = "gpt-5.6-terra"`;
  spark keeps its existing agent-level reroute.
- All four routing skills on BOTH platforms (.agents + .claude yct-aa/risk/
  fix/review): "Model availability, fallback and budget" protocol — one retry
  on the declared fallback, session-wide availability memory, per-task tier
  choice within the role ceiling, mandatory downgrade reporting.
- `.claude/rules/claude-model-routing.md`: failure re-route via per-call Agent
  `model` override (fable→opus→sonnet→inherit) + "pins are ceilings" dynamic
  selection.
- yct-aa skills + `.claude/rules/subagent-orchestration.md`: long-goal slicing
  (3-5 items/packet, same-instance continuation, incremental delta matrices,
  no re-reading unchanged files across slices).

## 2026-07-13 v2: capability probe, fallback chains, tier matrix, exploration dedup, routing trace (from second external Codex review, ~5.15M-token blocked goal)

Second review confirmed the pack acted as a "task router" but not an
"entitlement-aware, capability-aware, budget-aware orchestrator": role-bound
static models, no probe, dead failures on gpt-5.6-only pins, top-tier models
doing mechanical rounds, overlapping parallel exploration, no per-round
budget/model accounting.

- All 17 Codex agents: `model_fallback_chain` (gpt-5.6 -> gpt-5.6-terra ->
  gpt-5.6-luna; terra pins -> luna; spark -> terra -> luna).
- Both platforms' routing skills upgraded to v2 protocol: session capability
  probe + availability table (a failed model is never re-attempted), one
  attempt per chain hop, mandatory downgrade reporting.
- Tier-by-criticality hard rule (skills + claude-model-routing.md matrix):
  mechanical operations (polling/status/tests/evidence formatting/file
  location/diff self-checks/trace updates) forced to lowest tier or scripts;
  top tier reserved exclusively for architecture adjudication, adversarial
  review, conflict arbitration, final security audit.
- yct-aa skills: parallel exploration hygiene (disjoint MECE scopes, ~120-line
  evidence caps, session evidence ledger with "do not re-derive" facts,
  conclusion reuse) and a routing & budget trace (per-spawn model
  requested/used + token usage + evidence delta; top-tier spend without
  evidence delta = routing defect -> downgrade next round).

## 2026-07-13 v2.1: per-role quality floors; chains extended to gpt-5.5

- Chains may now descend to gpt-5.5 (and, for mechanical roles, the account's
  lowest available tier), but with per-role `model_floor`:
  adjudication roles (planner/plan-checker/verify/security/code-review/
  semantic) floor at gpt-5.6-luna — a weak model rubber-stamping a review is a
  fake-completion vector, so below the floor the round reports BLOCKED unless
  the operator explicitly authorizes (trace-recorded). Execution/exploration
  floor at gpt-5.5 (independent verification guards them); mechanical floor
  none.
- Claude symmetric floors: adjudication never auto-degrades below `sonnet`;
  mechanical/recording may take `haiku`.
- Chain entries absent from an account's catalog fail their hop and continue —
  ids like gpt-5.5/luna are placeholders to align with the real catalog.

## 2026-07-13 v2.2: implementation fidelity contract + four-defect hunt

High-frequency real defects: missing implementation, placeholder/stub bodies,
partial implementation folded into "done", behavior diverging from the
contract md.

- Source side (executor/focused-fixer/batch/spark, both platforms):
  "Implementation fidelity contract" — REQ-01..N restatement before coding,
  forbidden placeholder/mock-only/silent-scope-narrowing/silent-substitution,
  every REQ row is implemented-with-anchors or BLOCKED-with-remaining
  ("partially done" may never be reported as done), mandatory pre-handoff
  self-grep + bidirectional REQ<->diff walk.
- Gate side (verify-agent/code-reviewer-agent, both platforms): "Four-defect
  hunt" — per-requirement verdict rows (implemented/partial/placeholder/
  missing/divergent/scope-drift) with file:line evidence; any non-implemented
  row blocks a pass verdict; mandatory placeholder greps, tautological-test
  checks, and md-wording-vs-actual-behavior divergence quotes.

## 2026-07-13 v2.3: fake/mock implementation ban + detection battery

Extends v2.2 from stub/placeholder to the full fabrication family:

- Writers (executor/focused-fixer/batch/spark, both platforms): ban on fake
  data presented as computation, test doubles on production paths (doubles
  live only in tests; packet authorization required otherwise), simulated
  success (catch-and-return-ok, log-done-without-work, echo expected output),
  demo-input hardcoding, unwired features counted as done; any
  double/simulation-only satisfaction is a BLOCKED row, never silent done.
- Gates (verify/code-reviewer, both platforms): mandatory detection battery —
  runtime-diff greps for doubles/monkeypatch/DI-default fakes, simulated
  success patterns, wiring proof from real entrypoints, test-side fakery
  (mock-of-SUT, assert-on-mock, new skip/xfail, golden updated to broken
  output); mock-based test pass ≠ runtime completion, at least one non-double
  evidence path per runtime REQ.
- verify-runner (both platforms): honest-green rule — report skipped/removed/
  weakened tests alongside any green summary, never bare exit codes.

2026-08-13 mainline-first rebalance (operator feedback: process front-loading
defense/tests/review before mainline code exists):

- yct-aa SKILL twins (both platforms), Process step 2: mainline-first rule —
  smallest change that makes the target behavior work, verified green, BEFORE
  defensive branches, broader tests, or extra review rounds; never pre-build
  for unobserved failure modes. Risk–Complexity Budget still governs
  money/persistence/security paths but demands the minimal acceptable
  contract, not gold-plating.
- yct-aa SKILL twins, Process step 7: pre-write finding freeze narrowed from
  "L2+ implementation" to L3/L4 or contract work only; ordinary L2 takes at
  most one read-only scan of the touched surface, then implements — no
  multi-agent audit rounds before mainline code exists.

2026-08-13 conjunctive-gate + session-handoff (operator feedback from the
whack-a-mole canonical-cost forensics):

- yct-aa SKILL twins: new "Conjunctive-gate debugging" section — for gates
  aggregating multiple independent blockers, one read-only extraction of the
  COMPLETE blocker/reason set comes first, then one scoped fix pass;
  fix-one-rerun-discover-next loops are banned. Evidence extraction is
  strategy zero and does not consume the three-strategy limit.
- yct-aa SKILL twins: new "Session handoff" section — on operator request,
  produce ONE frozen HANDOFF-<task>-<yyyymmdd>.md: paste-ready opening
  prompt, adjudicated facts with as-of anchors, frozen scope manifest +
  status table, ordered remaining work, prohibitions from actual mistakes,
  volatile-evidence archiving first. Anchors over bodies, tables over prose,
  target <=120 lines; new session validates anchors before acting.
- Session handoff amendment (operator correction): the handoff's source of
  truth is the outgoing session's rollout JSONL (Codex sessions dir / Claude
  projects dir) mined by scripts or a low-tier agent and cross-checked
  against repo/git state - never the outgoing session's self-summary, which
  a bloated session gets wrong. The generator (possibly a different process)
  reads the JSONL; the new session reads only the handoff file.

2026-08-13 deep-investigation tier escalation (operator feedback: triage
quality too shallow — 019ff65b ran all `/root/triage_*` root-cause agents on
the mid tier):

- yct-aa SKILL twins, Conjunctive-gate section: deep root-cause
  investigation — the strategy-zero extraction, post-failure forensics,
  repeated-regression analysis — is adjudication-tier work; the parent
  per-call escalates the investigator to the adjudication tier (Codex:
  gpt-5.6-sol high; Claude: opus/xhigh) while routine location/scoping
  scans stay mid tier. Role pins are unchanged (explorer stays mid tier by
  default) so ordinary exploration cost does not inflate.
- yct-aa SKILL twins, tier-by-criticality hard rule: the top-tier allowlist
  now reads "architecture adjudication, adversarial plan review, conflict
  arbitration, final security audit and deep root-cause investigation".

### 2026-08-13 adjudication tier defaults to xhigh (operator directive)

- `.codex/agents/`: planner-agent, plan-checker, verify-agent,
  security-reviewer-agent, semantic-review-agent — `model_reasoning_effort`
  raised `high` -> `xhigh` (sol adjudication default).
- `.agents/skills/yct-aa/SKILL.md`: deep-investigation escalation now says
  `(gpt-5.6-sol, xhigh effort)`.
- `.claude/agents/`: semantic-review-agent, verify-agent `effort: high` ->
  `xhigh`, aligning all five Claude adjudication roles at opus/xhigh.

### 2026-08-13 dedicated deep-investigator-agent role (RED routing tests)

End-to-end routing tests (codex exec CX1 / claude -p CT1) proved per-call
tier escalation unreliable on BOTH platforms: Codex spawn_agent exposes no
model/effort parameter (explorer ran gpt-5.6-terra medium — structural,
still true), and on Claude the subagent ran claude-sonnet-5 despite a
per-call `model: opus`. The Claude cause was later isolated (isolation
probes + official docs) to a global `CLAUDE_CODE_SUBAGENT_MODEL="sonnet"`
in `~/.claude/settings.json` env, which per documented precedence (env >
per-call > frontmatter > session) silently flattened ALL subagents to
sonnet; the runtime pin mechanism itself is intact — after removing the
env key, an isolated probe spawning deep-investigator-agent ran
claude-opus-5 (subagent transcript verified). Both test sessions FALSELY
reported the escalation succeeded. Fix: escalation via role choice, an
env preflight, plus an honest-reporting rule.

- NEW `.codex/agents/deep-investigator-agent.toml` (gpt-5.6-sol, xhigh,
  read-only, BATCHABLE_READ/6) and `.claude/agents/deep-investigator-agent.md`
  (opus, xhigh, permissionMode plan, maxTurns 18): strategy-zero
  conjunctive-gate extraction, post-failure forensics, repeated-regression
  analysis. Registered in pack `.codex/config.toml`, MANIFEST.txt,
  CLAUDE.md route table, method-orchestration role mapping, and
  verify_pack.sh contracts (model pin, delivery, methods, read-only set).
- yct-aa SKILL twins: deep-investigation bullet rewritten to route to
  `deep-investigator-agent`; fallback-chain bullets corrected (fallback =
  re-route to a role pinned at the lower tier, never a per-call override);
  NEW honest-reporting rule — a child's tier may be claimed as "ran" only
  with runtime evidence (Codex rollout turn_context / Claude subagent
  transcript), otherwise report "requested X, actual unverified".
- Claude yct-aa SKILL + deep-investigator-agent.md: corrected the initial
  "runtime silently ignores pins" misattribution to the env-var root cause
  above; added the preflight "CLAUDE_CODE_SUBAGENT_MODEL must be unset".
- Codex yct-aa SKILL rule 11: spawn workers as clean-context children only —
  spawn_agent rejects `agent_type` combined with a full-history fork
  ("Full-history forked agents inherit the parent agent type", observed
  live in exploration test CX3; the fail-closed BLOCKED was correct).
  Retest CX5 spawned explorer-agent at gpt-5.6-terra/medium successfully.
- Follow-up matrix (deep-investigation / exploration / mechanical batch on
  both platforms) all GREEN with rollout/JSONL evidence; Claude mechanical
  case correctly stayed parent-inline per the L0/L1 exception.
- Operator environment (outside the pack): removed
  `CLAUDE_CODE_SUBAGENT_MODEL="sonnet"` from `~/.claude/settings.json` env
  (backup `settings.json.bak-20260813-subagent-model`). Already-running
  sessions keep the stale process env until restarted.

### 2026-08-13 dead-pin fallback live tests: disclosure hardening

Two live dead-pin tests (profile-overlay dead models on spark-agent and
verify-agent, $yct-fix fixtures) proved the fallback MECHANISM works: the
dead spark-agent spawn was re-routed to focused-fixer-agent per the written
rule, and the dead verify-agent was substituted with code-reviewer-agent at
gpt-5.6-terra (above the luna adjudication floor) so the "independent
static review PASS" claim had a real agent behind it. Neither run made a
false claim — but BOTH final answers omitted the spawn failure and the
substitution entirely. Fix: in all eight yct-aa/fix/review/risk SKILL twins,
"report the tier actually used" is hardened to "the FINAL answer must name
each failed spawn and the substitute role/tier that actually ran — silent
substitution is a false report."
