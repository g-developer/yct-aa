# Claude Native Notes

## Why this changed

The first pack converted Codex TOML agents into Claude Markdown adapters. This version treats Claude Code as a native harness:

- clear `description` fields for automatic delegation
- stronger model/effort mapping
- clean-context contracts in every agent
- `maxTurns` to bound cost
- read/write separation
- dedicated `code-reviewer-agent` and `security-reviewer-agent`
- `.claude/rules/` for Claude-only instructions

## Source weighting

Official Claude Code docs were treated as authority for frontmatter fields, models, effort, CLAUDE.md, rules, and memory. GitHub repositories were used as implementation-pattern references. X.com posts were used only as weak signals because most content is login-gated and not stable enough for authoritative configuration.
