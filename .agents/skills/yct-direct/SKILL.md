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
- More files or higher risk do not themselves change this no-agent mode. Continue authorized work in the parent with the required risk checks. If safe execution needs independent agent verification that this mode prohibits, complete only the preparation and independent authorized work that do not depend on that verification, report the specific requirement and its source, and do not execute a dependent action before a required pre-execution check.
