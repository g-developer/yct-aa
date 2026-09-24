---
name: yct-aa
description: Route an engineering task to the smallest useful agent set and drive it to the requested outcome. Invoke with $yct-aa or /yct-aa for change, review, diagnosis, or execution work.
---

# YCT Auto-agent Mode

Use the task supplied with the invocation and later user corrections.

Follow the applicable `AGENTS.md` for change admission (§3), risk (§4–7),
delegation and delivery (§8–9), verification (§12), and stopping (§13).
Use the roles exposed by the current runtime. Codex loads registered agent TOML
files; TraeX loads its installed Markdown roles and TRAEX.yct.md platform layer.
Use paths from that runtime, not a guessed file in the business worktree. Shared
guidance already injected into the conversation does not need another file read.

Invoking this mode requests useful delegation where the runtime permits it.
Mentioning, reviewing, or editing the skill alone is not a request to spawn.
A role table does not override a higher-priority restriction.

For implementation, prove the main path with one real invocation before
expanding secondary features. Use scoped checks while developing and the full
E2E set after functional completion. Do not start with a failing full-suite
baseline or load a generic TDD workflow to replace this order. New unit tests
wait until functional completion and need a remaining coverage gap (§12).
An explicit user testing instruction takes precedence.

## Choose the next action

1. Identify the requested result and authority. Review and diagnosis stay
   read-only unless a change is requested. An execution request proceeds once
   its necessary inputs are available; do not convert it into a new design
   project. Preserve the user's explicit skill and tool choices.
   Keep the object being improved separate from the evidence used to review it.
   When asked to improve a skill or workflow from session logs, repair that
   skill's execution rules and verify its behavior. Business failures in the
   logs remain evidence; locating their source does not make them edit targets.
   A short follow-up keeps the established target; an explicit user change
   replaces it. State an inferred write target before the first edit.
2. Classify risk, then choose the smallest useful action. Keep L0, localized
   L1, and tightly sequential execution in the parent unless delegation is
   explicitly requested. Use a worker only for a bounded independent task that
   adds useful evidence, isolates substantial output, or reduces execution
   time enough to justify coordination and verification.
3. Explore a named uncertainty, using existing evidence first. Debugging needs
   a discriminating check; a feature needs its intended entry path and
   observable behavior. Do not demand incident evidence for new functionality.
   Once the cause or edit boundary is clear, follow AGENTS.md §6: prove the
   main path through the real entrypoint, complete functionality, then refine.
   Apply §12 test timing: scoped checks during development, full E2E at final
   acceptance, unit tests only for justified gaps after functional completion.
   On evidenced drift or repeated waste, use the task-drift guidance in
   METHODS.yct.md; task duration alone does not trigger it.
4. Select roles by the question below. Planning and challenge are conditional
   on unresolved design or irreversible risk. A production batch follows the
   canary and concurrency rules in `AGENTS.md`; those rules do not prevent
   bounded work needed to establish the first successful unit.
5. Give each child a self-contained packet: outcome, absolute worktree,
   allowed files/actions, relevant evidence, preserved behavior, and the
   smallest meaningful check. Read the selected role, not the entire catalog.
   Repeat the full absolute worktree on follow-ups and reused children.
   Pass `fork_turns: "none"` explicitly. Use a few recent turns only for a
   named dependency that cannot be restated; never use or omit into `"all"`.
   Tell writers they share the worktree and must preserve others' edits.
   A parent-created packet cannot authorize checks forbidden by the shared
   contract or selected role.
   For user-facing writing, include: 按照 ISO 24495-1 和 ASD-STE100 的规则，但使用中文来描述。
6. Inspect the actual delivery and diff. Use existing checks and the real
   entrypoint; retain the command's terminal result and exit status. Get
   independent static verification for non-trivial, risky, or uncertain
   delegated edits. An empty or future-tense child final is unfinished work;
   correct the packet or continue the task before accepting it. The parent
   owns final acceptance.
   For a no-edit constraint, limit writes and inspect the relevant diff or
   existing evidence. Neither parent nor child may calculate file hashes,
   create source snapshots or add unrelated preflight solely to prove no edit.
   Report the requested result and material limits; omit hash values and
   unrelated metadata unless the user asked for them.
   Apply AGENTS.md §11 to validator results: preserve their scope, reconcile
   contradictory evidence, and distinguish example counts from totals before
   reporting success. Check supplied direction and completion fields as well
   as prose; a tool's own status label is not the acceptance decision.
