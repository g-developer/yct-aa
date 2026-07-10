@AGENTS.md

# Claude Code Operating Layer

This file is Claude-specific. Keep durable cross-tool engineering rules in `AGENTS.md`. Keep path-specific or Claude-only details in `.claude/rules/`. Keep role instructions in `.claude/agents/*.md`.

## Priority

1. Direct user instruction in the current session.
2. `AGENTS.md` shared engineering contract.
3. This `CLAUDE.md` Claude orchestration layer.
4. `.claude/rules/*.md` path or topic rules.
5. `.claude/agents/*.md` role contracts for spawned subagents.

When these conflict, obey the more specific instruction unless it weakens safety, scope, or verification.

## Claude model policy

Use model aliases by default so Claude Code maps to the recommended current model for the provider.

- `fable`: highest capability. For L4 planning or adversarial plan review, the parent may override `planner-agent` or `plan-checker` to Fable when the alias is available and cost is justified; otherwise use Opus.
- `opus`: complex agentic coding, planning, adversarial review, architecture, security, and independent verification.
- `sonnet`: default for implementation, test running, browser work, ordinary research, and engineering review.
- `haiku`: cheap/fast read-only or low-risk tasks: mechanical lookup, simple recording, small docs, fallback inspection.
- `inherit`: use when the subagent should follow the parent session's chosen model.

Use `effort` deliberately:

- `low`: trivial or latency-sensitive work.
- `medium`: bounded work where cost matters.
- `high`: default for serious coding.
- `xhigh`: hard reasoning, security, architecture, adversarial review.
- `max`: rare; use only when explicitly justified.

Do not set `CLAUDE_CODE_SUBAGENT_MODEL` globally unless intentionally overriding all subagent model choices.

## Claude workflow

Permitted stage order; include only stages selected by task criticality and evidence:

```text
explorer-agent -> planner-agent -> plan-checker -> executor-agent/focused-fixer-agent/batch-agent -> verify-agent/verify-runner-agent -> code-reviewer/security-reviewer when relevant
```

Task routing:

- L0 trivial: work directly. Do not use subagents for L0 tasks.
- L1 focused: work directly or use `focused-fixer-agent` when failure output, target files, and command are explicit.
- L2 multi-file/unfamiliar: use `explorer-agent` before editing when the impact surface is unclear.
- L3 risky: use `planner-agent`, `plan-checker`, scoped implementation, and independent verification.
- L4 strategic/irreversible: plan and review only until the user explicitly approves execution.

For approved L3 implementation, keep `executor-agent` on Sonnet and place stronger-model checks around it: Opus planning, plan challenge, security review, and independent verification. This is a deliberate pipeline, not an implicit promise to upgrade the write-capable agent.

## Subagent orchestration

- Select methods from the `AGENTS.md` task-signal matrix before selecting roles. Detailed contracts live in `docs/METHODS.md` or installed `METHODS.yct.md`; `.claude/rules/method-orchestration.md` owns Claude method-to-role mapping.
- Pass selected method names and required outputs in the clean-context packet. Do not invoke methods as empty headings or a full-chain ritual.
- Spawn subagents only with a self-contained clean-context packet.
- The parent owns final judgment and user communication.
- Subagents are workers, not decision owners.
- Do not delegate vague work.
- Do not let write-capable agents edit overlapping files concurrently.
- Use worktrees or sequential execution for parallel write-capable work.
- For noisy independent read-only research/exploration/review, concurrency is useful. Do not force background execution in agent frontmatter; let Claude choose foreground or background based on dependency order.
- For implementation, require a verification handoff packet before finalizing.

## Claude agent route table

| Need | Agent |
|---|---|
| Map unfamiliar code paths | `explorer-agent` |
| Plan risky or ambiguous work | `planner-agent` |
| Attack a plan before implementation | `plan-checker` |
| Implement approved scoped work | `executor-agent` |
| One small failure-driven edit | `focused-fixer-agent` |
| Mechanical repeated edit | `batch-agent` |
| Static independent verification | `verify-agent` |
| Run tests/build/lint/typecheck | `verify-runner-agent` |
| Review diff for engineering defects | `code-reviewer-agent` |
| Review security/data-boundary risk | `security-reviewer-agent` |
| External/version/source research | `research-agent` |
| Browser/UI/social evidence after tool preflight | `browser-agent` |
| Write durable docs | `docs-agent` |
| Record confirmed status/decision deltas | `alignment-recorder-agent` |
| Review rule/prompt quality | `semantic-review-agent` |
| Small read-only fallback | `general-agent` |

## Browser and external sources

- Prefer official docs, repo source, release notes, changelogs, and maintainer discussions.
- Treat X.com/social posts as discovery leads, not authority.
- `browser-agent` requires browser tooling exposed to the child profile. Checking only the parent session is insufficient: preflight the agent's configured `tools` names or a browser CLI callable through its allowed `Bash`. The portable template intentionally omits unknown MCP names, so add the exact local MCP tool names before MCP-only use. Otherwise use `research-agent` for public pages or report the missing capability. Keep browser work read-only in this pack.

## Context and compaction

- Keep this file concise. Move path-specific details to `.claude/rules/`.
- Move repeatable procedures to skills or commands.
- After compaction, preserve architecture decisions, modified files, verification status, blockers, and rollback notes.

## Output

Use Chinese for user-facing explanations. Final responses should start with the conclusion, then provide evidence, changed files, verification, and remaining risk. Do not expose private chain-of-thought.

## Claude Shortcut Layer

Use these shortcuts to reduce repeated long prompts:

- `/yct-aa <task>` or `yct-aa: <task>`: auto-agent routing. Classify the task, choose subagents only when useful, require clean-context packets and independent verification.
- `/yct-direct <task>` or `yct-direct: <task>`: no-agent mode for tiny low-risk tasks.
- `/yct-risk <task>` or `yct-risk: <task>`: L3/L4 flow with planning, adversarial review, verification, and security review when relevant.
- `/yct-review <target>` or `yct-review: <target>`: review-only mode. Do not implement unless asked.
- `/yct-fix <failure-or-task>` or `yct-fix: <failure-or-task>`: focused fix mode for one failing test, stack trace, small bug, or localized cleanup.

Do not force subagents for small reversible tasks. Do use subagents for noisy exploration, risky work, independent verification, or parallel review.
