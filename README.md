# YCT Agent System Pack

This package installs a merge-safe user-level agent system for Claude Code, Codex, and TraeX.

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
./install.sh --traex-only --dry-run
./install.sh --traex-only
```

For an existing hand-copied TraeX installation, review the preview and use
`./install.sh --traex-only --replace-conflicts --dry-run`, then the same command
without `--dry-run`. This backs up old YCT import blocks, roles and duplicate YCT
shortcut directories outside discovery before replacing them. Unrelated skills,
model defaults, authentication and MCP settings are preserved.
Each canonical YCT shortcut directory is managed as one asset: obsolete files
inside it are backed up with the directory before replacement. Put custom
skills outside those directories. System path aliases are supported, but the
resolved install, shared-skill and backup roots must not overlap.
Legacy standalone rule files are not removed based on their names or text.
After reviewing a specific old YCT file, select it explicitly with
`uv run --no-project python scripts/install_traex.py --replace-conflicts --retire-legacy rules/subagent-orchestration.md --dry-run`,
then remove `--dry-run` to retire that file after backup.

TraeX guidance is embedded in `$TRAE_HOME/AGENTS.md` (or the existing override),
with a sufficient top-level `project_doc_max_bytes`; Claude `@` imports are not
used. Roles are rendered from `.codex/agents/*.toml`, so fixes to shared role
contracts reach TraeX without a second hand-maintained copy. New roles use
`model: inherit`; upgrades preserve each installed role's model and effort
settings. This includes user overrides and avoids reintroducing unavailable
model pins. The Codex role models are unchanged.
TraeX shortcuts link to the same `~/.agents/skills/yct-*` directories used by
Codex. Open a new session after installing; a running session keeps its snapshot.

Validate through the actual installed TraeX entrypoint:

```bash
uv run --no-project python tests/test_traex_install.py -v
uv run --no-project python tests/verify_traex.py --trae-home "$HOME/.trae" --output /absolute/new-evidence-dir --model GPT-5.6-Terra
```

The live check runs bounded local tasks and uses real subagents for ordered
commands and worktree switching. It checks terminal events, artifacts, protected
source preservation, partial blocking, zero-yield recovery, and reuse of an existing generator and
format validator. The output directory must be new to avoid replaying one-shot
actions. A model timeout is a failed run, never a pass. Model availability is an
account/runtime fact; `--model` selects the parent for this test only.
Command evidence is retained for review without prescribing a shell spelling
or tool-call count. A loop or a safe wrapper may be appropriate. The tests
check delivered behavior; they are not a benchmark of general planning ability.
The `--case capacity` scenario limits TraeX to two concurrent threads including
the parent, then starts two different child tasks in sequence. It checks new
admission after completion; it does not prove immediate memory unloading. A
completed child may remain visible for reuse. Use a real close/shutdown tool
when available; interrupting or deleting history is not resource cleanup.
`checks_passed` reports automated checks only. Inspect `command-evidence.json`
and the final answer for correct execution scope and accurate claims before
accepting the workflow. Copied parent history is excluded from command evidence.
Role scopes describe permitted work; TraeX roles inherit the host permission
boundary. The installer does not grant broader filesystem or network access.

Backups contain `install.json` with exact changed paths and their originals.
To recover, stop using that installation, restore the listed originals from
the backup, and remove only newly created listed files/links after checking
they have not since been edited. Restore parent directory backups as units;
do not copy through a current symlink. Keep the backup until fresh sessions
pass acceptance.

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
- unresolved L3/L4 design → First Principles and the specific decomposition or failure analysis needed for the decision;
- auth/data boundary → Trust Boundary and Abuse Cases;
- new retries, fallbacks, durable state, workers, cache/lease/ACK protocols, or theoretical reliability findings → Risk–Complexity Budget;
- schema/API migration → Expand–Migrate–Contract;
- implementation/review → Bidirectional Traceability and Adjacency Scan;
- recurring route/rule defect → Double-loop Learning.

Selected methods are written into the subagent packet with required outputs. Merely naming a method without evidence does not satisfy the contract.

The risk budget does not weaken safety boundaries: authorization, tenant isolation, irreversible data damage, duplicate side effects, and unbounded blocking remain must-handle. It prevents evidence-free review findings from automatically growing the production state machine, and keeps code-only complexity-reducing refactors separate from runtime reliability machinery.

## Bounded agent delivery

Batch only work with independently useful items. Every role states an expected size in tool calls and reserves room for delivery within the runtime's hard limit. Exceeding the estimate does not stop useful work or justify `BLOCKED`. The child completes independently useful work first and returns any remainder that cannot proceed as `BLOCKED` or `REROUTE` with the exact prerequisite; partial delivery is not acceptance. The child ends with a self-contained deliverable: completed work, evidence, changed files, verification, and the concrete remainder, without receipt headers.

The next batch closes the previous remainder before taking new scope. A recurring remainder is relocalized or stopped with evidence. Review agents cannot claim acceptance from partial coverage. Focused agents reroute when their scope no longer fits. If a writer returns invalid output after changing files, overlapping writers stop until the actual diff is reconciled.

Same-agent continuation requires a confirmed runtime handle. Pass the concise result and evidence delta when a new child is needed; no separate ledger is required.

## Claude routing note

Claude uses `focused-fixer-agent` for small focused fixes. `spark-agent` is retained only as a legacy compatibility worker for packets that explicitly request it.

Claude model routing uses Haiku for recording/fallback work, Sonnet for implementation and normal engineering work, Opus for demanding reasoning and independent verification, and optional Fable overrides for justified L4 planning or challenge. Select those roles only when the task needs them; they are not a fixed pipeline.

## Codex routing note

Codex delegation requires a direct request or applicable project/skill instruction, subject to runtime restrictions. Invoke `$yct-aa ...` to request useful routing. Mentioning or editing the skill is not a spawn request.

Codex pins GPT-6 Astra for difficult planning, challenge, deep investigation, and
explicit security review; GPT-5.6 Sol for semantic review and static verification;
GPT-5.6 Terra for normal engineering and dynamic verification; and GPT-5.6 Luna
for mechanical batches, recording, and small read-only work. Spark is optional:
`batch-spark-agent` uses `batch-agent` as its non-Spark substitute, and
`spark-agent` uses `focused-fixer-agent`. The parent handles quota failure and
reconciles partial work before switching. Model availability is account-dependent.
See `docs/ROUTING.md` for all 19 Codex roles and substitution limits.


## Codex instruction size

This installer sets or recommends `project_doc_max_bytes = 65536` to leave room when YCT guidance is merged with existing global instructions. Existing config is merged, not replaced.