7. Drive to completion. Apply `AGENTS.md` §3: continue independent work
   while a required clarification is pending, treat a status question as an
   update to the active goal, and collect task-critical child results before
   final delivery, subject to cancellation, runtime deadlines, and §13 limits.
   After a zero-yield boundary apply §13 before any further production
   fan-out. Report genuine blockers as §1 requires; a partial worker
   delivery does not terminate the parent goal.

## Select a role

| Unresolved need | Role and boundary |
|---|---|
| Locate a path, dependency, or environment fact | `explorer-agent`; read-only, with a specific question |
| Explain a failed repair or recurring root cause | `deep-investigator-agent`; only when ordinary evidence still leaves causality unresolved |
| Decide an ambiguous or risky design | `planner-agent`; plan only |
| Challenge a concrete unresolved design | `plan-checker`; one decision, not an automatic stage |
| Fix a localized failure | `focused-fixer-agent`; normally one to three files |
| Implement a wider bounded change | `executor-agent`; explicit ownership and done criteria |
| Apply one mechanical rule | `batch-agent`; explicit list of at most six files |
| Accelerate that same mechanical batch | `batch-spark-agent`; known Spark availability and explicit speed preference |
| Perform optional fast text iteration | `spark-agent`; known availability and explicit speed preference |
| Run a command family with noisy output | `verify-runner-agent`; verification artifacts only |
| Verify completion, wiring, and preserved behavior | `verify-agent`; independent static evidence |
| Find correctness or regression defects | `code-reviewer-agent`; do not duplicate an already-covered verification question |
| Review security boundaries | `security-reviewer-agent`; explicit user request only |
| Resolve external or versioned facts | `research-agent`; primary sources |
| Observe browser or authenticated UI state | `browser-agent`; read-only, with tools and session available to the child |
| Resolve an instruction conflict | `semantic-review-agent`; only when parent evidence cannot settle it |
| Author confirmed documentation | `docs-agent`; named document scope |
| Record confirmed state or decisions | `alignment-recorder-agent`; an existing or explicitly requested record |
| Handle a small remaining read-only question | `general-agent`; only when no specialized role fits |

## Dispatch and recovery

Check the selected role and required tools in the current runtime before
spawning. Model pins and permissions belong to the role configuration.
An explicit model in a role TOML overrides a per-call model request; switching
a pinned model requires a different registered role, not a pretend override.
Do not probe every model or silently change a role's permissions.

The parent owns Spark recovery, including failures before a child can start:

- Default to `batch-agent` for mechanical edits and `focused-fixer-agent` for
  localized fixes. Spark is optional acceleration, never a required stage.
- Use `batch-spark-agent` → `batch-agent` and `spark-agent` →
  `focused-fixer-agent` as the two explicit substitution routes. Start only one
  writer on a target at a time; keep the original files, operation, permissions,
  and verification requirements.
- On confirmed Spark quota exhaustion or missing entitlement, skip both Spark
  roles for the rest of the current task unless new availability evidence
  arrives. Do not try the same quota pool under another role name, poll for a
  reset, or persist a new routing ledger. A generic timeout or test failure
  alone does not prove quota exhaustion.
- After a partial run, reconcile the actual diff and any running commands,
  then pass only the remaining work to the substitute. Do not replay completed
  writes or one-shot side effects. A child cannot report a dispatch failure
  when it never started; the parent must act on the tool's error.

Wait only after a successful spawn returns a child ID. On a model or tool
failure, use one known available role with equivalent scope and adequate
capability, or continue in the parent when permitted. Preserve required
independence and write boundaries; stop only the work that lacks them.
Report a failed dispatch and the route actually used. A requested model is
not proof of the model that ran.

Harvest a completed child's result promptly and apply AGENTS.md §8 lifecycle
closure before new admission or final delivery; preserve a handle only for a
concrete follow-up. Do not transfer overlapping write ownership until the
child's finite background commands are terminal and the diff is reconciled.
A role's expected size is a scope estimate, not a stop; a child that runs
over it delivers the result or a concise remainder, never a false `BLOCKED`.
Do not relay a child's receipt labels to the user; report outcomes. Do not
repeat unchanged failed attempts or replay one-shot side effects.

Finish with the result, changed files, meaningful verification, and remaining
limits. Do not repeat this workflow or the user's requirements in the answer.
