---
name: yct-review
description: Review-only workflow for diffs, PRs, branches, designs, plans, or implementations. Use for correctness, runtime wiring, regression risk, tests, and security review.
argument-hint: [target]
disable-model-invocation: true
---

# YCT Review Mode

Target:
$ARGUMENTS

Do not implement unless explicitly asked.

Review lenses:

- Goal match.
- Runtime wiring.
- Partial or fake completion.
- Regression risk.
- Missing tests.
- Security/data risk.
- Operational risk.
- Rollback risk.
- Steelman before challenge.
- Use Bidirectional Traceability and Adjacency Scan for non-trivial implementation or contract review.
- Counterexamples and concrete failure paths.
- Use Test Strategy Selection only when parser/refactor/security/concurrency/retry/combinatorial or another explicit test-strategy signal exists.

Routing:

- Use `code-reviewer-agent` for Steelman, traceability, adjacency, correctness, and maintainability.
- Use `security-reviewer-agent` for Trust Boundary, Abuse Cases, attack paths, and negative tests.
- Use `verify-agent` for bidirectional traceability, completion, wiring, and test-strategy verification.
- Use `plan-checker` for Steelman, counterexamples, Red Team, Pre-mortem/FMEA, and one-way-door challenges.
- Use `research-agent` for Evidence Triangulation when current or version-specific external behavior is disputed.

Final output:

- Verdict.
- Findings by severity.
- Evidence with file paths/symbols.
- Suggested fix.
- Forward trace matrix, Reverse trace matrix, and adjacency findings when triggered.
- Test-strategy adequacy when triggered.
- What was not checked.
- Residual uncertainty and the exact next evidence needed.

Model availability, fallback and budget:

- Capability probe: at session start, if account alias availability is unknown,
  the FIRST spawn of each pinned alias is the probe. Record results in a
  session model-availability table and consult it before every later spawn —
  an alias that failed once is never attempted again this session.
- Fallback chain: on a model/alias-unavailable spawn error, retry with an
  explicit per-call `model` override on the Agent tool, walking
  fable -> opus -> sonnet -> haiku -> inherit, ONE attempt per hop; report the
  tier actually used. Never claim the pinned alias ran after a downgrade;
  BLOCKED only after the chain is exhausted.
- Tier-by-criticality (hard rule): L0/L1 and ALL mechanical operations —
  polling, status reads, test execution, evidence formatting, file location,
  diff self-checks, trace updates — MUST take `haiku` or plain scripts, never
  opus/fable. L2 exploration/implementation/targeted review runs `sonnet`.
  ONLY architecture adjudication, adversarial plan review, conflict
  arbitration and final security audit may use opus/fable.
- Quality floor: adjudication roles (planner/plan-checker/verify/security/
  code-review/semantic) floor at `sonnet` — never auto-degrade adjudication to
  `haiku`; below the floor report BLOCKED instead (operator may explicitly
  authorize, recorded in the trace). Mechanical/recording roles may go to
  `haiku`; execution/exploration roles floor at `sonnet` unless the packet
  explicitly allows `haiku` for trivial mechanical slices.
- A top-tier round that adds no new evidence to the ledger is a routing
  defect: log it and downgrade the next similar round.
