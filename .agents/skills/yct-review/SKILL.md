---
name: yct-review
description: Review-only workflow. Explicitly invoke with $yct-review for PR, branch, diff, plan, or implementation review using suitable agents.
---

# YCT Review Mode

Target:
$ARGUMENTS

This is explicit authorization to spawn review-oriented subagents.

Do not implement unless explicitly requested.

Review lenses:

- Goal match, runtime wiring, partial/fake completion, regression, operations, and rollback.
- Steelman the stated intent before challenge.
- Use Bidirectional Traceability and Adjacency Scan for non-trivial implementation or contract review.
- Use Test Strategy Selection only when parser/refactor/security/concurrency/retry/combinatorial or another explicit test-strategy signal exists.
- Use counterexamples and concrete failure paths rather than generic objections.
- When a finding implies new reliability machinery, apply the Risk–Complexity Budget and classify it as `must-fix`, `observe-first`, or `documented-defer`; review findings are evidence to judge, not requirements by themselves.
- Judge runtime reliability mechanisms separately from cohesive behavior-preserving refactors that reduce net code complexity without adding protocol or operational state.

Spawn as appropriate:
- `code-reviewer-agent` for Steelman, Bidirectional Traceability, Adjacency Scan, correctness, regression risk, and missing tests.
- `verify-agent` for requirement→diff→test and diff→requirement traceability, completion, wiring, and fake-completion checks.
- `plan-checker` for Steelman, counterexamples, Red Team, Pre-mortem/FMEA, and one-way-door challenges.
- `security-reviewer-agent` for Trust Boundary, Abuse Cases, attack paths, and negative tests on sensitive surfaces.
- `research-agent` for Evidence Triangulation when versioned external behavior is disputed.

Return:
- Verdict.
- Findings by severity.
- Evidence.
- Suggested fix.
- Forward trace matrix, Reverse trace matrix, and adjacency findings when triggered.
- Test-strategy adequacy when triggered.
- Finding classification and mechanism-cost decision when triggered.
- What was not checked.
- Residual uncertainty and the exact next evidence needed.

Model availability, fallback and budget:

- Capability probe: at session start, if account model availability is unknown,
  probe once (CLI model list if the runtime exposes one; otherwise the FIRST
  spawn of each pinned tier is the probe). Record results in a session
  model-availability table and consult it before every later spawn — a model
  that failed once is never attempted again this session.
- Fallback chain: on a model-unavailable/entitlement error, walk the agent's
  `model_fallback_chain` from `.codex/agents/*.toml`
  (default gpt-5.6 -> gpt-5.6-terra -> gpt-5.6-luna), ONE attempt per hop;
  report the tier actually used. Never claim the pinned tier ran after a
  downgrade; BLOCKED only after the chain is exhausted.
- Tier-by-criticality (hard rule): L0/L1 and ALL mechanical operations —
  polling, status reads, test execution, evidence formatting, file location,
  migration-number checks, diff self-checks, trace updates — MUST take the
  lowest available tier or plain scripts, never a top-tier model. L2
  exploration/implementation/targeted review runs mid tier. ONLY architecture
  adjudication, adversarial plan review, conflict arbitration and final
  security audit may use the top tier.
- Quality floor: each agent may declare `model_floor`. Adjudication roles
  (planner/plan-checker/verify/security/code-review/semantic) floor at
  gpt-5.6-luna — a weak model rubber-stamping a review is worse than BLOCKED,
  so below the floor report BLOCKED instead of degrading silently; the
  operator may explicitly authorize a below-floor run, recorded in the trace.
  Execution/exploration roles floor at gpt-5.5 (independent verification
  guards them); mechanical roles may take the lowest available tier. Chain
  entries below an account's real catalog simply fail their hop and continue.
- A top-tier round that adds no new evidence to the ledger is a routing
  defect: log it and downgrade the next similar round.
