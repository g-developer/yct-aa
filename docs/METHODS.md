# Engineering Method Selection and Execution

Version: v4.7

This is the detailed method owner for the YCT agent pack. `AGENTS.md` owns only the compact trigger matrix. Platform skills select roles, and role files turn the selected methods into concrete output contracts.

The objective is better decisions and evidence, not more headings. Use a method only when its trigger is present. Combining two methods is useful when they answer different questions; applying the whole catalog to every task is a routing defect.

## 1. First Principles with Assumption and Invariant Ledgers

Use for ambiguous architecture, L3/L4 work, disputed fundamentals, or a plan built on uncertain premises.

Required output:

```text
Goal:
Current reality:
Verified facts:
Assumption ledger:
  - Assumption / Why it matters / Evidence / Confidence / How to falsify / What breaks if wrong
Constraints:
Invariant ledger:
  - Invariant / Where enforced / How verified / Risk if broken
Non-goals:
Minimal solution:
Rejection criteria:
```

Rules:

- Start from current code, runtime, tests, and user constraints—not from the proposed solution.
- Low-confidence assumptions may guide reversible experiments, not irreversible decisions.
- Rejection criteria must describe evidence that would prove the preferred approach wrong.
- Do not create an abstraction unless it removes observed duplication or isolates demonstrated volatility.

## 2. MECE Decomposition

Use for L2+ work when the impact surface overlaps or important residue could be missed.

Choose and name one primary lens:

- lifecycle: explore, plan, implement, verify, document, operate;
- boundary: client, API, domain, persistence, infrastructure, tests;
- risk: correctness, compatibility, security, performance, operations, recovery;
- evidence: code, tests, runtime, config/schema, external sources.

Required output:

```text
Lens:
Scopes:
Dependencies/order:
Deliberate cross-checks:
Uncovered residue:
```

Do not call a list MECE when scopes overlap accidentally. Cross-cutting verification is allowed when labeled as a second lens.

## 3. Hypothesis–Falsification Debugging

Use when the root cause is unknown, multiple causes fit the symptoms, or a previous fix failed.

Required table:

| Observation | Hypothesis | Predicted evidence | Falsifying evidence | Cheapest discriminating check | Result | Confidence update |
|---|---|---|---|---|---|---|

Rules:

- Separate symptom, proximate cause, and root cause.
- Prefer checks that distinguish between hypotheses over checks that merely collect more data.
- Modify code only after evidence narrows the cause, unless the change is an explicitly reversible diagnostic experiment.
- After three distinct failed strategies, stop and reassess the abstraction and missing evidence.

## 4. PDCA and Test-First Implementation

Use internally for L1+ implementation:

- Plan: goal, constraints, non-goals, minimal change, verification.
- Do: one cohesive change; add a failing behavioral test first when practical.
- Check: targeted tests, diff inspection, wiring, negative path, unrelated changes.
- Act: finalize, correct the approach, or stop with a blocker.

Do not expose PDCA headings to the user unless requested. The method controls the work loop; it is not a reporting template.

For behavior-preserving refactors without adequate tests, add characterization tests before restructuring. A characterization test records current observable behavior; it is not proof that the behavior is desirable.

## 5. Pre-mortem and FMEA-lite

Use before L3/L4 execution, migrations, concurrency/cache changes, and production behavior changes.

First ask: `Assume this shipped and caused a serious failure. What credible path produced it?`

Convert answers into:

| Failure mode | Cause | Effect | Severity | Likelihood | Detectability | Existing control | Required mitigation/test | Recovery |
|---|---|---|---|---|---|---|---|---|

Use qualitative ratings unless the project already defines numeric scoring. Generic risks without a plausible path are noise. Every blocker/high failure mode needs prevention, detection, and recovery evidence.

## 6. Steelman, Counterexample, and Red Team

Use for plan challenge, architecture review, security review, and consequential code review.

Sequence:

1. Steelman: restate the strongest version of the goal, constraints, and proposed mechanism.
2. Identify proof obligations and hidden assumptions.
3. Search for counterexamples: boundary input, stale data, partial deploy, retry, concurrency, unauthorized actor, dependency failure.
4. Red-team concrete failure/exploit paths.
5. Offer the smallest safer or more reversible alternative.

Do not attack a weaker plan than the one actually proposed. Do not manufacture generic objections merely to appear adversarial.

## 7. Trust Boundaries, Abuse Cases, and Attack Paths

Use for auth, authorization, secrets, payments, uploads, injection, tenant isolation, cryptography, and sensitive data access.

The Trust Boundary + Abuse Cases contract starts from the actual actor-to-side-effect path, not a generic vulnerability checklist.

