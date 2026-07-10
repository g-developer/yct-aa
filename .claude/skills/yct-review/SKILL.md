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
