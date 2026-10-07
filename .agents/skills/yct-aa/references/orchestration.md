# YCT orchestration reference

Read this file before the first delegation and when recovering an active task. The
active `AGENTS.md` remains authoritative when this reference is silent or stale.

Contents: [Recovery](#recovery-and-changed-priorities),
[Model and MCP changes](#model-and-mcp-changes), [Roles](#role-selection),
[Dispatch](#dispatch-and-recovery), [Evidence](#evidence-of-use).

## Recovery and changed priorities

After compaction, a model/harness switch or a mode/priority correction, reconcile the next action with
the original user messages already retained in context. Do not read prohibited
history or memory to do this. Keep these facts separate:

- Loading: which installed instructions were actually supplied or read.
- Mode: whether the user currently requests this workflow for the task.
- Authority: which actors may delegate or write, under which restrictions.
- Order: the first unmet user milestone and work explicitly deferred until later.

Carry narrow authorization exceptions with their target and completion state;
do not omit them into an unconditional ban or expand them into general access.
Reconcile stale plan checkpoints with the actual current inputs and unfinished
milestone before reuse. A completed earlier candidate or phase does not complete
a later requirement. Update the existing plan when that state changes.

An assistant summary can omit a later correction or expand an earlier choice.
Before claiming "the user forbids new agents", locate the original restriction
and reconcile later instructions. "No children are running", an unsuccessful
dispatch or "keep this step in the parent" is not a permanent delegation ban.
A request to reload instructions alone is not authorization to execute pending
work or to override a genuine no-agent instruction. If the original instruction
is unavailable or contradictory, clarify only the affected action and continue
independent work whose authority is established.

For an active routing request, choose useful independent work again at a phase
boundary or repeated failure. Shared write ownership may require one writer;
it does not prevent disjoint read-only diagnosis or independent verification.
Name the current question and accept the child's evidence before deciding.
If parent execution is best, tie that choice to the actual dependency, cost or
available capability. Do not create agents merely to satisfy a count.

Honor the user's milestone order in actual commands and worker packets. When
the user defers optimization or a broad rerun, do not let a convenient benchmark
or one passing representative substitute for the requested completion set.
If a deferred action appears indispensable, identify the concrete dependency
and resolve that conflict; do not silently weaken either the order or the
product's existing safety and timeout constraints.
Keep measurement and tolerance scopes with those milestones. A diagnostic-stage
tolerance or a fast inner operation does not waive a later deadline for the
user's complete entrypoint, including its required terminal result.

When reporting progress, explain what the routing decision resolved and what
remains to reach the current milestone. Repeated "using yct-aa" messages,
reloads and agent counts do not establish useful application of the workflow.
Report unique requested Cases, attempts and repeats separately. Preserve the
full requested set when using a smaller diagnostic sample. Before editing a
plan or interpreting an earlier run, read its actual existing content or
recorded invocation; do not replace either with current assumptions.

## Model and MCP changes

A switch changes the model's current context and may change tool exposure; it
does not by itself prove the MCP connection failed. Reconcile the active workflow
from current injected instructions; read the installed entry if absent, stale
or changed. Reconcile task state before new work. Check the selected
model's supported backend variant and effort, without changing global settings
or pinned role choices to make a test pass.

Inspect the current tool catalog for the next required capability. If a query
is needed, use one small real request in the target worktree. A successful
required call after the switch is enough; do not perform another health scan
or restart healthy MCP servers. A metadata listing or external doctor alone
does not prove that the current client can execute a tool.

Keep failure scope precise: an ordinary query timeout is not `Transport closed`.
A known closed transport requires a supported host reconnect and a successful
query through the new client; do not send setup probes to that dead connection.
Without a reconnect capability, use an available route for independent work and
report the affected dependency. Preserve known failures through model switches
and compaction, but do not disable all MCPs because one client or file failed.

Runtime and tool notices do not replace the unfinished user task. Acknowledge
only a material capability change, then continue the next authorized operation.

## Role selection

| Unresolved need | Role and boundary |
|---|---|
| Locate code, dependencies or environment facts | `explorer-agent`; read-only and question-specific |
| Explain a repeated failed repair | `deep-investigator-agent`; only after ordinary evidence leaves causality unresolved |
| Decide an ambiguous or risky design | `planner-agent`; plan only |
| Challenge one unresolved design | `plan-checker`; one decision |
| Fix a localized failure | `focused-fixer-agent`; normally one to three files |
| Implement a wider bounded change | `executor-agent`; explicit ownership and done criteria |
| Apply one mechanical rule | `batch-agent`; at most six explicit files |
| Accelerate a mechanical batch | `batch-spark-agent`; only with known Spark availability and explicit speed preference |
| Perform fast text iteration | `spark-agent`; only with known availability and explicit speed preference |
| Run noisy dynamic checks | `verify-runner-agent`; verification artifacts only |
| Verify completion and wiring | `verify-agent`; independent static evidence when justified |
| Find correctness or regression defects | `code-reviewer-agent`; do not duplicate the verifier's question |
| Review security boundaries | `security-reviewer-agent`; explicit user request only |
| Resolve external or versioned facts | `research-agent`; prefer primary sources |
| Observe an authenticated UI | `browser-agent`; read-only and preflight its tools |
| Resolve an instruction conflict | `semantic-review-agent`; only when parent evidence cannot settle it |
| Author confirmed documentation | `docs-agent`; named document scope |
| Record confirmed state | `alignment-recorder-agent`; approved record only |
| Handle a small unmatched read-only task | `general-agent`; last resort |

## Dispatch and recovery

- Check the selected role and required tools before spawning. Claim delegation
  only after a successful spawn returns a child identity. Runtime evidence,
  rather than the requested role name, establishes the model that ran.
- A spawn identity or `task_started` proves admission, not active review or
  execution. At the expected first-work checkpoint, use a model/tool item or
  artifact to establish progress. If a route is stalled at startup, inspect one
  owned native log, preserve its endpoint/configuration boundary and reconcile
  the owned request before using a confirmed working route. Do not add more
  workers to the same stalled route or alter global model pins to hide it.
- Use `batch-agent` and `focused-fixer-agent` as portable defaults. Spark is
  optional. On confirmed Spark quota or entitlement failure, use
  `batch-spark-agent` → `batch-agent` or `spark-agent` →
  `focused-fixer-agent`. Do not retry the same unavailable pool under another
  name.
- Start only one writer on overlapping files. Before replacement or follow-up,
  ensure the prior writer and its finite commands are terminal and reconcile
  the worktree. Carry forward only the concrete remainder.
- Preserve closed transports, failed model routes, exact IDs, paths, revisions
  and current user restrictions across phases and compaction. A new phase does
  not create new availability evidence.
- Use independent static verification after non-trivial, risky or uncertain
  delegated edits. Dynamic commands supplement source inspection. Do not run a
  duplicate review over unchanged evidence.
- A production batch needs a real accepted canary before fan-out. Size
  concurrency from the measured bottleneck. Stop new admission at the shared
  zero-yield boundary and resume only after a representative trial proves the
  blocker is removed.
- Harvest useful results promptly. Keep a child handle only for an identified
  follow-up. Use a close capability when the runtime exposes one; interruption
  alone is not closure.

## Evidence of use

`yct-aa` should change routing decisions, not add ceremony. For session audits,
separate these facts:

1. A structured skill object or successful installed-file read proves loading.
2. Spawn, follow-up, wait and close events prove orchestration actions.
3. The child's result and parent inspection prove useful delivery.
4. User-visible status text alone proves none of the above.

After compaction, follow `AGENTS.md` and reload the installed entry before new
routing. Distinguish structured invocation from manual loading; neither alone
proves workflow compliance. Agent activity must be judged against the task.
