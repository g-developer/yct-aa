# Shortcut Layer v4.7

This package reduces repeated prompt boilerplate for Claude Code and Codex.

## Claude Code

Claude skills live in `.claude/skills/` and can be invoked as slash commands.

Use:

```text
/yct-aa fix the failing auth refresh-token test
/yct-direct explain this error
/yct-risk redesign the permission check for workspace admins
/yct-review current branch against main
/yct-fix pytest failure in tests/auth/test_refresh.py
```

Short text prefixes also work because `AGENTS.md` and `CLAUDE.md` define them. The installed shortcut skills themselves are explicit-only, so ordinary prompts do not unexpectedly activate a mode:

```text
yct-aa: fix the failing auth refresh-token test
yct-direct: explain this error
yct-risk: change the authorization model for teams
yct-review: current branch against main
yct-fix: stack trace ...
```

## Codex

Codex skills live in `.agents/skills/`.

Use explicit skill invocation:

```text
$yct-aa fix the failing auth refresh-token test
$yct-direct explain this error
$yct-risk redesign the permission check for workspace admins
$yct-review current branch against main
$yct-fix pytest failure in tests/auth/test_refresh.py
```

Why `$yct-aa` instead of typing the long prompt:

- `$yct-aa` explicitly authorizes Codex to spawn suitable subagents.
- The skill loads the clean-context packet, routing, and verification rules.
- It selects only task-relevant methods and passes their output contracts to the responsible agent.
- It gives every child a bounded delivery policy: complete final result or a reusable batch receipt, never progress-only output.
- It keeps your task prompt short while preserving the multi-agent discipline.
- Focused fixes use the portable `focused-fixer-agent` by default; Spark is an optional known-available acceleration route.

## Shortcut meanings

| Shortcut | Meaning | Use when |
|---|---|---|
| `yct-aa` | Auto-agent mode | Normal non-trivial coding task |
| `yct-direct` | No-agent mode | Tiny, low-risk, reversible task |
| `yct-risk` | Risky-task mode | Auth, data, migrations, public API, architecture, production behavior |
| `yct-review` | Review-only mode | PR, diff, branch, plan, or implementation review |
| `yct-fix` | Focused-fix mode | One failing test, stack trace, small bug, narrow cleanup |

## Recommended daily default

Use no prefix for simple natural requests in Claude. Use `/yct-aa` when you want more reliability.

Use `$yct-aa` in Codex for any task where subagents may be useful, because Codex requires explicit subagent authorization.

Methods are not separate shortcuts. `yct-aa`, `yct-risk`, `yct-fix`, and `yct-review` select them from the shared task-signal matrix. For example, a known one-file typo should not trigger FMEA; an ambiguous production migration should not omit it.

For long work, `yct-aa` closes the previous batch remainder before opening new scope. Review acceptance is final-only, focused/Spark/mechanical workers remain one-shot, and continuation is attempted only when the platform confirms a reusable child handle.

## Installer merge behavior

`install.sh` installs user-level files on macOS and Linux. It appends new `yct-*` skills and never deletes unrelated skills. Same-path YCT assets are backed up and updated. A different-path agent with the same declared identity stops installation unless `--replace-conflicts` is explicitly supplied; unrelated agents/rules are preserved. Root `CLAUDE.md` and Codex `AGENTS.md` are merged with YCT marker blocks instead of being replaced.


## Review agents

`yct-review` may use `code-reviewer-agent`, `security-reviewer-agent`, `verify-agent`, `plan-checker`, and `research-agent` depending on the target.
