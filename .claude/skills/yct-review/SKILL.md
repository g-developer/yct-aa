---
name: yct-review
description: Review-only workflow for diffs, PRs, branches, designs, plans, or implementations. Use for correctness, runtime wiring, regression risk, and meaningful test gaps.
argument-hint: [target]
disable-model-invocation: true
---

# YCT Review Mode

Target:
$ARGUMENTS

Do not implement unless explicitly requested.

- Name the decision or production risk the review must close. Use one suitable
  reviewer by default; add a second capability only when it answers a different
  unresolved question.
- Apply `AGENTS.md` §12's review budget and reopening rules to the current
  decision. Do not repeat an equivalent audit of unchanged evidence, and do not
  create a long static-audit or contract-review loop.
- Check goal match, real runtime wiring, partial/fake completion, regressions,
  Case quality, operations, and rollback only where relevant to the target.
- Use Bidirectional Traceability and Adjacency Scan for a non-trivial
  multi-surface contract or implementation, not as mandatory tables for every
  diff. Use Test Strategy Selection only when the changed input space requires
  it.
- Treat automated or agent findings as evidence to judge, not requirements.
  Before recommending retries, fallbacks, workers, durable state, gates, or
  protocol expansion, apply the Risk–Complexity Budget and prefer the smallest
  mechanism supported by product evidence.
- Do not block on wording, hashes, frozen artifacts, exhaustive matrices, or
  theoretical edge cases that cannot affect the requested production outcome.
- Prefer real integration/end-to-end evidence for production paths. A mock-only
  test or static audit does not establish runtime completion.

Routing: `code-reviewer-agent` for correctness and regression,
`verify-agent` for completion/wiring, `plan-checker` for an unresolved risky
design, `research-agent` for disputed external/versioned facts, and
`security-reviewer-agent` only when the user explicitly requests security
review.

Return: verdict, production-relevant findings by severity, evidence, smallest
fix, what was not checked, and remaining uncertainty. Partial inventory cannot
claim final acceptance.
