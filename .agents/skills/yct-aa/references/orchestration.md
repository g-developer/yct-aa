# YCT orchestration reference

Read this file before the first delegation in an invoked `yct-aa` task. The
active `AGENTS.md` remains authoritative when this reference is silent or stale.

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
