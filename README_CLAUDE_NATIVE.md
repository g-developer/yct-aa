# Claude Native Layer v4.7

This pack keeps `AGENTS.md` as the cross-tool contract and upgrades the Claude side to use Claude Code native concepts:

- `CLAUDE.md` imports `AGENTS.md` and adds only Claude-specific orchestration.
- `.claude/rules/` stores Claude-only model routing, method-to-role mapping, subagent orchestration, and instruction-maintenance rules.
- `.claude/agents/*.md` uses Claude frontmatter with `model`, `effort`, `maxTurns`, permission modes, and tool allowlists. It does not force `background`; Claude chooses foreground/background from dependency order.
- Every Claude role stops new work at a role-specific soft budget before `maxTurns` and returns a complete result or structured batch receipt. Agent Teams and `SendMessage` are optional; recovery capability is checked before use.
- Write-capable agents are Sonnet by default; hard planning/review agents use Opus; cheap/status agents use Haiku.
- Fable is an optional L4 planner/plan-checker invocation override. Opus remains the portable high-capability default.
- `.claude/rules/method-orchestration.md` maps the task-selected contracts in `docs/METHODS.md` to Claude roles without duplicating their definitions.

User-level install:

```bash
./install.sh --claude-only
```

Repo-level installation is still possible by copying `AGENTS.md`, `CLAUDE.md`, and `.claude/` into a repository, but the default installer targets `~/.claude`.

If your Claude Code environment does not support a model alias or effort level, change that agent to `model: inherit` or to a permitted full model ID.

For browser MCP tools, edit `.claude/agents/browser-agent.md` and add the exact local MCP tool/server names. Parent-session availability alone does not prove that the child profile can call them; preflight the child allowlist before routing browser work.
