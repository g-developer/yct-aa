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

Haiku does not support effort control; omit `effort` for Haiku roles.

## Rules

- Use `sonnet` for scoped implementation, including approved L3 execution. Use Opus/Fable around it for planning, challenge, security review, and verification rather than implying an unavailable stronger write route.
- Prefer `opus` for verifying or attacking important plans because independent review must be stronger than the implementer’s confidence.
- Do not use `haiku` for write-capable code changes except trivial mechanical edits; this pack uses `sonnet` for write-capable agents.
- Do not use `fable` by default. The parent may override planner-agent or plan-checker per invocation for justified L4 work; fall back to their Opus defaults when unavailable.
- Use aliases unless reproducibility requires pinned full model IDs.
- If an alias is unavailable in the account or provider, change that agent to `inherit` or a permitted full model ID.
- On Claude Code 2.1.251+, model precedence is per-call override > agent
  frontmatter > `CLAUDE_CODE_SUBAGENT_MODEL` > parent model. On 2.1.257+,
  `CLAUDE_CODE_SUBAGENT_MODEL_FORCE=1` makes the environment model (or the
  parent model when none is set) override per-call and frontmatter choices.
  Do not enable that force flag for this
  tiered setup. Diagnose the installed version, both variables, and alias
  overrides in the actual invocation environment before claiming a model ran.
- Before 2.1.251, `CLAUDE_CODE_SUBAGENT_MODEL` takes precedence over per-call
  and frontmatter models. Leave it unset to preserve these role defaults on
  older clients; before 2.1.196 even the value `inherit` forces the parent
  model. Do not apply the newer precedence or force-flag behavior to old clients.

## Outcome and cost economy (2026-07-13)

- Model cost may choose between otherwise suitable routes; it must not create a
  delegation phase. Keep bounded work in the parent when packet, coordination,
  and review overhead would exceed the work or add no decision evidence.
- When a genuinely independent or noisy task is delegated, use the cheapest
  model that still meets that role's quality floor.

## Failure re-route & dynamic selection (2026-07-13)

- On a model/alias-unavailable error, use at most one known available substitute
  through an exposed per-call override or equivalent role. Check the quality
  floor below first; `inherit` is suitable only when the inherited model meets
  it. Report the actual route and downgrade. Do not walk unknown aliases or
  repeat the same unavailable model.
- Frontmatter models are defaults constrained by the quality floors below.
  Use a cheaper per-call model only when it still meets the task's floor;
  escalate to Opus/Fable when the actual risk requires it. Overrides must be
  supported by the installed runtime and must preserve role permissions.

## Tier-by-criticality matrix (2026-07-13)

| 任务 | 模型档 |
|---|---|
| L0/L1 + 机械操作（轮询/状态读取/测试执行/证据整理/文件定位/diff 自检） | haiku、脚本或父线程直接完成 |
| L2 勘探 / 实现 / 定向评审 | sonnet |
| L3 计划 / 独立验证 / 工程评审 | opus（实例复杂度低时可 per-call 降 sonnet） |
| L3/L4 架构裁决、对抗评审、冲突裁决、最终安全审计 | opus/fable（唯一允许的顶配场景） |

机械操作走低成本路径；高档调用若没有增加决策所需证据，下一次同类工作降档，不创建会话路由台账。

质量地板：裁决类角色（planner/plan-checker/verify/security/code-review/semantic）
降档地板为 `sonnet`——弱模型盖章式通过比 BLOCKED 更危险；触底改报 BLOCKED，
操作者显式授权方可破例。机械/记录类可至 `haiku`。
