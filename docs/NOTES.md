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
- Exception, verified live (session 01a00836, 2026-08-17): explicit
  `$yct-…` re-invocation mid-session re-reads the CURRENT on-disk
  SKILL.md — a session opened on the v4.13 body received the v4.14 body
  (25,577B -> 26,133B in the same rollout JSONL) after `install.sh` plus
  re-invocation. SKILL-borne rule updates can therefore be hot-loaded
  into a running session by re-invoking the skill; only the merged
  AGENTS.md snapshot stays pinned until restart.
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
- Behavioral acceptance uses the actual installed skill, normal `codex exec`
  entrypoint, working directory, and authenticated command environment. A
  modified tool inventory or internal runner is diagnostic only; if normal
  startup is blocked, report that environment blocker instead of substituting
  a different invocation and calling it E2E.
- After `install.sh`, `tests/verify_deploy.sh` runs one live behavioral E2E
  through the installed `$yct-aa` and real `codex exec` entrypoint. It verifies
  observable ordered one-shot receipts and the accepted final outcome; it does
  not grade model prose or compare prompt/source/log strings. Run it from an
  authenticated shell when deployment behavior, rather than package shape,
  must be proven.
- Skill resolution is cwd-sensitive: with cwd inside the pack repo, the
  repo's own same-named skill source directories collide with the
  installed skills and `$yct-…` silently injects nothing (verified
  2026-08-18: identical probe failed from the repo cwd and passed from a
  neutral cwd on the same CLI 0.147.0). verify_deploy.sh therefore runs
  its probes from a neutral temp directory; apply the same care to any
  manual probe.
