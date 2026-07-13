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

## Parent-tier economy (2026-07-13)

- A parent session running on `fable`/`opus` must not do inline work that the route table
  assigns to cheaper tiers: scoped implementation belongs to `executor-agent` (sonnet)，
  mechanical batch/verification belongs to `batch-agent`/`haiku` workers. The parent's
  inline turns are the most expensive tokens in the system — reserve them for adjudication,
  packet construction, and integration of results.
- Exception: single-file edits where the packet-writing overhead exceeds the edit itself
  (L0/L1), per the AGENTS.md criticality table.

## Failure re-route & dynamic selection (2026-07-13)

- Spawn failure with a model/alias-unavailable error -> retry once with an
  explicit per-call `model` override on the Agent tool, walking down
  fable -> opus -> sonnet -> inherit; report the downgrade. Never repeat the
  same unavailable alias, and never claim the pinned tier ran after a downgrade.
- Frontmatter pins are ceilings: for low-complexity instances of a role
  (an L2 plan, a light diff review), the parent should pass a cheaper per-call
  `model` override, guided by criticality and remaining budget.

## Tier-by-criticality matrix (2026-07-13)

| 任务 | 模型档 |
|---|---|
| L0/L1 + 机械操作（轮询/状态读取/测试执行/证据整理/文件定位/diff 自检/trace 更新） | haiku 或脚本（顶配出现在此为路由缺陷） |
| L2 勘探 / 实现 / 定向评审 | sonnet |
| L3 计划 / 独立验证 / 工程评审 | opus（实例复杂度低时可 per-call 降 sonnet） |
| L3/L4 架构裁决、对抗评审、冲突裁决、最终安全审计 | opus/fable（唯一允许的顶配场景） |

机械操作强制低成本路径是硬规则；每轮的模型选择与 token 消耗记入会话路由台账，
高档消耗无证据增量 → 记为路由缺陷并在下一轮降档（Double-loop）。
