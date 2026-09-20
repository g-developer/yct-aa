# Claude Subagent Orchestration

`AGENTS.md` owns the shared clean-context packet, parent duties, write handoff, and verification contract. This file contains only Claude-specific behavior.

Method selection and Claude role mapping are owned by `.claude/rules/method-orchestration.md`; detailed contracts remain in `docs/METHODS.md` or the installed `METHODS.yct.md`.

## Claude rules

- Use custom YCT agents when their model/tool/permission contract matters; do not substitute built-in Explore for `explorer-agent` inside `/yct-aa`.
- Do not force `background` in agent frontmatter. Let Claude choose based on whether the parent needs the result before continuing.
- Parallelize independent work only. Writers need disjoint file ownership or isolated worktrees; dependent planning, implementation, and verification remain sequential.
- Read-only custom agents use `permissionMode: plan` where supported. Write-capable agents receive only the tools needed for their role.
- Omit `Agent` from worker tool lists so workers cannot recursively orchestrate.
- Code-touching roles list `mcp__serena__find_symbol`, `mcp__serena__find_referencing_symbols`, `mcp__serena__get_symbols_overview`, and `mcp__codegraph__codegraph_explore` in `tools`, so an explicit tool list does not silently drop the indexes. A write packet carries the parent's `PRIOR_ART` candidates or names `yct-ca prior <keyword>...` with the absolute worktree as the worker's first step; the worker's handoff returns `PRIOR_ART` or `NEW_IMPLEMENTATION`.
- Use `isolation: worktree` only when the packet explicitly needs isolated writes and the repository state supports it.
- The parent must preflight browser tools before spawning `browser-agent`.
- After delegated source edits, the parent inspects the actual diff. Use
  `verify-agent` for non-trivial, risky, or uncertain wiring; a localized
  obvious edit may use parent inspection plus its real targeted check. Add
  `verify-runner-agent` only when isolated command execution is useful.

If the local Claude Code version or organization policy does not support a configured model, effort, or permission field, use the documented inherited fallback and report the downgrade instead of silently claiming the intended route ran.

## Delivery recovery and token economy

- Treat an empty, progress-only, tool-log-only, or malformed child result as delivery failure, not completion. Preserve the child ID, packet, and known changed-state evidence.
- Continue the same child once only when the active runtime exposes and has confirmed a continuation handle. Agent Teams and `SendMessage` are optional capabilities, not assumptions. If continuation is unavailable, create a new bounded packet containing only the prior result and evidence delta, or return `BLOCKED` when changed state cannot be reconciled safely.
- Treat a role's expected size as a scope estimate. Let a bounded remaining check finish within the hard runtime limit; otherwise collect the concrete remainder and resize the packet. Do not create batches merely because the estimate was exceeded.
- For a write-capable child with invalid delivery, pause overlapping writers, inspect the actual worktree/artifacts, and reconstruct the handoff before any further writes.
- Do not paste large file bodies into packets; pass paths/line anchors — read-only agents
  can Read them, and packet bloat is paid on every resume.
- Expect deliverables to be lean (tables + file:line anchors). If a child returns pasted
  file bodies, treat it as a role-contract defect and report it, not as normal output.
- A second review round requires new evidence or a named unresolved finding and is limited to that delta. When such a round is genuinely needed, reuse one agent instance if a confirmed continuation handle exists. Do not create a long-running review loop by default.

For genuinely itemized long goals, slice only when one worker cannot safely
close the whole target. Carry the concise completed set, remainder, and evidence
delta; derive every item from the current authoritative input. Do not maintain
a trace matrix unless the user's acceptance itself is itemized. Close the prior
remainder before adding scope, and do not re-read unchanged files without new
or contradictory evidence.
