---
name: yct-aa
description: Explicit auto-routing mode for non-trivial engineering tasks. Invoke /yct-aa to apply AGENTS.md/CLAUDE.md routing, select the smallest useful Claude subagent/model set, use clean-context packets, and independently verify delegated source edits.
argument-hint: [task]
disable-model-invocation: true
---

# YCT Auto Agent

Task:
$ARGUMENTS

Follow `AGENTS.md` and `CLAUDE.md`.

Process:

1. Classify task criticality: L0 trivial, L1 focused, L2 multi-file, L3 risky, L4 strategic.
2. Use the lightest process that controls actual risk.
3. Select only the methods whose task signals match the `AGENTS.md` method matrix; method dumping is a routing defect.
4. Put each selected method and its required output into the responsible agent packet.
5. Do not use subagents for L0 or clear L1 tasks unless they add concrete value.
6. Use read-only agents first when scope is unclear.
7. Use write-capable agents only with clean-context task packets.
8. Require verification handoff from any write-capable agent.
9. After delegated source edits, use `verify-runner-agent` first when dynamic commands are needed, then use `verify-agent` with runner results as evidence.
10. Do not allow overlapping write-capable agents on the same files.
11. Treat a successful `Task` result identifying the configured child agent as the precondition for claiming delegation. If `Task` fails or no child identity is returned, report `BLOCKED`; do not simulate the child or silently execute its scope in the parent.

Routing:

- `CLAUDE.md` is the single owner of Claude agent/model mapping. Use its route table rather than duplicating the table here.
- Do not substitute built-in Explore for the configured `explorer-agent` inside this workflow.
- Preflight browser tooling before the configured browser route; without a browser tool, use public research or report the missing capability.

Risk override: auth, security/data boundaries, migrations, concurrency, public APIs, irreversible actions, or production behavior use `/yct-risk` discipline even when the requested diff is small.

Recurring routing/instruction failures use Double-loop Learning through `semantic-review-agent`: correct both the immediate defect and the underlying rule or feedback gap.

Final response must start with the conclusion and include changed files, verification, and residual risk.

Model availability, fallback and budget:

- Role model pins (agent frontmatter) are ceilings, not guarantees. If a spawn
  fails with a model/alias-unavailable error, retry ONCE with an explicit
  per-call `model` override on the Agent tool, walking down
  fable -> opus -> sonnet -> inherit, and report the downgrade. Never retry the
  same unavailable alias, and never claim the pinned tier ran after a downgrade.
- Remember availability for the rest of the session: after one failure of an
  alias, spawn later agents of that tier directly on the working override.
- Within a role's ceiling, pick the model by task complexity and remaining
  budget: an L2 plan may run planner on `sonnet` via per-call override; reserve
  top-tier spend for L3/L4 adjudication, adversarial review and security.

Long goals (many-item contracts, e.g. GDR-01..24):

- Slice into bounded packets of 3-5 items; never hand one agent the whole span.
- Reuse the SAME agent instance for adjacent slices (continuation reuses its
  cached context); do not respawn per slice.
- Maintain evidence/trace matrices incrementally - append delta rows per slice,
  never rebuild the full matrix from scratch.
- Do not re-read unchanged files across slices; cite prior slice anchors
  (file:line) instead.
