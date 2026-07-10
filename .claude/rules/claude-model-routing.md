# Claude Model and Effort Routing

This rule is Claude-specific. Do not copy it into `AGENTS.md` unless another tool understands Claude model aliases.

## Model scope

- `fable`: optional L4 planning or plan-check escalation when available and justified. Expensive; not the default.
- `opus`: architecture, planning, adversarial review, security, hard debugging, independent verification.
- `sonnet`: day-to-day coding, implementation, test running, browser work, research synthesis.
- `haiku`: simple read-only lookup, short docs, mechanical status recording, low-risk fallback.
- `inherit`: use when the parent session already selected the right model and consistency matters.

## Effort scope

- `low`: trivial, mechanical, or latency-sensitive work.
- `medium`: bounded work where cost matters.
- `high`: default for serious coding and review.
- `xhigh`: hard reasoning, security, architecture, ambiguous debugging, adversarial review.
- `max`: exceptional only; risk of overthinking and high token spend.

## Rules

- Use `sonnet` for scoped implementation, including approved L3 execution. Use Opus/Fable around it for planning, challenge, security review, and verification rather than implying an unavailable stronger write route.
- Prefer `opus` for verifying or attacking important plans because independent review must be stronger than the implementer’s confidence.
- Do not use `haiku` for write-capable code changes except trivial mechanical edits; this pack uses `sonnet` for write-capable agents.
- Do not use `fable` by default. The parent may override planner-agent or plan-checker per invocation for justified L4 work; fall back to their Opus defaults when unavailable.
- Use aliases unless reproducibility requires pinned full model IDs.
- If an alias is unavailable in the account or provider, change that agent to `inherit` or a permitted full model ID.
