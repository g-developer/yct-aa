---
name: yct-aa
description: Route an engineering task to the smallest useful agent set and drive it to the requested outcome. Invoke with $yct-aa or /yct-aa for change, review, diagnosis, or execution work.
---

# YCT Auto-agent Mode

Use the task supplied with the invocation and later user corrections. Follow
the active `AGENTS.md`; it owns change admission, implementation order, risk,
delegation, verification, lifecycle and stop conditions. Use roles exposed by
the current runtime and the installed TraeX operating layer.

## Activation and visibility

Invoking this mode requests useful delegation where the runtime permits it.
Mentioning, reviewing, or editing the skill alone is not a request to spawn.
A role table does not override a higher-priority restriction.

Treat this mode as loaded only when the runtime supplied a structured `yct-aa`
skill invocation or the main agent successfully read this installed file after
the user named it. A user mention or an assistant statement such as “using
yct-aa” is not loading evidence. Do not claim the mode was loaded without one
of those signals.

If TraeX rejects a turn because an updated skill exceeds its automatic reload
limit, tell the user to invoke literal `/yct-aa <task>` or start a fresh
session. Natural-language “reload yct-aa” cannot pass that pre-model check.

`yct-aa` is an orchestration mode, not a per-step tool. Its evidence is actual
loading, task-relevant routing, agent dispatch when useful, bounded packets,
collected results and parent acceptance. Do not create repeated skill reads or
extra agents merely to make its use look frequent.

## Work loop

1. Identify the requested result, authority, write target and preserved
   behavior. Review and diagnosis stay read-only unless a change is requested.
2. Classify risk and choose the smallest action that changes a decision. Keep
   L0, localized L1 and tightly sequential work in the parent unless useful
   delegation is explicitly requested.
3. For implementation, prove the main operation through the real entrypoint,
   complete requested functionality, then add required secondary behavior and
   final verification. For performance work, prove the slow request enters the
   proposed branch and measure the same input before an expensive delivery run.
4. Before the first delegation, read `references/orchestration.md`. Select a
   role for one unresolved need. Planning, challenge and independent review are
   conditional on actual uncertainty or risk, not automatic stages.
5. Give each child a clean packet with the full absolute worktree, outcome,
   allowed files/actions, evidence, preserved behavior and smallest meaningful
   check. Pass `fork_turns="none"`; repeat the absolute worktree on follow-ups.
6. Collect finite work to a terminal result. Reconcile writes before another
   writer touches the same files. Inspect the actual diff and runtime wiring;
   the parent owns acceptance.
7. Continue until the user outcome is delivered or a genuine stop condition in
   `AGENTS.md` applies. A phase, build, review, artifact or worker receipt is not
   final delivery by itself.

After compaction, reload this entry. For model/harness or priority changes,
reuse current injected rules, loading missing/stale instructions as needed.
Reconcile original user inputs: outcome, order, authority and failed routes.
Summaries cannot create user bans. Apply `references/orchestration.md` recovery.
Keep explicit current bans; a reload-only request authorizes no task execution.
Report the decision improved by routing, verification and remaining limits.
