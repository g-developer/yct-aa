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

## Token economy (2026-07-13, from etf-skill session double-loop review)

- A completion notification whose final message is a progress note (or empty) means the
  child hit its turn budget mid-work. Resume it once via `SendMessage`（复用同一实例，缓存
  命中其已读上下文）with a one-line demand for the final deliverable — never respawn a
  fresh agent for the same packet, and never accept a process log as a deliverable.
- Do not paste large file bodies into packets; pass paths/line anchors — read-only agents
  can Read them, and packet bloat is paid on every resume.
- Expect deliverables to be lean (tables + file:line anchors). If a child returns pasted
  file bodies, treat it as a role-contract defect and report it, not as normal output.
- Long-running review loops (multi-round plan challenge) should stay on ONE agent instance
  across rounds; each round sends only the delta packet.

Long goals (many-item contracts, e.g. GDR-01..24):

- Slice into bounded packets of 3-5 items; never hand one agent the whole span.
- Reuse the SAME agent instance for adjacent slices (continuation reuses its
  cached context); do not respawn per slice.
- Maintain evidence/trace matrices incrementally - append delta rows per slice,
  never rebuild the full matrix from scratch.
- Do not re-read unchanged files across slices; cite prior slice anchors
  (file:line) instead.
