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
- Codex uses Astra for difficult planning, challenge, deep investigation, and explicit security review; Sol for semantic review and static verification; Terra for normal engineering and dynamic verification; Luna for normal mechanical, recording, and small read-only work.
- Spark availability is account-dependent. Only `batch-spark-agent` and `spark-agent` require it; their non-Spark substitutes are `batch-agent` and `focused-fixer-agent`. The parent handles unavailable quota and reconciles partial work before switching.
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

## GPT-6 Astra instruction calibration (2026-09-10)

- Astra follows `AGENTS.md`, skill, and role instructions more literally than
  earlier models. Clauses written to restrain older models — "ask before",
  "stop and return BLOCKED", "two zero-yield boundaries override every
  continue clause", "read once, never re-read" — become literal stop points.
  Forensics of 30 NAS sessions (2026-09-06..09, MusicTagWeb batch reruns)
  showed the parent ending goals with hundreds of items unstarted after
  quoting the §13 economic stop, ending turns while its own children were
  still running, and patching cases one by one instead of measuring the whole
  batch; the supplied digests do not establish that §11 caused this behavior.
  Counting bases differ: the digest generator groups messages into 79 turns
  for the main session, the same JSONL holds 110 `turn_context` records, and
  the 151 calls attributed to `general-agent` are the whole subsession total.
- v4.20 therefore states the continuation duties positively in `AGENTS.md`
  §3 (Initiative and follow-through), scopes the economic stop to a
  homogeneous production batch after two consecutive zero-yield boundaries,
  regardless of strategy renaming, and removes the role-file receipt ritual
  (delivery status / overall ready / route used). Those headers appear in the
  supplied digests; whether they were emitted as parent final responses
  remains unverified because the digests do not preserve the channel.
- When Astra pauses because of an instruction, it must name and link the
  file, quote the rule, and separate the rule from its own interpretation
  (§1). Use that quote to fix the instruction at its owner, not to add
  another layer. User instructions outrank file-based guidance but not
  `developer_instructions` or enforced permissions; the parent routes
  authorized work to a role whose permissions allow it.
- Reasoning effort: the Astra guide says to preserve the current effective
  effort and never use `none`. This pack keeps the parent's configured effort;
  role TOMLs pin their own. On the NAS the yct config block had
  `model_reasoning_effort = "medium"` while the Mac used `"max"`. The NAS
  default was changed to `high` as a tuning experiment. The session records
  do not establish that Astra at medium caused shallow diagnosis: the 27
  scripted exec jobs ran `gpt-5.5`/medium, the long interactive session
  mixed `gpt-5.6-sol`/max with Astra at max, xhigh, and medium, and the two
  subagent sessions ran `gpt-5.6-terra`/high and `gpt-5.6-luna`/medium.
  Validate any effort change against the effective model and effort recorded
  in the relevant turns. Two caveats observed on 2026-09-10: the scripted
  NAS jobs pin `-m gpt-5.5 -c model_reasoning_effort="medium"` on the
  command line, so the config default only affects sessions that do not
  override it; and `~/.codex/config.toml` was rewritten while jobs were
  running (its mtime matched the start of a `codex exec` job, which appends a
  trust entry) and afterwards read `medium` again although `high` had been
  set earlier; the cause of that revert is not verified. Re-check the file,
  and the effective effort in the session `turn_context`, after editing it.
- Every scripted `codex exec` job inherits the full merged `~/.codex/AGENTS.md`
  (about 34 KB) plus any invoked skill. Whether a minimal project `AGENTS.md`
  or a `project_doc_max_bytes` override changes what 0.153.x actually loads
  has not been verified; check with `codex debug prompt-input` before relying
  on either as a way to trim orchestration guidance from business jobs.
- `general-agent` is a read-only fallback with an expected size of about
  three tool calls. A session that used it for a 151-call workhorse task was
  a routing defect; use `explorer-agent` or `executor-agent` for that shape.
  That subagent session (24 turn contexts, `gpt-5.6-luna`/medium) also
  recorded `sandbox_policy = danger-full-access` and claimed to have written
  a file, although the role declares `default_permissions = ":read-only"`.
  Every one of the 30 sessions, including the parent interactive session
  and all scripted exec jobs, had `danger-full-access` turns (one parent turn
  was `workspace-write`), so the child most likely inherited the parent's
  session-wide bypass. The cause is not
  verified; adding the same `:read-only` line again cannot fix it. Check it
  with an isolated test file: spawn `general-agent` from a parent that runs
  with the default sandbox, ask it to write, and confirm the write is
  refused. Check the effective policy after a real spawn and use an isolated
  write probe; a verbal refusal by the model does not prove the boundary.
- Follow-ups recorded from the two-round Astra review of v4.20, not applied
  in this release. These are open items of the original configuration and
  skills review, not resolved problems:
  - `[features] unbounded_connection_retries` is `stable`/`true` on the Mac
    0.153.4 install. Setting it to `false` would bound reconnect loops, but
    whether the observed `503 auth_unavailable` path is governed by it is
    unknown; the flag stays unchanged until that is verified.
  - The Mac config grants writable workspace roots for two whole parent
    directories plus `~/.codex/config.toml`, so "write only the task
    worktree" currently rests on prompts. Runner roles inherit `:workspace`,
    which cannot enforce "artifacts only, no source edits".
  - `tests/verify_deploy.sh` runs four authorized actions once in sequence.
    The v4.20 behavior changes need at least two behavioral scenarios that
    it does not cover: (a) zero-yield pause and recovery — one real unit
    passes, a shared fault is injected, production calls are recorded, no
    third batch starts after two consecutive zero-yield boundaries while the
    representative trial fails, and the authorized remainder completes
    automatically after the repair and a passing trial; (b) partial block
    and handoff — one path lacks a required input while an independent path
    completes, the independent artifact is actually produced, the whole is
    not reported as passing, and a write-requiring verification is handed by
    `verify-agent` to the runner and then actually executed. Status-question
    resumption and effective child permissions need an interactive
    entrypoint; the existing one-shot `codex exec` test does not cover them.
  - The installed `yct-cr` skill (separate repository) still requires a
    regression test and a negative test for every accepted change, which
    conflicts with §12's risk-based test selection. The original
    non-business-skills review is therefore not complete.
