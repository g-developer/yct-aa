---
paths:
  - "**/*"
---

# Claude Method Orchestration

`AGENTS.md` owns method triggers. `docs/METHODS.md` in the package/repository, installed as `METHODS.yct.md` for user-level use, owns detailed contracts. This file maps those contracts to Claude roles without redefining them.

## Selection rules

- Select methods from the task signal before selecting agents. Use only methods that change the decision, evidence, or verification quality.
- Put selected method names and required outputs into the clean-context packet. Do not assume a child infers the method from criticality alone.
- Do not invoke a full method chain by ritual. L0 work normally needs none; L1 usually needs PDCA and possibly Hypothesis–Falsification; L3/L4 selects the relevant risk methods.

## Role mapping

- `explorer-agent`, `focused-fixer-agent`: Hypothesis–Falsification; OODA only for active incidents.
- `planner-agent`: First Principles, MECE, ledgers, One-way/Two-way Doors, Pre-mortem/FMEA-lite, Expand–Migrate–Contract.
- `plan-checker`: Steelman, counterexamples, Red Team, FMEA challenge, reversibility challenge.
- `executor-agent`: PDCA/test-first, characterization tests, requirement traceability, approved migration stage.
- `code-reviewer-agent`, `verify-agent`: Bidirectional Traceability, Adjacency Scan, Test Strategy Selection.
- `security-reviewer-agent`: Trust Boundary, Abuse Cases, attack paths, negative tests.
- `research-agent`: Evidence Triangulation.
- `docs-agent`, `alignment-recorder-agent`: ADR and evidence-qualified decision/status records.
- `semantic-review-agent`: Double-loop Learning and method over-trigger/under-trigger review.

## Quality gate

- The parent verifies that method outputs are evidence-bearing, not empty headings.
- A child returning only method names without the required fields is incomplete.
- When evidence is missing, report the missing observation or decision instead of silently downgrading the method.
