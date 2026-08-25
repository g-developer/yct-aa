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

Use at most one `semantic-review-agent` pass only when a current unresolved semantic conflict cannot be closed from the parent thread's source and behavior evidence, for example:

- a rule is duplicated in multiple places
- an agent description becomes vague or overlapping
- platform-specific details leak into `AGENTS.md`
- an agent prompt grows without a clear payoff
- a new write-capable agent is added
- Claude/Codex behavior parity changes and the correct owner is ambiguous
- method triggers, role mappings, or required method outputs change

Do not spawn it for mechanical twin synchronization, wording-only edits, or a conflict whose owner and correction are already proven. A review must name the decision it will close; after that decision closes, move to real behavior verification.

## Final check

Before finalizing, check only what can change behavior:

- each durable rule has one shared or platform-specific owner, without a second
  shortcut copy pretending to be authoritative;
- affected roles have a clear use boundary, output, and safe write handoff;
- no fixed agent/review chain, ledger, prompt-string test, or unsupported
  tool/model was introduced;
- package structure still validates and the observed failure class is replayed
  through the installed real entrypoint when feasible.

Delete duplication instead of adding another instruction layer.
