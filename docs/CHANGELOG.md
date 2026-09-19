# Changelog

## Unreleased

- Preserve installed TraeX model/effort overrides and default new roles to
  inherit. Clarify task-local undo in dirty worktrees, closed-transport
  recovery boundaries, and same-execution evidence for historical claims.

- Clarified completed-child lifecycle: consume terminal results promptly, retain
  handles only for concrete follow-ups, and close only through a real runtime
  capability. Distinguished concurrency admission, memory unloading and history
  visibility; interrupt and archive are not resource-release substitutes.

## v4.21

- Added the explicit TraeX installation path, rendering Markdown roles from
  current shared contracts and linking shortcuts to one canonical source.
- Replaced legacy Claude imports with inline TraeX guidance, preserved user
  config, and added reviewed backup migration for duplicate YCT discovery
  entries. Added installation and real `traex exec` behavioral checks.
- Tightened absolute-worktree packets on follow-up, recurring-design reuse,
  incomplete child acceptance, and owned command-session collection based on
  the 2026-09-16 devbox session audit.
- Added conditional drift correction, observable-progress distinctions and
  cumulative-change acceptance to the existing shared method guidance. Made
  Chinese plain-language output explicit and removed exact shell-spelling
  tests and artificial tool-call counts from live workflow checks.
- Fixed physical install-root overlap, stale managed skill resources and
  quoted TOML document-limit keys. Excluded inherited parent execution from
  native command evidence and distinguished automated checks from acceptance.

## v4.20.1

Documentation only. `docs/NOTES.md` records the verified result of the
`general-agent` write probes (2026-09-10, CLI 0.153.4, NAS and Mac): Codex
subagents inherit the parent's sandbox policy; role-layer
`default_permissions = ":read-only"` and `sandbox_mode = "read-only"` do not
make a child stricter, so the `:read-only` lines in the Codex role files are
intent, not enforcement. The NAS `workspace-write` sandbox is unusable
(bubblewrap cannot create user namespaces), which is why NAS sessions run
`danger-full-access`.

## v4.20

Initiative and follow-through release for GPT-6 Astra, derived from forensics
of the 30 most recent NAS Codex sessions (2026-09-06..09; main session
`01a06e89`, 79 turns, 4,739 tool calls, MusicTagWeb batch reruns) read against
the Astra guide (bias toward action and completion; complete authorized work
before asking; audit older-model "ask first / stop" scaffolding; name and
quote the skill instruction that caused a pause) and pvncher's Astra skill
notes (stable facts in AGENTS.md, completion criteria, risk by tools not
prompts). Observed failure chain: §13's "two zero-delta boundaries override
every continue clause" fired on a debug loop and on user-authorized batches,
ending goals with 445 items unstarted ("触发你提供的 AGENTS.md 停批条件"); the
parent ended turns with a progress note while its own children ran, so the
user had to type "继续"; the parent sampled slow items instead of measuring the whole batch
("此前我只分析了部分慢样本"), consistent with §11's read-once rule and the
one-pass review budget although the transcript does not record the rule
being cited; role receipt headers (Delivery status / Overall
ready / Route used) appear in the supplied digests, although whether they
were emitted as parent final responses remains unverified; `general-agent` ran a
151-call task against a 3-call estimate.

- AGENTS.md §1: precedence item 1 now names system and developer
  instructions. Direct user instructions outrank this contract and skill or
  role guidance within file-based guidance, but not `developer_instructions`
  or enforced permissions; the parent routes authorized work to a suitable
  role. A file rule that blocks authorized work must be named, linked, and
  quoted, separated from the model's interpretation. §13/§15 refer to §1
  instead of repeating the quote duty.
- AGENTS.md §3, new "Initiative and follow-through": treat `帮我/你去/能不能/
  我想要` as instructions; ask for missing information when a dependent
  decision needs it and continue independent authorized work in the same
  turn; check whether authorization is already established before asking
  again; collect task-critical child results before final delivery, subject
  to cancellation, runtime deadlines, and §13 limits; finish everything
  independent of an external blocker before reporting it (repeated probes of
  the same dependency are not independent work); status questions and
  corrections are updates to the active goal, not cancellation. "Smallest
  action" now means no wasted steps, not shallow: measure the whole input
  once when the decision depends on the whole.
