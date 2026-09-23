# Routing Contract and Model Rationale

Configuration reviewed: 2026-09-10. Model names below describe package pins,
not account entitlement or proof of a live delegated run.

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

Examples: explorers/fixers narrow causes, planners resolve design uncertainty, plan and code reviewers assess concrete findings, security reviewers inspect trust boundaries, verifiers check the requested outcome and wiring, and semantic reviewers resolve instruction conflicts. Each method needs a task signal; a role assignment does not activate its whole method catalog.

Risk routing and mechanism admission are separate decisions. A safety or production signal can require L3 review while the accepted implementation remains a timeout, fail-fast path, local boundary fix, or observability-only change. New durable state, workers, retries/fallbacks, leases, ACKs, and protocol fields still require a current commitment or safety invariant, occurrence evidence, explicit lifecycle cost, and an activation signal.

## Codex model tiers

| Role | Model | Effort |
|---|---|---|
| `alignment-recorder-agent` | `gpt-5.6-luna` | low |
| `batch-agent` | `gpt-5.6-luna` | low |
| `batch-spark-agent` | `gpt-5.3-codex-spark` | low |
| `browser-agent` | `gpt-5.6-terra` | high |
| `code-reviewer-agent` | `gpt-5.6-terra` | high |
| `deep-investigator-agent` | `gpt-6-astra` | xhigh |
| `docs-agent` | `gpt-5.6-terra` | medium |
| `executor-agent` | `gpt-5.6-terra` | medium |
| `explorer-agent` | `gpt-5.6-terra` | medium |
| `focused-fixer-agent` | `gpt-5.6-terra` | medium |
| `general-agent` | `gpt-5.6-luna` | medium |
| `plan-checker` | `gpt-6-astra` | xhigh |
| `planner-agent` | `gpt-6-astra` | xhigh |
| `research-agent` | `gpt-5.6-terra` | medium |
| `security-reviewer-agent` | `gpt-6-astra` | xhigh |
| `semantic-review-agent` | `gpt-5.6-sol` | xhigh |
| `spark-agent` | `gpt-5.3-codex-spark` | medium |
| `verify-agent` | `gpt-5.6-sol` | xhigh |
| `verify-runner-agent` | `gpt-5.6-terra` | medium |

Astra is reserved for difficult planning, adversarial challenge, repeated-failure
investigation, and explicitly requested security review. Its stronger long-task
capabilities justify evaluating these roles first; the existing xhigh effort is
preserved. Sol remains the default for semantic review and independent static
verification. These are responsibility-based choices, not a local quality,
latency, or cost benchmark.

Normal batch, recording, and small read-only work use Luna. Dynamic verification
uses Terra because collecting valid terminal evidence needs more than launching
a command. None of these normal routes depends on Spark quota.

`batch-spark-agent` and `spark-agent` are optional speed routes. Their explicit
non-Spark substitutes are `batch-agent` and `focused-fixer-agent`, respectively.
The two batch variants keep the same mechanical scope and permissions; only
one writer runs on a target at a time. Claude keeps its existing Sonnet batch
role and does not install a Spark batch variant.

The parent handles quota or entitlement failure, including failed dispatch.
Confirmed Spark unavailability skips both Spark roles for the current task
unless new availability evidence arrives. Reconcile partial edits and running
commands before handing over the remainder; never repeat completed side
effects. No quota polling, persistent ledger, or automatic model-fallback
configuration is introduced. Runtime recovery rules live in the Codex shortcut
skills. A custom provider may have additional shared limits; changing a role
does not create a new allowance.

Role TOML files pin both model and effort. These pins override per-call model
requests, so a replacement must use an exposed equivalent role or safe parent
execution with the required independence and permissions. Do not claim an
intended model ran without runtime evidence.

## Claude model tiers

| Tier | Alias | Roles |
|---|---|---|
| Cheap/fast | `haiku` | alignment recording and read-only fallback |
| Normal engineering | `sonnet` | exploration, implementation, focused fixes, batch edits, research, browser evidence, docs, dynamic verification, code review |
| High assurance | `opus` | planning, adversarial plan review, deep investigation, security review, semantic review, static verification |
| Optional L4 escalation | `fable` | per-invocation planner or plan-checker override when available and justified |

Authorized L3 implementation remains on the scoped Sonnet executor. Add planning
or challenge only for an unresolved design or irreversible decision; use the
verification required by the actual risk.

## Verification closure

- Repository retrieval and prior-art rules live in AGENTS.md §10 and the active
  yct-ca skill. Roles reference that owner instead of maintaining their own
  query order. Known structural targets use node/callers/callees; explore is
  for discovery. Claude tool lists include both precise and discovery tools.
