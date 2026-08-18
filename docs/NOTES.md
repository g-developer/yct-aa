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

## Codex deployment model (2026-08-16)

- A Codex session pins its instruction snapshot (merged AGENTS.md plus the
  skill inventory) at session start; neither disk edits nor `install.sh`
  reach a running session — v4.13-only AGENTS.md strings scored 0 hits in a
  13 h session that spanned the install. Deploying a pack update therefore
  requires restarting long-running sessions; only new sessions carry the
  new rules.
- Codex native skill discovery scans BOTH `~/.codex/skills` and
  `~/.agents/skills` (plus bundled plugin caches), deduping entries that
  resolve to the same canonical directory. Verified 2026-08-16 by live
  `codex exec` probes: a probe skill present only under `~/.agents/skills`
  appeared in a fresh inventory.
- The five yct workflow skills are intentionally absent from the ambient
  skill inventory: their `agents/openai.yaml` sets
  `policy.allow_implicit_invocation: false`, whose official semantics
  (`.system/skill-creator/references/openai_yaml.md`) hide a skill from
  default context while explicit `$yct-…` invocation still injects the full
  SKILL.md. Verified live: `$yct-aa` injected the v4.14 text (marker matched
  in the probe session's JSONL ground truth, not model self-report). An
  inventory probe that does not see them is expected behavior, not a
  deployment failure. The operator-created `~/.codex/skills` symlinks are
  redundant but harmless.
- Mid-session manual rediscovery with `rg --files` does NOT traverse
  symlinked directories unless `-L/--follow` is passed — such a search
  reports a false negative even when the symlink exists.
- Headless `codex exec` probes should disable MCP servers with
  `-c 'mcp_servers={}'`: one probe without it hung 19 minutes in MCP
  startup (process alive, zero TCP connections, no rollout file written).
- After `install.sh`, `tests/verify_deploy.sh` provides dynamic acceptance
  for the two runtime behaviors above: the ambient inventory must hide the
  five explicit-only workflow skills, and explicit `$yct-aa` must inject
  content matching the installed SKILL.md, checked against the probe
  session's rollout JSONL (ground truth), never the model's self-report.
  It spends real tokens (~25k/probe); run it when deployment must be
  proven at runtime, not on every edit.
