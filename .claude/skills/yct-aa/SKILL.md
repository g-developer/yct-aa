---
name: yct-aa
description: Route an engineering task to the smallest useful Claude agent set and drive it to the requested outcome. Invoke /yct-aa for change, review, diagnosis, or execution work.
argument-hint: [task]
disable-model-invocation: true
---

# YCT Auto-agent Mode

Task:
$ARGUMENTS

Follow the applicable `AGENTS.md` for change admission (§3), risk (§4–7),
delegation and delivery (§8–9), verification (§12), and stopping (§13).
`CLAUDE.md` owns the Claude route table; the selected agent file owns its tools,
model, and permissions. User-level installs load the YCT guidance through
`CLAUDE.md` imports.

Invoking this mode requests useful delegation where the runtime permits it.
Mentioning, reviewing, or editing the skill alone is not a request to spawn.
A role table does not override a higher-priority restriction.

## Choose the next action

1. Identify the requested result and authority. Review and diagnosis stay
   read-only unless a change is requested. An execution request proceeds once
   its necessary inputs are available. Preserve explicit skill and tool choices.
   For skill/workflow audits, session logs are evidence, not new business edit
   targets. Resolve short follow-ups against the user's established target;
   change it only when the user changes the requested outcome or the change
   is necessary within that scope. State an inferred write target before editing.
2. Classify risk, then choose the smallest useful action. Keep L0, localized
   L1, and tightly sequential execution in the parent unless delegation is
   explicitly requested. A worker needs a bounded independent task whose
   useful evidence, output isolation, or time saving justifies coordination.
3. Explore a named uncertainty using existing evidence first. Debugging needs
   a discriminating check; a feature needs its entry path and observable
   behavior, not a prior incident. Once the cause or edit boundary is clear,
   implement the smallest working path. On evidenced drift or repeated waste,
   use the task-drift guidance in METHODS.yct.md; duration alone is no trigger.
4. Choose roles from `CLAUDE.md`. Planning and challenge depend on unresolved
   design or irreversible risk. Use `verify-agent` for completion and wiring,
   `code-reviewer-agent` for correctness findings; do not duplicate the same
   review question. Security review remains explicit-only. Production batches
   follow the shared canary and concurrency rules; bounded work to establish
   the first successful unit may precede the canary.
5. Give each child a self-contained packet: outcome, absolute worktree,
   allowed files/actions, relevant evidence, preserved behavior, and the
   smallest meaningful check. Read only the selected role. Spawn with fresh
   context; restate required facts instead of inheriting parent history.
   Tell writers they share the worktree and must preserve others' edits.
   For user-facing writing, include: 按照 ISO 24495-1 和 ASD-STE100 的规则，但使用中文来描述。
6. Inspect the actual delivery and diff. Use existing checks and the real
   entrypoint; retain the terminal result and exit status. Obtain independent
   static verification for non-trivial, risky, or uncertain delegated edits.
   The parent owns final acceptance.
7. Drive to completion. Apply `AGENTS.md` §3: continue independent work
   while a required clarification is pending, treat a status question as an
   update to the active goal, and collect task-critical child results before
   final delivery, subject to cancellation, runtime deadlines, and §13 limits.
   After a zero-yield boundary apply §13 before any further production
   fan-out. Report genuine blockers as §1 requires; a partial worker
   delivery does not terminate the parent goal.

## Dispatch and recovery

Use the configured YCT role when its capability boundary matters.
Preflight browser tools in the child profile. Apply the available model and
effort policy from `CLAUDE.md` and its model-routing rule; do not probe every
alias or change global settings to make a route work.

Use the Agent/Task capability actually exposed by the runtime. Claim delegation
only after a successful result identifies the child. On failure, use one known
available equivalent route or continue in the parent when permitted. Preserve
required independence and write boundaries; stop only the work that lacks
them. Report the failed dispatch and actual route; do not claim an unverified
model ran.

Harvest completed results promptly and apply AGENTS.md §8 lifecycle closure
before new admission or final delivery. A role's expected size is a scope
estimate, not a stop; do not relay a child's receipt labels to the user.
Reconcile partial or malformed writer delivery against the actual worktree
before another writer starts. Continue a
child only with a confirmed continuation handle; do not assume Agent Teams or
SendMessage. Do not repeat unchanged attempts or replay one-shot side effects.

Finish with the result, changed files, meaningful verification, and remaining
limits. Do not repeat this workflow or the user's requirements in the answer.