- AGENTS.md §13: the batch rule is decidable again. A zero-yield boundary
  triggers diagnosis of the shared cause; two consecutive zero-yield
  boundaries pause further production fan-out; bounded diagnosis, repair, or
  one representative trial continues, and fan-out resumes only when the trial
  shows the cause removed. A renamed strategy, smaller packet, or new agent
  is not evidence. Debugging and single-feature work are exempt from the
  yield threshold; a user-directed rerun of independent items is still a
  batch, and authorization, safety, and total-cost limits apply to every
  task shape. Three failures exhaust only the unchanged attempt; continue
  through a different approach when evidence supports a specific explanation
  and a discriminating check. The cost-projection stop reports and asks
  instead of ending. The duplicate two-boundary rule in §9 and the
  yield-gated continue paragraph are removed; §3 owns continuation.
- AGENTS.md §2/§4/§8/§9/§11/§12: progress notes only at decision points, and
  never as a substitute for continuing; batch calibration report is not a
  waiting point; WIP-cap formula replaced by bottleneck naming plus an
  explicit "do not increase fan-out when added workers do not feed the
  bottleneck"; workers complete independently useful work first and return
  the remainder as `BLOCKED`/`REROUTE` with the exact prerequisite (partial
  delivery is not acceptance, and a worker blocker does not end the parent
  goal); a receipt label alone is not evidence, the parent judges the
  underlying evidence and reports outcomes without copying delivery headers;
  evidence-insufficient dispositions are reported separately from successful
  units; §11 evidence reuse is bounded by validity of inputs, code,
  environment, and acceptance criteria instead of receipt integrity, and
  whole-input measurement is allowed; §12 review budget applies to one
  decision with unchanged evidence, and new requirements, source changes,
  test results, or concrete counterexamples may reopen a conclusion.
- All 19 Codex role TOMLs and 18 Claude agent files: receipt ritual removed
  (delivery status, overall ready, acceptance-verdict line, delivery policy,
  route used); "Soft work budget: N tool-use turns" became "Expected size:
  about N tool calls", a routing estimate rather than an automatic stop, with
  a reroute when the remaining work no longer fits the role; the final
  deliverable is self-contained (completed work, evidence, changed files,
  remaining work, exact missing prerequisite) and no acceptance verdict is
  issued for incomplete required coverage; unified `BLOCKED` semantics as in
  §9. Verdict enums gain `PARTIAL` for implementation roles, `REJECT` and
  `NEEDS_INFO` for plan-checker, and `REROUTE` for verify-agent (workspace
  writes reroute to the runner instead of blocking). Role-specific: executor
  derives routine checks but not product policy, completes an in-scope change
  only when it is independently coherent, and returns a tradeoff instead of
  silently shrinking requested behavior; general-agent resolves only routine
  ambiguity that does not change scope, authority, or conclusion; plan-checker
  and security reviewer distinguish inability to complete a review from a
  blocking finding and withhold acceptance for unreviewed required scope;
  focused-fixer reports the three strategies tried. Runner/batch boundary
  `BLOCKED`s (unavailable services, judgement-heavy work) are unchanged.
- `yct-aa` twins: new step 7 "Drive to completion" (apply §3: continue
  independent work while clarification is pending, status question is a goal
  update, collect child results subject to cancellation and §13, apply §13
  before further fan-out after zero yield, report blockers per §1); sharper
  descriptions; expected-size wording; no receipt-label relay. `yct-fix`
  continues through a route supported by the evidence and within authorized
  scope and cost; `yct-risk` applies §13's batch-yield and total-cost limits;
  `yct-direct` completes only work independent of a prohibited verification
  and never executes a dependent action before a required pre-execution
  check.
- docs/ROUTING.md durable-delivery section, README bounded-delivery
  paragraph, and `.claude/rules/subagent-orchestration.md` updated to the
  expected-size, deliverable, `BLOCKED`, and batch-rule semantics;
  docs/NOTES.md gains an Astra calibration section (literal instruction
  following, effort as a tuning experiment with the recorded model/effort
  mix, exec-job context size, general-agent misuse and its unexplained
  `danger-full-access` sandbox).
