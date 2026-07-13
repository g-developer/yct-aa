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
- What was not checked.
- Residual uncertainty and the exact next evidence needed.

Model availability, fallback and budget:

- Role model pins are ceilings, not guarantees. If an agent spawn fails with a
  model-unavailable/entitlement error, retry ONCE with that agent's
  `model_fallback` from `.codex/agents/*.toml` (default `gpt-5.6-terra`), then
  report the downgrade in the final answer. Never retry the same unavailable
  model, and never claim the pinned tier ran after a downgrade.
- Remember availability for the rest of the session: after one failure of a
  pinned model, spawn later agents of that tier directly on the fallback.
- Within a role's ceiling, pick the model by task complexity and remaining
  budget: an L2 plan may run on the fallback tier; reserve top-tier spend for
  L3/L4 adjudication, adversarial review and security.
