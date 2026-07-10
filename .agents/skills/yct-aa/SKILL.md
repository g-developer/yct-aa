---
name: yct-aa
description: Explicit auto-routing mode for non-trivial engineering tasks. Invoke with $yct-aa to classify risk, choose the smallest useful Codex subagent set and model tier, use clean-context packets, and independently verify delegated source edits. Do not use for trivial direct work or review-only requests.
---

# YCT Auto-agent Mode

Task:
$ARGUMENTS

This is explicit authorization to spawn appropriate Codex subagents.

Follow `AGENTS.md` and `.codex/agents/*.toml`.

Process:

1. Apply precedence: explicit mode, safety/risk override, task shape, needed phases, then verification.
2. Classify task criticality and use the smallest sufficient set of agents.
3. Select only the methods whose task signals match the `AGENTS.md` method matrix; method dumping is a routing defect.
4. Put each selected method and its required output into the responsible agent packet.
5. Keep L0 and clear L1 work in the parent unless delegation adds concrete value.
6. Use read-only agents first when scope is unclear.
7. Use write-capable agents only with complete clean-context packets and non-overlapping ownership.
8. Require a verification handoff from every write-capable agent.
9. After delegated source edits, run `verify-runner-agent` first when dynamic commands are required, then use `verify-agent` with runner results as evidence. Runner output supplements and never replaces static acceptance.
10. Treat a successful spawn response containing a child thread/agent ID as the precondition for any wait. Never call wait with an empty receiver set. If spawn fails or returns no child ID, return `BLOCKED` once with the tool error; do not simulate delegation or silently execute the child scope in the parent.

Routing:

- Exploration: `explorer-agent`.
- Planning: `planner-agent`.
- Plan review: `plan-checker`.
- Focused implementation: `focused-fixer-agent` by default.
- Near-instant text-only iteration: `spark-agent` only when Spark availability is known and speed is explicitly preferred; on model/entitlement failure reroute once to `focused-fixer-agent`.
- Bounded implementation: `executor-agent`.
- Mechanical edits: `batch-agent`.
- Static verification: `verify-agent`.
- Dynamic verification: `verify-runner-agent`.
- Correctness review: `code-reviewer-agent`.
- Security/data-boundary review: `security-reviewer-agent`.
- External research: `research-agent`.
- Browser evidence: `browser-agent`.
- Prompt/rules maintenance: `semantic-review-agent`.
- Durable confirmed documentation: `docs-agent`.
- Confirmed status/decision recording: `alignment-recorder-agent`.
- Small read-only fallback only when no specialized route fits: `general-agent`.

Risk overlay:

- Auth, authorization, payments, secrets, injection, uploads, migrations, tenant/data boundaries, concurrency, public APIs, irreversible actions, or production behavior use L3/L4 discipline even when the requested diff is small.
- L3/L4 uses `planner-agent`, `plan-checker`, scoped execution, `security-reviewer-agent` when sensitive boundaries are involved, `verify-agent`, and dynamic verification as needed.
- Do not execute destructive, irreversible, or public-contract-changing work without explicit approval.
- For recurring routing/instruction failures, use Double-loop Learning through `semantic-review-agent`: fix the immediate defect and the underlying rule or feedback gap.

Final response:
- Conclusion.
- Changed files.
- Verification.
- Risks / not checked.
