---
paths:
  - "AGENTS.md"
  - "CLAUDE.md"
  - ".claude/**/*.md"
  - ".codex/**/*.toml"
---

# Instruction System Maintenance

This rule applies when editing AGENTS.md, CLAUDE.md, Claude agents/rules, or Codex agents.

## Boundaries

- `AGENTS.md`: cross-tool engineering contract and durable repo rules.
- `CLAUDE.md`: Claude-specific orchestration and concise routing policy.
- `.claude/rules/*.md`: Claude-specific topic or path rules.
- `.claude/agents/*.md`: one agent's role, tools, model, effort, and output contract.
- `.codex/agents/*.toml`: Codex-native equivalent role contracts.
- `docs/METHODS.md`: single detailed owner for cross-platform engineering method contracts.
- Skills/commands: repeatable procedures that should load on demand.

## Review triggers

Use `semantic-review-agent` before finalizing non-trivial edits when:

- a rule is duplicated in multiple places
- an agent description becomes vague or overlapping
- platform-specific details leak into `AGENTS.md`
- an agent prompt grows without a clear payoff
- a new write-capable agent is added
- Claude/Codex parity changes
- method triggers, role mappings, or required method outputs change

## Quality gate

Before finalizing instruction changes:

- every rule has one shared owner or one owner per platform; shortcut skills contain only mode-specific deltas
- every agent has clear use / do-not-use / output contract
- every write-capable agent has a verification handoff rule
- every agent declares one delivery policy and soft work budget
- batchable roles return the shared receipt; one-shot roles reroute instead of accumulating hidden remainder
- partial review cannot emit a final acceptance verdict, and changed-state delivery failures freeze overlapping writers
- platform recovery rules capability-check continuation instead of assuming Agent Teams, `SendMessage`, or hidden context
- no unsupported tool/model names were introduced without a note
- instructions are concrete enough to verify
- paired Codex/Claude roles preserve method-family parity without duplicating detailed definitions
- method selection is triggered by task signals and does not become mandatory ceremony
- delete rather than duplicate when possible
