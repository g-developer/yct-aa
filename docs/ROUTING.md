# Routing Contract and Model Rationale

Date checked: 2026-07-10

This document records design decisions. Runtime rules remain owned by:

- shared criticality, precedence, method triggers, packet, and verification rules: `AGENTS.md`;
- detailed method contracts: `docs/METHODS.md`;
- Claude role/model mapping: `CLAUDE.md` and `.claude/agents/*.md`;
- Codex role/model mapping: `.agents/skills/yct-aa/SKILL.md`, `.codex/config.toml`, and `.codex/agents/*.toml`;
- shortcut-specific deltas: the corresponding `yct-*` skill.

## Route precedence

1. Explicit shortcut intent.
2. Safety/risk override.
3. Task shape and capability.
4. Only the phases actually needed.
5. Verification closure.

Security, data, migration, concurrency, public API, irreversible, and production-impacting work must not remain on the focused-fix path merely because the diff is small.

## Method routing

Method selection occurs after task/risk classification and before agent selection:

1. Identify the decision, uncertainty, or failure signal.
2. Select only matching methods from the `AGENTS.md` matrix.
3. Add selected methods and required outputs to the clean-context packet.
4. Route each method to its owning capability.
5. Reject empty method headings and method dumping during verification.

Examples: explorers/fixers own hypothesis falsification, planners own first-principles/MECE/ledgers/FMEA/risk–complexity budgeting/migration staging, plan and code reviewers classify theoretical findings instead of promoting them directly to requirements, security reviewers own trust boundaries and abuse cases, verifiers own bidirectional traceability and test-strategy adequacy, and semantic reviewers own double-loop learning.

Risk routing and mechanism admission are separate decisions. A safety or production signal can require L3 review while the accepted implementation remains a timeout, fail-fast path, local boundary fix, or observability-only change. New durable state, workers, retries/fallbacks, leases, ACKs, and protocol fields still require a current commitment or safety invariant, occurrence evidence, explicit lifecycle cost, and an activation signal.

## Codex model tiers

| Tier | Model | Roles |
|---|---|---|
| Demanding | `gpt-5.6` | planner, plan checker, executor, code/security/semantic review, static verifier, browser evidence |
| Fast portable | `gpt-5.6-terra` | explorer, research, docs, general fallback, alignment recording, focused fixer, batch edits, dynamic runner |
| Optional latency path | `gpt-5.3-codex-spark` | Spark-only focused text iteration when ChatGPT Pro preview availability is known |

`focused-fixer-agent` is the portable default. A model/entitlement failure from `spark-agent` may reroute once to the focused fixer; do not retry Spark repeatedly.

## Claude model tiers

| Tier | Alias | Roles |
|---|---|---|
| Cheap/fast | `haiku` | alignment recording and read-only fallback |
| Normal engineering | `sonnet` | exploration, implementation, focused fixes, batch edits, research, browser evidence, docs, dynamic verification, code review |
| High assurance | `opus` | planning, adversarial plan review, security review, semantic review, static verification |
| Optional L4 escalation | `fable` | per-invocation planner or plan-checker override when available and justified |

Approved L3 implementation remains on the scoped Sonnet executor. Opus/Fable planning and verification surround it. The pack does not claim to have a stronger write-capable Claude route that it does not define.

## Verification closure

- Delegated source edits always receive static acceptance from `verify-agent`.
- `verify-runner-agent` runs tests, lint, typecheck, builds, and smoke commands when needed.
- Runner results are evidence for the static verifier, not a substitute for goal-match, wiring, regression, and fake-completion review.
- Direct L0/L1 work may be verified by the parent without ritual subagent spawning.

## Runtime dispatch guard

- Codex must receive a successful spawn response with a child thread/agent ID before calling wait. An empty receiver set is a dispatch failure, not an idle child.
- Claude must receive a successful `Task` result identifying the configured child before claiming delegation.
- On either platform, a failed or identity-less spawn returns `BLOCKED` with the tool evidence. The parent must not simulate the child or silently execute the delegated scope itself.

## Portability boundaries

- Shortcut skills are explicit-only: Claude uses `disable-model-invocation: true`; Codex uses `policy.allow_implicit_invocation: false` metadata.
- Browser agents are read-only evidence collectors. Codex requires an available inherited browser tool; Claude requires the browser tool to be exposed in the child profile's allowlist, or an allowed browser CLI through `Bash`.
- Codex role registrations are explicit in `.codex/config.toml`; the installer appends missing role tables while preserving existing same-name tables and warning on incompatible depth/thread settings.
- Account model allowlists and local tool availability remain runtime facts. Static parsing cannot prove a live spawn used the intended model.
- Method fixtures prove static contract coverage only. They do not prove a live model selected the intended method for a prompt.

## Official references

- Codex subagents and model guidance: <https://learn.chatgpt.com/docs/agent-configuration/subagents>
- Codex configuration reference: <https://developers.openai.com/codex/config-reference/>
- Codex skills and invocation policy: <https://developers.openai.com/codex/skills/>
- Claude Code subagents: <https://code.claude.com/docs/en/sub-agents>
- Claude Code model and effort configuration: <https://code.claude.com/docs/en/model-config>
