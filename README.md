# Agent System Pack v4.7 YCT Routing and Methods

This package installs a merge-safe user-level agent system for Claude Code and Codex.

## Daily usage

Claude Code:

```text
/yct-aa <task>
/yct-fix <focused failure or small fix>
/yct-direct <tiny no-agent task>
/yct-risk <high-risk task>
/yct-review <review target>
```

Codex:

```text
$yct-aa <task>
$yct-fix <focused failure or small fix>
$yct-direct <tiny no-agent task>
$yct-risk <high-risk task>
$yct-review <review target>
```

Use `yct-aa` for normal non-trivial engineering work. Use `yct-fix` only for a small bounded fix, `yct-risk` for sensitive or irreversible work, `yct-review` for review-only work, and `yct-direct` when you explicitly do not want subagents. Shortcut skills are explicit-only and do not auto-trigger from ordinary prompts.

## What is included

```text
AGENTS.md                    shared Claude/Codex engineering contract
CLAUDE.md                    Claude-specific orchestration layer
docs/METHODS.md              detailed task-selected method contracts
docs/METHOD_EVAL.md          v4.6/v4.7 qualitative comparison and iteration evidence
install.sh                   macOS/Linux user-level merge installer
.claude/agents/*.md          Claude native subagents
.claude/rules/*.md           Claude-only routing, method mapping, and maintenance rules
.claude/skills/yct-*/        Claude shortcut skills
.codex/agents/*.toml         Codex native subagents
.codex/config.toml           Codex agent defaults
.agents/skills/yct-*/        Codex shortcut skills
```

## Install

Preview first:

```bash
./install.sh --dry-run
```

Install both Claude and Codex user-level files:

```bash
./install.sh
```

Install only one side:

```bash
./install.sh --claude-only
./install.sh --codex-only
```

Default targets:

```text
Claude agents/rules/skills -> ~/.claude/
Codex agents/config/AGENTS -> ~/.codex/
Codex user skills          -> ~/.agents/skills/
Backups                    -> ~/.yct-agent-backups/<timestamp>/
```

The installer also places the detailed method catalog at `~/.claude/METHODS.yct.md` and `~/.codex/METHODS.yct.md` so user-level agents do not depend on the package checkout remaining available.

## Merge policy

The installer is append/merge oriented:

- Existing unrelated skills are not deleted.
- New shortcut skills are prefixed with `yct-`.
- Existing unrelated non-YCT agents/rules are preserved.
- Same-path YCT files are backed up, then updated; different-path duplicate agent identities require explicit `--replace-conflicts`.
- Symlinked write targets are rejected instead of followed.
- Existing `~/.claude/CLAUDE.md` is merged with a YCT marker block.
- Existing `~/.codex/AGENTS.md` or `AGENTS.override.md` is merged with a YCT marker block.
- Existing Codex `[agents]` values are preserved; missing YCT role registrations are appended and unsafe depth/thread values produce warnings. YCT defaults are also saved as `config.yct.example.toml`.
- Canonical `[agents]` and `[agents."role"]` tables are accepted with or without leading indentation. Inline, dotted, quoted, array-table, or internally spaced forms such as `[ agents ]` are rejected before writes because the shell merger cannot extend them safely.

Different-path agents declaring the same identity stop installation by default. Review the conflict, then use `./install.sh --replace-conflicts` only when you intentionally want the YCT definition to replace it after backup. Same-path YCT assets still update after backup.

## Method selection

v4.7 selects engineering methods from task signals instead of applying a full process ritual to every request. The compact trigger matrix lives in `AGENTS.md`; detailed contracts, output fields, examples, and anti-patterns live in `docs/METHODS.md`.

Examples:

- unknown root cause → Hypothesis–Falsification;
- L3/L4 design → First Principles, MECE, ledgers, Pre-mortem/FMEA-lite;
- auth/data boundary → Trust Boundary and Abuse Cases;
- schema/API migration → Expand–Migrate–Contract;
- implementation/review → Bidirectional Traceability and Adjacency Scan;
- recurring route/rule defect → Double-loop Learning.

Selected methods are written into the subagent packet with required outputs. Merely naming a method without evidence does not satisfy the contract.

## Claude routing note

Claude uses `focused-fixer-agent` for small focused fixes. `spark-agent` is retained only as a legacy compatibility worker for packets that explicitly request it.

Claude model routing uses Haiku for cheap recording/fallback work, Sonnet for implementation and normal engineering work, Opus for planning/security/semantic review/independent verification, and optional Fable overrides for justified L4 planning or plan challenge. The Sonnet executor remains deliberate even in an approved L3 pipeline; stronger models surround it with plan and verification gates.

## Codex routing note

Codex requires explicit subagent authorization. Use `$yct-aa ...` to authorize Codex to choose and spawn suitable agents according to `AGENTS.md`.

Codex uses GPT-5.6 for demanding implementation/planning/review, GPT-5.6 Terra for fast read-heavy and mechanical work, and `focused-fixer-agent` as the portable focused-fix default. `spark-agent` is optional because GPT-5.3-Codex-Spark is a ChatGPT Pro research-preview model; use it only when availability is known and latency is the priority.


## Codex instruction size

This installer sets or recommends `project_doc_max_bytes = 65536` to leave room when YCT guidance is merged with existing global instructions. Existing config is merged, not replaced.