Required model:

```text
Actor/capability:
Protected asset:
Entrypoint:
Trust boundary crossed:
Authentication/authorization decision:
Side effect:
Abuse case:
Detection and response:
```

For multi-step attacks, write the attack path as prerequisites → boundary crossings → side effect. Check fail-open behavior, replay/idempotency, confused-deputy paths, cross-tenant references, grandfathered data, and secret leakage. STRIDE labels may help discovery but never replace a code-grounded exploit scenario.

Run the security method twice when a sensitive plan changes a trust boundary: pre-execution against the current boundary and proposed mechanism, then post-implementation against the real diff and negative-test evidence. Blocker/high findings block completion; any lower finding that breaks the goal or an invariant also blocks. Security recovery must not revert to a known exploitable state.

## 8. Bidirectional Traceability and Adjacency Scan

Use for non-trivial implementation and review.

Forward trace:

| Requirement ID | Required behavior | Diff evidence | Tests | Verdict |
|---|---|---|---|---|

Reverse trace:

| Changed surface | Requirement/approval | Why needed | Tests | Scope verdict |
|---|---|---|---|---|

Then scan:

- upstream producers and callers;
- downstream consumers and persisted/wire shapes;
- sibling implementations of the same pattern;
- old tests and fixtures that lock prior behavior;
- config, registration, migration, deployment, and operational wiring.

This catches both missing implementation and unapproved scope drift.

## 9. One-way/Two-way Doors and ADRs

Classify consequential decisions:

- Two-way door: cheap to reverse, contained blast radius, no durable external contract. Prefer a small experiment and measured feedback.
- One-way door: schema/data rewrite, public API, security model, dependency/platform lock-in, irreversible operation, or costly coordinated rollback. Require explicit alternatives, approval, and recovery analysis.

Create an ADR only when the decision is likely to recur or constrain future work. ADR fields:

```text
Status and date:
Context/evidence:
Decision:
Alternatives considered:
Consequences/tradeoffs:
Reversal or expiry condition:
Owner/source:
```

Do not create ADRs for small local implementation choices.

## 10. Expand–Migrate–Contract

Use for schemas, public APIs, event formats, persisted artifacts, and configuration migrations.

1. Expand: add backward-compatible readers/writers or fields.
2. Migrate: move callers/data, observe progress, verify old and new behavior.
3. Contract: remove the old path only after evidence shows no live dependency and rollback is no longer needed.

Required decisions:

- compatibility and coexistence window;
- dual-read/dual-write ownership and idempotency;
- old-data handling;
- migration progress signal;
- rollback point for each stage;
- proof required before contract/removal.

Never combine destructive contract/removal with the first expand deployment unless the system is explicitly offline and recovery is proven.

## 11. Test Strategy Selection

Choose tests by uncertainty, not habit:

| Situation | Preferred technique | What it proves |
|---|---|---|
| Known input/output behavior | Example-based behavioral test | Named contract examples |
| Existing behavior must survive refactor | Characterization test | Observed compatibility baseline |
| Large/combinatorial input space | Property-based test | Invariants across generated cases |
| No simple oracle but transformations have known relations | Metamorphic test | Relational correctness |
| Persisted/wire/schema change | Compatibility and migration test | Old/new coexistence and data readability |
| Retry, timeout, network, concurrency, cache | Fault injection and deterministic scheduling where possible | Failure/recovery behavior |
| Auth/data/trust boundary | Negative and abuse-case test | Forbidden behavior is rejected |
| Tests may be too coupled or vacuous | Mutation testing when cost permits | Tests detect meaningful defects |

Do not add property or mutation tooling when the repository lacks it unless the benefit justifies the dependency. A precise deterministic loop may be the simpler equivalent.

## 12. OODA for Active Incidents

Use only when runtime state is changing faster than a normal plan cycle.

```text
Observed at:
Observation/source:
Orientation and uncertainty:
Reversible decision:
Action:
Expected signal:
Next check/deadline:
Stop/rollback threshold:
```

Refresh state before every status claim. Prefer reversible containment before root-cause repair. Once the incident is stable, return to hypothesis-driven debugging and PDCA.

## 13. Evidence Triangulation

Use for external/versioned claims and conflicting evidence.

- Prefer current runtime/repo evidence.
- Match official documentation to the exact version.
- Compare independent primary sources when one source cannot establish behavior.
- Record agreement and disagreement; do not average conflicting claims.
- Treat social/forum claims as leads unless corroborated.

Output: claim, source/date/version, direct support, conflict, inference, confidence, next verification.

## 14. Double-loop Learning

