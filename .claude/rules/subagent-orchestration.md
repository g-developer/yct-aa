# Claude Subagent Orchestration

`AGENTS.md` owns the shared clean-context packet, parent duties, write handoff, and verification contract. This file contains only Claude-specific behavior.

Method selection and Claude role mapping are owned by `.claude/rules/method-orchestration.md`; detailed contracts remain in `docs/METHODS.md` or the installed `METHODS.yct.md`.

## Claude rules

- Use custom YCT agents when their model/tool/permission contract matters; do not substitute built-in Explore for `explorer-agent` inside `/yct-aa`.
- Do not force `background` in agent frontmatter. Let Claude choose based on whether the parent needs the result before continuing.
- Parallelize only independent read-only work. Chain dependent planning, implementation, and verification stages.
- Read-only custom agents use `permissionMode: plan` where supported. Write-capable agents receive only the tools needed for their role.
- Omit `Agent` from worker tool lists so workers cannot recursively orchestrate.
- Use `isolation: worktree` only when the packet explicitly needs isolated writes and the repository state supports it.
- The parent must preflight browser tools before spawning `browser-agent`.
- After delegated source edits, `verify-agent` performs independent static acceptance. Add `verify-runner-agent` for commands that create caches, build outputs, coverage, or other verification artifacts.

If the local Claude Code version or organization policy does not support a configured model, effort, or permission field, use the documented inherited fallback and report the downgrade instead of silently claiming the intended route ran.

## Delivery recovery and token economy

- Treat an empty, progress-only, tool-log-only, or malformed child result as delivery failure, not completion. Preserve the child ID, packet, receipt ledger, and any known changed-state evidence.
- Continue the same child once only when the active runtime exposes and has confirmed a continuation handle. Agent Teams and `SendMessage` are optional capabilities, not assumptions. If continuation is unavailable, create a new bounded packet containing the previous receipt and evidence ledger, or return `BLOCKED` when changed state cannot be reconciled safely.
- Do not ask a child that reached its soft work budget to continue exploration. Ask only for the required receipt/finalization, then apply the two-consecutive-remainder stop rule from `AGENTS.md`.
- For a write-capable child with invalid delivery, pause overlapping writers, inspect the actual worktree/artifacts, and reconstruct the handoff before any further writes.
- Do not paste large file bodies into packets; pass paths/line anchors — read-only agents
  can Read them, and packet bloat is paid on every resume.
- Expect deliverables to be lean (tables + file:line anchors). If a child returns pasted
  file bodies, treat it as a role-contract defect and report it, not as normal output.
- Long-running review loops (multi-round plan challenge) should stay on ONE agent instance
  across rounds; each round sends only the delta packet.

Long goals (many-item contracts, e.g. GDR-01..24):

- Slice into bounded packets of 3-5 items, or 2-3 for L3/L4/high-uncertainty work; never hand one agent the whole span.
- Reuse the same agent instance for adjacent slices only when a confirmed continuation handle exists. Otherwise start a fresh bounded packet with the prior receipt and ledger.
- Require every slice to close the previous remainder before accepting new item IDs. A second consecutive carry-over becomes `BLOCKED` or a separate evidence task.
- Maintain evidence/trace matrices incrementally - append delta rows per slice,
  never rebuild the full matrix from scratch.
- Do not re-read unchanged files across slices; cite prior slice anchors
  (file:line) instead.
