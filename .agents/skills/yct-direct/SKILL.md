---
name: yct-direct
description: No-agent mode for small low-risk tasks. Explicitly invoke with $yct-direct when the task must stay in the main Codex thread without subagent delegation.
---

# YCT Direct Mode

Task:
$ARGUMENTS

Handle directly.

Rules:

- Do not spawn subagents. Direct Mode is not authorization to switch into another mode.
- Keep the diff minimal.
- Run targeted verification when code changes.
- If the task becomes multi-file, ambiguous, risky, or requires independent agent verification, continue only with safe main-thread analysis. Stop before unsafe execution and ask the user to invoke `$yct-aa` or `$yct-risk` explicitly.
