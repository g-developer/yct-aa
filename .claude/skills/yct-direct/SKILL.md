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

More files or higher risk do not themselves change this no-agent mode. Continue authorized work in the parent with the required risk checks. If safe execution needs independent agent verification that this mode prohibits, complete only the preparation and independent authorized work that do not depend on that verification, report the specific requirement and its source, and do not execute a dependent action before a required pre-execution check.
