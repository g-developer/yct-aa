# Changelog

## v4.7

- Added a compact task-signal method matrix to `AGENTS.md` and a single detailed owner in `docs/METHODS.md`.
- Restored executable First Principles, MECE, Assumption/Invariant Ledger, PDCA, Pre-mortem, FMEA-lite, adversarial review, decision-record, and negative-testing contracts while keeping the shared `AGENTS.md` below its 22KB static budget.
- Added Hypothesis–Falsification debugging, Steelman + Red Team, Trust Boundary + Abuse Cases, Bidirectional Traceability + Adjacency Scan, One-way/Two-way Door classification, Expand–Migrate–Contract, Test Strategy Selection, OODA, Evidence Triangulation, and Double-loop Learning.
- Wired task-appropriate methods into matching Codex and Claude explorer, fixer, planner, plan-checker, executor, reviewer, verifier, security, research, docs, alignment, and semantic-review roles.
- Updated `yct-aa`, `yct-risk`, `yct-fix`, and `yct-review` on both platforms to select and transmit method contracts without method ceremony.
- Added Claude-specific method-to-role mapping while keeping detailed definitions tool-neutral.
- Expanded routing fixtures from 15 to 24 cases with structured `expected_methods` coverage.
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
