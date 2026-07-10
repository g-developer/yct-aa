# Notes

## What belongs in AGENTS.md

Put durable, repo-level, tool-neutral engineering rules in `AGENTS.md`:

- build/test conventions
- code quality standards
- clean-context contract
- verification matrix
- evidence ladder
- compact method-trigger matrix
- stop conditions
- multi-agent orchestration principles

## What belongs in platform rules

Put platform-specific behavior outside `AGENTS.md`:

- Claude auto-routing and model aliases: `CLAUDE.md`, `.claude/agents/*.md`
- Codex model/sandbox/thread settings: `.codex/config.toml`, `.codex/agents/*.toml`
- personal communication style: global/user rules
- long reusable workflows: skills or slash commands

Detailed cross-platform method definitions belong in `docs/METHODS.md`. Platform rules and agent files map those definitions to roles and required output fields; they must not fork the underlying method definitions.

## Current routing target

Claude and Codex should be capability-aligned, not mechanically file-aligned.

Maintain these boundaries:

- Claude and Codex both use a portable `focused-fixer-agent` for small focused fixes.
- Codex uses GPT-5.6 for demanding roles and GPT-5.6 Terra for fast portable roles.
- Codex Spark is optional and account-dependent; it is not the default focused-fix route.
- `spark-agent` on Claude is retained only for legacy explicit requests.
- Browser MCP tool names remain environment-specific and should be adjusted locally.
- Model aliases may need local account-specific adjustment.

See `docs/ROUTING.md` for precedence, model tiers, verification closure, and official sources.
