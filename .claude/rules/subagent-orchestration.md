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
