---
name: yct-aa
description: Explicit auto-routing mode for non-trivial engineering tasks. Invoke with $yct-aa to classify risk, choose the smallest useful Codex subagent set, execute outcome-relevant work, and independently verify delegated source edits. Do not use for trivial direct work or review-only requests.
---

# YCT Auto-agent Mode

Task:
$ARGUMENTS

This is explicit authorization to spawn appropriate Codex subagents. Follow
`AGENTS.md` and `.codex/agents/*.toml`; this skill adds routing, not a second
governance system.

## Outcome-first rules

- Every action must either implement the requested production behavior,
  distinguish a current blocker, or verify a required outcome. Skip it when
  that contribution cannot be stated concretely.
- A proposed source change must satisfy all four conditions: the real
  production path needs it; it addresses the observed failure class through a
  general existing boundary rather than a one-off special case; the smallest
  meaningful behavioral coverage proves it; and existing Case quality is not
  weakened. Otherwise do not implement it.
- Choose the highest-ROI path: compare expected outcome gain with code,
  maintenance, review, and runtime-verification cost. Higher criticality
  requires better evidence, not more machinery.
- Do not introduce new hashes, frozen contracts or baselines, scope manifests,
  routing ledgers, process gates, retries/fallbacks, persistent state machines,
  or fake Docker/Compose-style harnesses unless the user requested them or
  direct production evidence proves the target cannot be met safely without
  them. A plan, handoff, or reviewer preference alone is not that evidence.
- When a plan or acceptance artifact conflicts with current runtime evidence,
  correct the artifact or approach. Do not build production code to satisfy a
  stale document. Plans, manifests, handoffs, hashes, and static counts do not
  replace the production outcome requested by the user.

## Test selection

- Before changing code or tests, classify the failure as product code, Case,
  data, or environment and capture the cheapest discriminating evidence.
- Prefer a small number of high-information checks. For production workflows,
  prefer isolated real integration/end-to-end execution over a large unit or
  fake-infrastructure matrix.
- Do not add a test whose only oracle is matching prompt text, source text,
  logs, headings, generated prose, or another incidental string. Domain string
  values are valid only when the value itself is observable behavior.
- Do not add tests for unobserved failure modes, target a test count, weaken an
  existing assertion, or replace a mature Case with an easier synthetic one.

## Process

1. Apply precedence: explicit mode, safety override, task shape, necessary
   phases, then verification.
2. Classify criticality and use the smallest sufficient agent set. Keep L0 and
   clear L1 work in the parent, including a bounded explicit local batch. If
   the failure, files, and real check are supplied, do not recast it as a
   discovery task or invoke analysis skills. An execution-only request with an
   exact entrypoint, inputs, and acceptance also stays in the parent; do not
   spawn an explorer merely to reread those inputs.
3. Select only methods triggered by current evidence. Method dumping is a
   routing defect; put each selected method and its required output in the
   responsible packet.
4. Explore only unresolved facts. An already-localized L1 gets one reproduction,
   one minimal edit, one real integration/E2E check, and one diff/status
   inspection; expand only on contradictory or new evidence. Before declaring
   a global blocker, trace the real production consumers and block only the
   affected subpath; an artifact or recovery precondition does not expand a
   configuration's product scope. Read authoritative input once; do not re-read,
   recount, stat, or diff it without contradictory or new evidence. Use an
   entrypoint's explicit scenario/time input directly; never add a wall-clock
   wait or rerun a successful side effect to repair wrapper/timing evidence.
5. For L3/L4 work, use only the planning, challenge, execution, and verification
   phases justified by one named current unresolved risk. Keep each decision to
   one complete challenge and at most one focused re-check. Once that risk is
   closed, stop static review and move to real integration/E2E or the production
   result; reopen only for new runtime evidence.
6. Give writers complete clean-context packets and non-overlapping ownership.
   Include the target behavior, production-path evidence, non-goals, allowed
   files, and the four change conditions above. Writers derive target members
   from the current authoritative input and confirm the absolute worktree before
   the first write; they do not hand-expand remainders or use a sibling checkout.
7. For genuinely batched work, carry a concise remainder and change/evidence
   delta. If the same remainder survives two receipts, stop or localize it;
   do not expand scope. Reuse a child only with a confirmed continuation
   handle. Reconcile an invalid writer delivery against the actual diff before
   another writer touches overlapping files.
8. Require a concise verification handoff from every writer and inspect the
   actual diff. A localized obvious edit may use parent inspection plus its real
   targeted check; use `verify-agent` for non-trivial, risky, or uncertain
   wiring. Run acceptance through the installed skill/product with the user's
   real entrypoint, working directory, and command-level environment/auth
   injection; a temporary runner or direct internal tool is diagnostic only.
   Dynamic evidence is valid only when the target Case was collected and not
   filtered out, the command reached a terminal state, and its framework
   summary plus real exit status were captured.
9. Continue approved, reversible work without asking for redundant permission.
   Three failed attempts exhaust only the unchanged strategy or bounded worker
   packet: preserve evidence and stop repeating it. If the goal remains
   incomplete and new evidence supports a different safe in-scope hypothesis,
   partition, or revision, continue. Overall `BLOCKED` requires a genuine
   authority decision, destructive/irreversible action, missing required
   access, contradictory requirements, or proof that no safe outcome-relevant
   discriminating action remains. Never replay a consumed one-shot. A commit,
   build, image, artifact, review PASS, elapsed-time boundary, or progress
   receipt is only a milestone: do not return a progress-only final while the
   requested outcome is incomplete and a safe, authorized, outcome-relevant
   next action exists.
10. Do not create process files beyond a required plan; create a handoff only
    when asked. Runtime caches from a required check are not process artifacts:
    report Git-visible residue once instead of starting a cleanup/debug loop.
    Never add new hashes or frozen manifests.

## Routing

- Exploration: `explorer-agent`.
- Planning: `planner-agent`; plan challenge: `plan-checker`.
- Focused implementation: `focused-fixer-agent`; bounded implementation:
  `executor-agent`; fast bounded iteration: `spark-agent` when applicable;
  mechanical edits: `batch-agent`.
- Repeated-failure forensics: `deep-investigator-agent` only when the new evidence still leaves causality unresolved.
- Dynamic verification: `verify-runner-agent`; static acceptance:
  `verify-agent`; correctness review: `code-reviewer-agent`.
- Security review: `security-reviewer-agent` only when the user explicitly
  requests it.
- Research: `research-agent`; browser evidence: `browser-agent`.
- Rule maintenance: `semantic-review-agent` only for an unresolved cross-file semantic conflict that current evidence cannot close; confirmed documentation:
  `docs-agent`; confirmed status records: `alignment-recorder-agent`.
- Small read-only fallback only when no specialized route fits:
  `general-agent`.

Use the Risk–Complexity Budget only when a proposal adds runtime reliability
machinery. A theoretical failure is not a product requirement. Prefer the
existing safe failure mode or observation when it already meets the product
commitment.

When a subagent is actually required, call spawn before any wait and retain the
returned child thread/agent ID. Without a confirmed non-empty child ID, never
call wait; continue in the parent only when the route remains safe, otherwise
report the tool failure. Do not simulate a delegated result.

Final response: conclusion, changed files, verification, and remaining risk.