- Review: the whole change set was reviewed by GPT-6 Astra (`codex exec`,
  reasoning effort max) in two rounds; its accepted edits are the §1/§3/§8/
  §9/§11/§12/§13 wording above, the role `BLOCKED`/deliverable/size lines,
  the model-attribution correction, and the round-2 fixes (clarification
  exception phrased by runtime capability, verify-agent mission/REROUTE
  consistency, Codex semantic-review `BLOCKED` verdict, `yct-review` and
  `yct-risk` deferring to §12's review budget and reopening rules, and the
  digest-based claims in docs marked as unverified where the channel was not
  preserved). Not applied: removing the §7 method table and §8 capability
  map (no evidence they cause stops), `unbounded_connection_retries = false`
  (503 path unverified), narrowing Mac workspace roots and runner
  permissions, and the two behavioral E2E scenarios the review requires
  (recorded as open follow-ups in docs/NOTES.md).
- Installed configs (not in the package): NAS yct `model_reasoning_effort`
  medium -> high as a tuning experiment; stale `[projects]` trust entries for
  missing directories removed on Mac and NAS with backups.

## v4.19

- Moved Codex planner, plan checker, deep investigator, and explicitly requested
  security review to GPT-6 Astra xhigh; retained Sol for semantic review and
  independent static verification.
- Moved normal batch, alignment recording, and small read-only work to Luna;
  dynamic verification now uses Terra. Added the optional Codex-only
  `batch-spark-agent`, with `batch-agent` as its non-Spark substitute.
- Made the parent responsible for Spark quota/entitlement failure, including
  failed spawn: skip both Spark roles for the current task, reconcile partial
  work, and continue through the named non-Spark route. Removed obsolete
  commented fallback fields that never implemented runtime switching.
- Corrected Claude model precedence for 2.1.251+ and the force override added
  in 2.1.257; frontmatter models are defaults subject to quality floors.
  Removed unsupported effort settings from Haiku roles.

- Consolidated shared change admission and verification in AGENTS.md; the
  yct-aa twins now focus on task intent, risk, role selection, and completion.
- Distinguished required feature behavior from incident evidence, bounded
  canary preparation from batch fan-out, and parent acceptance from worker
  delivery. Preserved existing role boundaries, permissions, and explicit
  invocation policy while updating the model assignments above.
- Corrected role instructions that blocked on optional packet fields, treated
  soft budgets as forced stops, or demanded fixed planning/review stages.
- Replaced the mechanical worker's duplicated requirement ledger and textual
  placeholder census with scoped diff and behavior verification.
- Updated current routing documentation to match the installed configuration
  format and package model pins; historical audit records remain unchanged.

## v4.18