Use when a defect recurs, the same review finding returns, routing repeatedly misfires, or instructions produce systematic waste.

- Single loop: repair the immediate output or behavior.
- Double loop: identify and correct the underlying assumption, routing rule, role boundary, missing feedback signal, or test gap that allowed recurrence.

Required output:

```text
Immediate defect and correction:
Why existing controls missed it:
Underlying rule/assumption to change:
Regression signal/test:
Owner and review/expiry condition:
```

Do not turn every bug into governance work. Trigger double-loop learning only with recurrence or clear systemic evidence.

## 15. Risk–Complexity Budget and Observability-First Reliability

Use when a plan, fix, or review proposes new retries/fallbacks, durable state, recovery workers, leases/heartbeats, cache-consistency behavior, ACKs, tables/fields, or other runtime protocol machinery. The objective is the smallest mechanism that satisfies current product promises, not theoretical completeness.

Required decision record:

| Field | Required evidence |
|---|---|
| Commitment | Exact product promise, SLO, safety invariant, or upstream obligation |
| Scenario | Failure path and deployment assumptions |
| Probability/impact | Production, load/fault-test, or protocol evidence; blast radius |
| Current convergence | Timeout, terminal state, fail-fast, user retry, or operational recovery |
| Simplest failure | Acceptable behavior without the new mechanism and why it is insufficient |
| Mechanism cost | New states/transitions, storage/schema, migration, worker, config, monitoring, tests, ownership |
| Observation | Activation signal and whether instrumentation should come first |
| Decision | `must-fix` / `observe-first` / `documented-defer` plus residual risk and best-effort boundary |
| Lifecycle | Rollback, review trigger, expiry/removal condition |

Rules:

- Probability never excuses authorization failure, cross-tenant impact, irreversible data damage, duplicate non-idempotent side effects, or permanent/unbounded blocking.
- Handle explicit SLO/product behavior, expected rolling/reconnect/timeout paths, evidence-backed failures, and cheap local boundary fixes.
- Normally defer an evidence-free scenario requiring multiple independent unlikely failures outside stated assumptions when existing convergence is observable and safe.
- A review finding is a hypothesis to classify, not a requirement. Tests lock promised behavior; extreme tests do not create new product promises.
- When evidence is absent and harm is bounded, add a cheap signal before a recovery protocol. Instrumentation must have an owner, decision threshold, and review date.
- Retries require one owning layer, bounded attempts/deadline, observable exhaustion, and idempotency for side effects. Avoid stacked retries whose combined budget is unknown.
- Count state-machine and operational surface, not only lines of code. A small diff can create a large permanent support burden.
- Evaluate reliability machinery separately from code-quality refactoring. Keep a cohesive behavior-preserving refactor when it adds no runtime/protocol/operational state and demonstrably lowers net complexity; split unrelated churn or abstraction without a net reduction.

## Role mapping

| Role capability | Primary methods |
|---|---|
| Explorer / focused fixer | Hypothesis–Falsification; OODA for active incidents |
| Planner | First Principles; MECE; ledgers; One-way/Two-way; Pre-mortem/FMEA; Risk–Complexity Budget; Expand–Migrate–Contract |
| Plan checker | Steelman; Counterexamples; Red Team; FMEA and mechanism-admission challenge |
| Executor | PDCA/test-first; requirement traceability; characterization; approved reliability/migration stage |
| Code reviewer / verifier | Bidirectional Traceability; Adjacency Scan; Test Strategy Selection; finding classification |
| Security reviewer | Trust Boundaries; Abuse Cases; Attack Paths; negative tests |
| Researcher | Evidence Triangulation |
| Docs / alignment recorder | ADRs; evidence-qualified decision/status records |
| Semantic reviewer | Double-loop Learning; method over-trigger/under-trigger review |

## Anti-patterns

- Method dumping: listing every framework without selecting by task signal.
- Cargo-cult headings: output sections exist but contain no evidence.
- Fake MECE: overlapping scopes with hidden residue.
- Confirmation-only debugging: tests that can only support the preferred hypothesis.
- Risk register without action: failure modes have no prevention, detection, test, or recovery.
- Reliability maximalism: turning every theoretical review counterexample into durable state, retries, workers, or protocol surface without a product promise or evidence.
- Diff minimalism: removing a cohesive complexity-reducing refactor solely to shrink the patch while retaining duplicated or unclear code.
- ADR spam: recording reversible local choices as architecture decisions.
- Premature contract: removing compatibility before migration evidence exists.
- Review tunnel vision: tracing requirements forward but never mapping diff back to authorization.
- Process substitution: governance documents replacing runtime fixes and regression tests.
