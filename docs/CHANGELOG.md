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
