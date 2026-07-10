# Method Contract Qualitative Evaluation

Date: 2026-07-10

## Scope and boundary

Two clean-context read-only comparisons evaluated the v4.7 candidate against the v4.6 pack. Workers read only the named pack files and produced routing/method contracts; they did not implement business code or run real Claude/Codex shortcut dispatch.

This evaluation answers: `Does the pack expose a more explicit, evidence-bearing method contract for the same prompt?` It does not prove account entitlement, actual model selection, live trigger accuracy, or runtime tool availability.

## Case 1: authorization bypass

Prompt:

```text
$yct-aa fix an authorization bypass in the workspace admin endpoint
```

### v4.6 baseline

Verdict: `PARTIAL`.

The baseline selected the safe L3 route and appropriate planner/checker/executor/security/verifier roles, but important method contracts were scattered or implicit:

- no centralized method-selection matrix;
- MECE absent from the Codex path;
- first-principles output omitted parts of the shared contract;
- no formal assumption/invariant ledgers;
- pre-mortem had no role owner/output;
- trust-boundary/abuse-case analysis was implicit;
- no explicit security finding closure or composite final gate;
- runner/verifier ordering and plan re-review were ambiguous.

### v4.7 candidate and iteration

The first v4.7 pass selected explicit First Principles, MECE, ledgers, Pre-mortem/FMEA-lite, Steelman/Red Team, Trust Boundary/Abuse Cases, Test Strategy Selection, PDCA, and Bidirectional Traceability with role owners and outputs.

The evaluator found five concrete gaps. They were fixed and regression markers were added:

1. security review now occurs before a sensitive boundary change and after the real diff;
2. blocker/high security findings block, and lower findings block when they violate goal/invariants;
3. security/data boundaries explicitly trigger Test Strategy Selection;
4. `ACCEPT_WITH_CHANGES` requires plan revision and re-review before L3/L4 execution;
5. recovery may not restore a known exploitable or data-corrupting state.

Additional closure added during the same iteration:

- composite gate: revised plan accepted + security findings resolved + required runner checks pass + final verifier pass;
- parent ownership of `IMPLEMENTATION_PLAN.md` lifecycle;
- runner evidence precedes final static acceptance.

Final re-evaluation: `7/7 PASS` for the requested closure checks.

## Case 2: unknown Unicode parser failure space

Prompt:

```text
$yct-fix the parser fails on a few Unicode inputs but we do not know the full failing space
```

### v4.6 baseline

Verdict: `PARTIAL`.

The baseline correctly avoided immediate focused writing and could route through exploration, but it lacked explicit contracts for:

- hypothesis/falsifier/experiment/result tracking;
- parser/combinatorial Test Strategy Selection;
- property/metamorphic test choice and oracle/invariant declaration;
- deterministic corpus/seed/reproduction considerations;
- a precise gate for returning from diagnostic routing to focused fixing.

### v4.7 candidate and iteration

The initial v4.7 candidate selected Hypothesis–Falsification and Test Strategy Selection, but the evaluator found two timing gaps:

- test strategy was visible to the final verifier but not mandatory before the writer;
- ambiguous `yct-fix` escalation did not define an exact explorer-only diagnostic stage and return gate.

The contracts now require:

- immediate diagnostic orchestration when root cause/files/input/oracle/command are missing;
- `explorer-agent` only, with no other agent or writer at the first stage;
- return to focused fixing only after evidence localizes the cause, scope is normally one to three files, risk remains L1/L2, and a targeted command is known;
- before writing: invariant/oracle, selected test technique, and rejected alternatives;
- runner-before-verifier ordering.

The first regression-harness revision was rejected because it checked loose markers rather than the full semantics. Exact assertions and a structured fixture gate list were added for diagnostic-first, explorer-only, no-writer, focused-return evidence, test-strategy-before-writer, and runner-before-verifier.

Final re-evaluation: `PASS` for both implementation contracts and regression locks.

## Evaluation conclusion

The selected cases show a material improvement over v4.6: v4.7 does not merely name more methods; it assigns triggers, owners, required output fields, execution order, stop conditions, and regression assertions. The final fixture schema also records criticality, route, method-specific trigger evidence, closed-world forbidden methods, and ordered gates per case.

Remaining limits:

- only two qualitative with-pack/baseline scenarios were independently compared;
- the 24 JSON fixtures are static contracts and were not dispatched through fresh installed Claude/Codex sessions;
- no token/time benchmark was captured;
- live smoke must still record actual shortcut, role, selected methods, model metadata, tools/sandbox, and verification closure.