- The parent owns final acceptance. A localized obvious delegated edit may use parent inspection and its targeted behavioral check; non-trivial, risky, or uncertain edits need independent static verification.
- `verify-runner-agent` runs tests, lint, typecheck, builds, and smoke commands when needed.
- Runner results are evidence for the static verifier, not a substitute for goal-match, wiring, regression, and fake-completion review.
- Direct L0/L1 work may be verified by the parent without ritual subagent spawning.

## Runtime dispatch guard

- Codex must receive a successful spawn response with a child thread/agent ID before calling wait. An empty receiver set is a dispatch failure, not an idle child.
- Claude uses the Agent/Task tool actually exposed by the runtime and must receive a successful result identifying the child before claiming delegation.
- A failed or identity-less spawn is not a delegated result. Reconcile any changed state, then use one suitable available route or safe parent execution. Report the substitution; block only work whose required capability or independence is unavailable.

## Durable delivery and batching

- Every role states an expected size in tool calls. It is a routing estimate for the parent, not an automatic stop; when the remaining work no longer fits the role's bounded responsibility, the child returns completed evidence and the specific reroute, and leaves room for the final deliverable within runtime-enforced limits.
- A child ends with a self-contained final deliverable: result, evidence, changed files, verification, remaining work, and the exact missing prerequisite when incomplete. Roles no longer emit receipt headers (delivery status, overall ready, route used); the parent evaluates the underlying evidence and reports outcomes to the user without copying a child's labels.
- A child completes independently useful work first and returns the remainder as `BLOCKED` (or `REROUTE` where the role allows it) with the exact prerequisite when scope, authority, evidence, or a tool is missing. Optional fields and an exceeded estimate are not blockers; partial delivery is not acceptance, and a child blocker does not by itself terminate the parent goal.
- Review acceptance (`ACCEPT`, `PASS`, `NO_BLOCKERS`, or equivalent) requires the declared inventory to be closed; a partial inventory is a finding list, not acceptance.
- The executor, docs, and alignment roles may batch only non-overlapping requirement/file ownership. Focused fixer, Spark, mechanical batch, and general fallback remain one-shot and reroute when their bounded scope does not fit.
- The runner handles one command or cohesive command family per batch and records command, exit status, key output, artifacts, and remaining commands before starting another family.
- Empty, progress-only, tool-log-only, or malformed output never advances the parent state. A changed-state delivery failure freezes overlapping writers until the actual diff/artifacts are reconciled.
- Same-agent continuation requires a confirmed handle. Otherwise carry the concise result and evidence delta; no separate ledger or messaging feature is assumed.
- `AGENTS.md` §13 batch rule: a zero-yield boundary triggers diagnosis of the shared cause; two consecutive zero-yield boundaries pause further production fan-out until a representative trial shows the cause is removed. Debugging and single-feature work are exempt from the yield threshold; a user-directed rerun of independent items is still a batch, and authorization, safety, and total-cost limits apply to every task shape.
- Static package tests validate package structure, role registration, permissions, metadata, and installation. They do not grade prompt wording or prove live model decisions.

## Portability boundaries

- TraeX uses `platforms/TRAEX.md` and Markdown roles rendered at installation
  from the current Codex role bodies. Fresh roles inherit the active model;
  upgrades preserve local model and effort overrides, including inherit.
  Native runtime evidence, not the template, proves the actual model.
- TraeX receives inline shared guidance instead of Claude `@` references. Its
  shortcuts resolve to the same canonical directories as Codex. Reinstall
  through `--traex-only` and start a fresh session to activate rule updates.

- Shortcut skills are explicit-only: Claude uses `disable-model-invocation: true`; Codex uses `policy.allow_implicit_invocation: false` metadata.
- Browser agents are read-only evidence collectors. Codex requires an available inherited browser tool; Claude requires the browser tool to be exposed in the child profile's allowlist, or an allowed browser CLI through `Bash`.
- Codex role registrations are explicit in `.codex/config.toml`; the installer appends missing role tables while preserving existing same-name tables and warning on incompatible depth/thread settings.
- Account model allowlists and local tool availability remain runtime facts. Static parsing cannot prove a live spawn used the intended model.
- Method fixtures are historical evaluation inputs, not evidence that a live model selected a method or that a fixed agent chain is required.

## Official references

- Codex subagents and configuration precedence: <https://developers.openai.com/codex/subagents>
- Astra capabilities and migration guidance: <https://developers.openai.com/api/docs/guides/latest-model>
- Luna model scope: <https://developers.openai.com/api/docs/models/gpt-5.6-luna>
- Spark usage limits: <https://developers.openai.com/codex/pricing>
- Codex configuration reference: <https://developers.openai.com/codex/config-reference/>
- Codex skills and invocation policy: <https://developers.openai.com/codex/skills/>
- Claude Code subagents: <https://code.claude.com/docs/en/sub-agents>
- Claude Code model and effort configuration: <https://code.claude.com/docs/en/model-config>
