---
name: yct-direct
description: No-agent mode for tiny, low-risk, reversible tasks. Use when the user wants a direct answer or direct implementation without subagent orchestration.
argument-hint: [task]
disable-model-invocation: true
---

# YCT Direct Mode

Task:
$ARGUMENTS

Handle directly in the main thread.

Rules:

- Do not spawn subagents. Direct Mode is not authorization to switch into another mode.
- Keep the change minimal.
- Use existing project patterns.
- Run targeted validation if code changes.
- Report only conclusion, change summary, verification, and risk.

If the task becomes multi-module, risky, ambiguous, or requires independent agent verification, continue only with safe main-thread analysis. Stop before unsafe execution and ask the user to invoke `/yct-aa` or `/yct-risk` explicitly.