Orchestration-runaway release derived from three-way forensics (Claude Opus 5 + Codex gpt-5.6-sol max + Claude Fable 5, with cross-review of each other's findings) of the 2026-08-31/09-01 MusicTagWeb Codex sessions (`rollout-2026-08-31T14-36-54-01a05689...jsonl`, `rollout-2026-09-01T11-22-31-01a05afd...jsonl`; >=698.5M tokens combined at review snapshot, ~23 h, 3 completed migrations against a 1,070-directory target). Observed failure chain: skill blanket spawn authorization plus permissive §8 wording -> unbounded read-only fan-out with no canary or WIP cap -> `fork_turns:"all"` context inheritance (75 children, 195.8M tokens, 71% of session-A child spend; omitting the parameter defaults to all) -> worker receipts consumed as product-progress scheduling signals -> local changes escalated into 16 full-ledger rebuilds (22,727 rows each) -> §13 persistence clauses converting failure into more fan-out. Every edit below was applied to the live Mac/NAS installs first, byte-verified identical across both, and independently verified by Fable 5 (diff-vs-spec, byte identity plus permissions, semantic regression, and 5 behavioral acceptance scenarios: PASS_WITH_ISSUES, residuals below).

- AGENTS.md §8: new paragraph — the section is routing guidance, never spawn authorization; it does not satisfy an "explicit ask" under a higher-priority no-spawn restriction, and an injected platform restriction wins.
- AGENTS.md §8 parallelism rewrite: a canary must pass the real terminal acceptance path before fan-out; default upstream read-only WIP is capped at 2x the narrowest downstream side-effect stage; a requested concurrency number is a ceiling, not a target; a zero-admission batch must not be enlarged or repeated; name the current bottleneck stage before scaling, and report a mismatch before spawning.
- AGENTS.md §9: the child receives nothing but the packet — spawn with a clean context, full-history inheritance prohibited, bounded inheritance only for a named dependency that cannot be restated; a receipt proves worker delivery only and is never product progress; terminal means user-accepted outcome or evidence-complete stop, not a FINAL/ANSWERED/HOLD/CONFLICT label; two consecutive batch boundaries with zero terminal-unit delta forbid further fan-out.
- AGENTS.md §11: evidence invalidation is dependency-scoped — revalidate only members recorded as changed plus named global invariants; a full-corpus rebuild requires the acceptance contract to demand whole-corpus output, at most once per closed production batch; read authoritative input once per anchor and resume from the most recent durable receipt across compaction instead of re-scanning.
- AGENTS.md §13: two economic stop conditions added (two consecutive zero-delta batch boundaries, which override every continue clause in the contract; extrapolated cost clearly beyond the user-authorized scale); the closing continue paragraph is now yield-gated.
- AGENTS.md §3/§4/§14: each run of an inherited full-corpus rebuild needs the same justification as creating it; homogeneous batch is its own task shape (calibrate 1–3 items end to end, report the extrapolated total, script the mechanical majority); post-compaction resume from durable receipts, re-scanning only what no intact receipt covers.
- `.agents/skills/yct-aa`: the blanket "This is explicit authorization to spawn" line is replaced by admission-gated consideration (canary, WIP cap, terminal-unit yield); Process 6 requires passing `fork_turns` explicitly — `"none"` by default, a small number only for a named recent dependency, `"all"` or omission forbidden; Process 9's continue clause is subordinated to the AGENTS.md economic stops.
- `.claude/skills/yct-aa`: Process 6 forbids parent-history inheritance (restate facts in the packet); same Process 9 subordination.
- Recorded residuals (non-blocking): the §8 disclaimer names only §8, not the CLAUDE.md route table; the `.claude` twin is stricter than §9's bounded-inheritance exception (safe direction); the once-per-batch rebuild bound vs legitimate rebuild triggers (builder change, corrupted output) awaits a dependency-invalidation matrix; blanket read-once on mutable inputs leans on the contradictory/new-evidence escape hatch. Cross-review consensus: the durable fix for fan-out and `fork_turns` is tool-layer enforcement, which rule text cannot provide.

## v4.17

Delta release closing the 2026-08-16 forensic findings (session `rollout-2026-08-16T09-36-42-01a00836...jsonl`, 22.3 h, 194.8M tokens, 14 compactions, 292 spawns) that v4.16 — derived from the successor session 01a00d01 — did not cover, plus release hygiene. The turn-end/milestone rule from the same forensics already shipped in v4.14–v4.16 (see the v4.14 entry).

- All four `yct-aa`/`yct-risk` skills, idle-wait/writer section: restorative writes (rollback, reverse patch, file restore) are hash-anchored on BOTH sides — verify the preimage hash before writing and the intended postimage hash after; any mismatch stops the writer and freezes that file; rebuilding reverse patches from remembered or stale line ranges and stacking corrective patches on an unverified base are banned, recover forward from fresh evidence instead. Single occurrence but must-handle class (irreversible source damage): in session 01a00836 a reverse patch built from stale HEAD line ranges deleted an entire production function instead of restoring the pre-writer state (receipt at L10355); the session then correctly froze writes and returned BLOCKED — the rule prevents the damage, not just the recovery.
- docs/NOTES.md, deployment-model exception: explicit `$yct-…` re-invocation mid-session re-reads the CURRENT on-disk SKILL.md (verified in rollout 01a00836: v4.13 body 25,577B injected at open, v4.14 body 26,133B re-injected after `install.sh` + re-invocation), so SKILL-borne rule updates can be hot-loaded into a running session by re-invoking the skill; only the merged AGENTS.md snapshot stays pinned until restart. This bounds the v4.14 "restart required" note to AGENTS.md-carried rules.
- tests/verify_deploy.sh, version-exact injection check: the longest-line marker proved identical across adjacent SKILL versions (observed at v4.16), so probe 2 could pass on a stale injected body. It now additionally greps EVERY grep-safe installed body line (ASCII, quote/backslash-free, >=16 chars after trimming) against the probe session JSONL and fails on any missing line; new lines join the check automatically, no manual version markers.
- MANIFEST.txt bumped to v4.17 (release-hygiene catch-up: v4.16 shipped still carrying the v4.15 package name).

## v4.16

First live test of the v4.13 two-stage compaction gate, derived from full JSONL forensics of the 2026-08-17 Codex session (`rollout-2026-08-17T07-56-41-01a00d01...jsonl`, 30.9 h, 331.1M tokens, 21 compactions, 305 spawns), independently re-verified line-by-line against the raw JSONL and re-reviewed under yct-cr discipline before any rule change. The reread half of the gate worked completely: all 21 post-compaction state notes re-read the installed `yct-aa` SKILL (19 of 21 within 6–33 s; 0/14 in the pre-v4.13 thread). The handoff half failed 21/21: no handoff file was written after any compaction — the session's only handoff write landed at the session tail (L16838) on operator request — and the stop-at-second-compaction never fired; the closest thing to a waiver was a task-scoped "授权各种例外，务必完成" message (L8911) that could cover at most compactions 13–21 and never named the gate. Fixes convert the failed duties into observable pre-spawn actions.

- AGENTS.md §14 byte-swap rewrite (542 -> 545 bytes, total 26,399 of 26,400): the first-compaction duty is now an observable mechanical action — a handoff-file write that must precede any new spawn and whose path the compaction state note cites — replacing "emits or refreshes", which 21 consecutive compactions satisfied with nothing; and the waiver is now defined: it must name this gate, and task-scoped "authorize exceptions / must finish" wording never waives it (the exact pattern observed at L8911).
- All four `yct-aa`/`yct-risk` skills, Continue-by-default section: the lane inventory becomes a pre-spawn observable — recorded in the ledger before the stage's first spawn, and a one-lane wave must name why the inventory is empty. The v4.14 lane-wave rule was demonstrably in this session's snapshot and still produced 185 single-spawn groups out of 235 and five escalating user parallelism prompts (one more than the four that motivated v4.14); enumeration without a recorded artifact did not change spawn behavior.
- All four skills, same section: new state-closure bullet merging three observed defect families into one rule — a landed gate verdict, an interrupted/killed writer, or a closed batch each require a one-line closure (verdict settled, disk state reconciled, plan file touched only on stage change) before the next spawn on that thread. Observed: five plan-checker gates across four plan variants of one decision (P2H-4B); a writer interrupted and respawned 22.5 s later with zero reconcile execs in the gap (L12687 -> L12693); 96 plan-file patches used as a progress channel.
- All four skills, same section: mechanical work rides the cheapest lane (scripts or the lowest runner tier, never top-tier parent turns, which are reserved for adjudication, packet construction, and integration) — the parent thread spent 1,113 mechanical execs (ledger/plan patches, polling, status reads) inline on the most expensive tokens in the system.
- tests/verify_pack.sh: marker gates for the three new shared-section bullets and the two new §14 clauses, so a future trim cannot silently drop them.
- Confirmed covered, no new rules: ~50 production one-shot execs in 3 clusters used as probes reduce to the v4.11 attempt-economy rule (violation, not gap). Positive validations recorded: tier discipline and wait sizing held (short agent waits 16/570 = 2.8%, main peaks 300/120/180 s), no empty task deliveries, no promise-tail endings.
- Observation item, single occurrence, no rule change: stacked ≤30 s waits reappeared but as exec cell polls (`wait` + `write_stdin`, 30 s yields, e.g. 14 consecutive at L10232–10284), which the v4.13 wait-sizing bullet — scoped to agent waits — does not govern; if it recurs, the fix is yield sizing, not agent-list polling.

## v4.15

Deployment-verification hardening, derived from the 2026-08-16 live `codex exec` probe round: static byte-comparison after `install.sh` could not answer "is routing actually live in a fresh session?" (a full diagnostic round was spent on an ambient-inventory false alarm that dynamic probes would have pre-empted), and the four-twin shared-section consistency check had been re-implemented as a throwaway scratchpad script in two separate releases. Both one-off procedures are generalized into pack test infrastructure; SKILL/AGENTS content is unchanged this release.

- tests/verify_deploy.sh (new): dynamic post-install acceptance against the INSTALLED pack. Probe 1 asks a fresh headless session for its yct skill inventory and fails if any of the five explicit-only workflow skills appears (their `allow_implicit_invocation: false` policy must keep them out of ambient context). Probe 2 invokes `$yct-aa` with a nonce, locates the probe session's rollout JSONL by that nonce, and greps it for a marker line derived from the installed `~/.agents/skills/yct-aa/SKILL.md` (longest quote-free body line — verified unique across injectable instruction surfaces) — acceptance is session-file ground truth, never model self-report. Probes pass `-c 'mcp_servers={}'` because MCP startup once hung a headless probe for 19 minutes, and run from a neutral temp directory: with cwd inside the pack repo itself, the repo's same-named skill source directories (`.agents/skills/yct-aa` etc.) collide with the installed skills and `$yct-aa` silently fails to inject (observed 2026-08-18 on the same CLI 0.147.0 that injects correctly from a neutral cwd). Requires the codex CLI and spends real tokens (~25k/probe); run on deployment, not on every edit.
- tests/verify_pack.sh: four-twin shared-section sync gate — the Continue-by-default section must be byte-identical across `yct-aa`/`yct-risk` on both platforms; drift now fails the pack instead of relying on release-day ad-hoc hashing (manually re-done in v4.8 and v4.14).
- docs/NOTES.md: added the `-c 'mcp_servers={}'` headless-probe tip and the verify_deploy.sh pointer to the Codex deployment model section.

## v4.14

Lane-wave parallelism and deployment-model corrections, derived from full JSONL forensics of the first post-v4.11 successor session (`rollout-2026-08-15T20-04-47-01a0054f...jsonl`, 13.1 h, 134.7M tokens, 9 compactions, 146 spawns, 293 waits, 2 interrupts). The session validated the v4.11–v4.13 line: all 9 post-compaction state notes named yct-aa and re-read its SKILL (0/14 in the pre-fix thread), interrupts fell 22 -> 2, short waits fell from 63% to 35% of the mix after the wait-sizing bullet entered via re-read, the three-strategy cap correctly froze Stage 3 at the fourth independent test-contract defect instead of buying a blind fourth attempt, and the SHA-anchored handoff chain closed across two successor sessions. Its residual defects drive this release.

- All four `yct-aa`/`yct-risk` skills, Continue-by-default section: serial is likewise the exception for read-only work — at each stage/batch start enumerate the independent read-only lanes (MECE) and launch them as ONE wave alongside the serial writer chain; lanes must not overlap, writers stay single-owner, and needing the user to demand more SubAgents is a routing defect (observed: four escalating user prompts, after which the session found 32 legitimately independent spawns in a single hour that had been sitting unlaunched behind a serial stage chain).
- All four `yct-aa`/`yct-risk` skills, Continue-by-default section: a round does not end while any SubAgent is in flight or a batch receipt is unclosed — answer an interposed user question, then resume the harvest-and-advance loop in the same round; never end on a promise tail ("will start / about to / currently running"), because orchestration halts when the turn ends and in-flight work sits unharvested until the user prods. Legal endings: all agents harvested, a true hard stop, a named user-only decision, or a delivered handoff; each stage/wave closure emits a <=3-line milestone receipt (stage — in-flight — next action), contractual rather than optional commentary. (Drafted only into the `.agents` yct-aa twin at first; the v4.15 shared-section gate exposed the drift and the rule was synced to all four twins before release.)
- docs/NOTES.md: Codex deployment model recorded — a session pins its instruction snapshot at start; disk edits and installs never reach a running session (v4.13-only AGENTS.md strings: 0 hits across a 13 h session spanning the install). Erratum to the v4.11 entry: "AGENTS.md is the only carrier re-injected from disk every turn" is wrong for Codex — the §14 pointer works because the snapshot survives compaction, not because the file is re-read from disk; pack updates reach new sessions only, so restart long-running sessions after installing.
- docs/NOTES.md: Codex skill-visibility model corrected by live `codex exec` probes (erratum to the same-day draft that claimed `~/.codex/skills` was the only root): native discovery scans both `~/.codex/skills` and `~/.agents/skills` (a probe skill present only under `~/.agents/skills` was listed), deduping by canonical directory. The five yct workflow skills were never lost by discovery — their `agents/openai.yaml` sets `policy.allow_implicit_invocation: false`, which by official semantics keeps a skill out of the ambient inventory while explicit `$yct-…` invocation still injects it (verified: `$yct-aa` injected the v4.14 SKILL text; marker matched in the probe session's JSONL, not model self-report). The 2026-08-15/16 operator symlinks under `~/.codex/skills` are redundant but harmless. `rg --files` without `-L` does not traverse symlinked directories — the source of one false "no independent yct-aa SKILL available" compaction note.
- Observation items, single occurrence, no rule change yet: 58 residual 30 s waits during multi-agent harvest bursts; the v4.9 ACCEPT-triggered handoff again failed to fire under operator continue-pressure even with the rule text demonstrably in context (ACCEPT at compaction 2 of an eventual 9, handoff only on operator request) — the v4.13 two-stage compaction gate is the structural answer and awaits its first live session.

## v4.13

Compaction-durability fixes, derived from full JSONL forensics of the parent Codex thread (`~/.codex/sessions/2026/08/14/rollout-...01a000ea...jsonl`, 20.3 h, 14 compactions at ~50-minute intervals, 172.3M tokens, 151 spawns, 365 waits, 22 interrupts): the AGENTS.md compaction-reread pointer fired reliably (8 of 14 compactions produced a SKILL re-read within 90 s) but every re-read targeted an analysis skill (`yct-ca` ×7, `yct-cr` ×1) — the active workflow skill `yct-aa` was never re-read after session start, so every SKILL-borne gate was absent for ~19 of the thread's 20 hours; the last 4 compactions produced no re-read at all, and the v4.9 ACCEPT-triggered handoff gate never fired because the ACCEPT gates themselves churned (24 plan-checker spawns legally resetting the §12 review budget through plan mutation — 4 plan variants of the same delta).

- AGENTS.md §14 reread retarget: the re-read target is the `$`-invoked workflow mode, explicitly never an analysis/routing skill such as yct-ca (the mistarget root cause: always-injected analysis-skill routing text survives compaction better than the workflow skill it shadows); each compaction state note must name the active mode and its SKILL path. Install paths deliberately dropped from the rule — forensics showed path-finding was never the failure, target identity was.
- AGENTS.md §14 two-stage compaction gate (supplements, does not replace, the v4.9 ACCEPT-triggered handoff): the first compaction emits or refreshes the session-handoff file (non-blocking, so a fresh-session restart is always one file away); a second compaction closes the current batch, delivers the handoff, and stops for a fresh session unless the user explicitly waives it. Compaction count is the trigger because it is the event the session itself observes and the event that destroys rule carriage — the same forensics showed even AGENTS.md instruction-following degrading past hour 17.
- AGENTS.md §12 review-budget loophole closed: plan mutation does not reset the one-pass-plus-one-recheck budget; a third gate spawn on the same decision first requires fixing the plan instability (re-partition or shrink the batch) instead of buying another review.
- All four `yct-aa`/`yct-risk` skills, idle-wait section: size the FIRST wait to the role's typical duration (adjudicators/planners run minutes — 227 of the thread's 365 waits were ≤60 s, each return a paid top-tier parent turn); batch status via one agent-list poll instead of stacked short waits.
- Byte budget: +470B of new §12/§14 contract paid by 23 byte-swaps across §1/§5/§6/§7/§8/§9/§10/§11/§12/§13/§14/§15 (enumeration and redundant-phrase trims, no rule semantics removed); 26,372 -> 26,396 bytes, budget 26,400.
- Positive validation recorded: the same forensics confirmed tier-by-criticality held (adjudication on sol, implementation on terra, mechanical on spark), production writes stayed frozen, and the handoff-document protocol worked end-to-end in the successor session (doc consumed in 20 s, stale plan-check verdicts discarded, fresh gate spawned, first batch entered within 12 minutes).

## v4.12

Idle-wait kill discipline, derived from hour 5–6.5 of the same L3 production-replay Codex session (124M tokens in, second compaction). The session now correctly enforced the two-idle-wait kill rule — and its mechanical application exposed the rule's blind spot: a mid-flight write-capable worker was interrupted twice (partial writes needing freeze-and-reconcile passes), plan-checkers were killed and respawned three times (plan_check -> recheck -> one_shot_gate), and an ACCEPT was extracted by interrupting an adjudicator and demanding its verdict — kill-respawn churn across ~18 spawns while production stayed safely frozen.

- AGENTS.md §8 byte-swap: "Kill an agent after two idle waits and re-scope its remainder" -> "After two idle waits, check progress evidence before killing; writers are frozen and reconciled, not blind-killed" (offset by trimming the §15 pyramid-principle sentence already implied by §2 conclusion-first and the §13 "comparable repo patterns" list item; 26,376 -> 26,372 bytes, budget 26,400).
- All four `yct-aa`/`yct-risk` skills: new "Idle-wait and kill discipline" section — an idle WAIT is not an idle WORKER; two idle waits trigger a progress check (target-file mtime/diff growth, artifact freshness, receipt heartbeat); a demonstrably progressing worker gets a longer bounded wait and only a stalled one is killed and re-scoped; write-capable workers are never blind-killed — a writer repeatedly outliving its wait budget means the packet was oversized, so re-slice the scope instead of re-issuing it through a kill-respawn cycle; a verdict extracted from an interrupted adjudicator is not a gate pass.
- Confirmed covered, no new rules: the session's self-reported detours (V5 consumed on a partial root cause; created_at-based PIT model replaced by valid_from_at; successor-index misdiagnosis withdrawn via a cheap real-PostgreSQL probe with no production consumption; migration-174 gate-by-gate patching) all reduce to incomplete conjunctive layer-chain enumeration — already governed by the v4.11 attempt-economy rule plus the existing conjunctive-gate strategy-zero rule. Compaction rule loss is the v4.11 AGENTS.md re-read pointer; instructions load at session start, so the observed session never saw v4.11 — validation requires a fresh session.

## v4.11

Single-consumption gate economy and compaction-durable rule carriage, derived from an observed L3 production-replay Codex session (4.5 h, multiple compactions, 89.7M tokens in) that consumed two one-shot production authorizations (V4, V5) falsifying successive partial root causes (interpreter -> clock -> connection -> storage authority), and that lost every SKILL-borne gate after context compaction — the session itself reported "当前会话没有独立的 yct-aa 技能包" and fell back to bare AGENTS.md flow.

- Added a single-consumption attempt economy rule to all four `yct-aa`/`yct-risk` skills (twice-observed root cause: V4 consumed after the clock fix, V5 consumed after the connection fix, each falsifying a partial root cause promoted to a complete one): before consuming a one-shot/production authorization, enumerate the complete conjunctive layer chain (runtime identity, connection/transaction, clock/anchors, storage authority vs. overwritable projection, upstream point-in-time reconstructability, error classification) and falsify each layer with the cheapest local check first — the gated attempt is the most expensive falsifier and may only buy what no local check can prove; the execution packet states predicted failure modes, an unpredicted-layer failure triggers a strategy-zero full-surface audit (`deep-investigator-agent`) before the next attempt, and a second consecutive unpredicted failure hard-blocks; a fix that turns one layer green is necessary, not sufficient — never promote it to complete root cause.
- AGENTS.md §14: skill text does not survive context compaction — after compaction, re-read the active shortcut's installed `SKILL.md` before continuing. AGENTS.md is the only carrier re-injected from disk every turn on both platforms, so the durable pointer lives there. Byte-swap to stay within the 26,400 budget: removed the "tool-neutral and compact" meta note, the "accepted by Claude and Codex" intro sentence, and the duplicate "methods as ceremony" clause (26,397 -> 26,376 bytes).
- Not new rules — the observed session violated gates that already exist but ran without them after compaction: idle-wait loops (AGENTS.md §8 two-idle-wait kill + v4.10 continue-by-default), rolling a new phase onto a compacted thread past plan ACCEPT (v4.9 fresh-session handoff), a 5,300-line plan embedding complete wrapper programs (v4.9 plan-artifact path+hash budget), and top-tier inline mechanical hash-reconstruction chains (v4.9 inline-parent-turn ledger + tier-by-criticality). The compaction-reread pointer above is what makes these gates reach a long-running session again.

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
