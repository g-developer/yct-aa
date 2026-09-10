---
name: yct-risk
description: High-risk task workflow for auth, authorization, payments, data migrations, public APIs, concurrency, security, production behavior, or architecture decisions.
argument-hint: [task]
disable-model-invocation: true
---

# Risky Task Mode

Task:
$ARGUMENTS

Treat the task as L3/L4 until evidence narrows the risk. Follow the role and
model owners in `CLAUDE.md`; do not turn this mode into a fixed agent pipeline.

## Choose only necessary depth

- Start from the requested production outcome, current runtime facts,
  constraints, invariants, non-goals, smallest safe solution, and rejection or
  rollback conditions.
- L3/L4 raises the evidence bar; it does not require every planning, challenge,
  audit, or agent stage. Use `planner-agent` only when design remains unresolved
  or execution crosses a one-way door. Use `plan-checker` only when a
  current decision needs adversarial challenge, applying `AGENTS.md` §12's
  review budget and reopening rules.
- Use `security-reviewer-agent` only when the user explicitly requests a
  security review. Do not replace ordinary trust-boundary reasoning with a
  mandatory review chain.
- Require explicit user approval before destructive, irreversible, or
  public-contract-changing execution. Reversible, already-authorized work is
  not a waiting point.
- Apply Expand–Migrate–Contract only to an actual schema, event, persisted
  format, config, or public API migration. Use a short pre-mortem only for
  credible failure modes. Apply the Risk–Complexity Budget only when proposing
  retries, fallbacks, durable state, workers, leases, ACKs, or another runtime
  reliability mechanism.

## Change and test admission

- Apply AGENTS.md §3 change admission to the authorized behavior or migration.
- Do not add hashes, frozen contracts/baselines, manifests, ledgers, process
  gates, broad defensive branches, or fake infrastructure without direct
  production necessity.
- Prefer one or a few high-information checks. For production work, prioritize
  isolated real integration/end-to-end evidence. Do not add tests whose oracle
  is incidental prompt, source, log, heading, or generated-prose text.
- Verification must return to the requested runtime outcome. A plan, static
  audit, artifact inventory, or mock-only test is supporting evidence, not
  completion.

## Failure continuation

- Three failed attempts exhaust only the unchanged strategy or bounded worker
  packet. Preserve their evidence and stop repeating them.
- Never replay a consumed one-shot or duplicate a non-idempotent side effect.
  Use a fresh identity or revision only when new evidence supports it.
- If the authorized goal remains incomplete and new evidence supports a
  different safe in-scope hypothesis, partition, diagnostic, or revision,
  continue without requesting redundant permission.
- Overall `BLOCKED` requires missing authority/access, contradictory
  requirements, an unapproved irreversible action, unsafe execution, or proof
  that no safe outcome-relevant discriminating action remains.

## Routing and completion

- Exploration or localization: `explorer-agent`; repeated-failure causality
  that remains unresolved: `deep-investigator-agent`.
- Scoped implementation: `executor-agent` or `focused-fixer-agent` when truly
  localized.
- Dynamic commands: `verify-runner-agent`; independent static verification
  for risky or uncertain delegated edits: `verify-agent`. The parent owns
  final acceptance.
- Research or browser evidence only when current external or UI state is
  necessary.

Complete only when the requested behavior is delivered, relevant runtime
checks pass, the final diff is in scope, and remaining risk is stated. Report
`BLOCKED` only under the conditions above. A completed phase, commit, build,
image, artifact, review PASS, elapsed-time boundary, or intermediate receipt
is not final delivery while a safe, authorized, outcome-relevant next action
exists. Apply `AGENTS.md` §13's batch-yield and total-cost limits; a worker
or strategy stop does not by itself terminate the parent goal.
