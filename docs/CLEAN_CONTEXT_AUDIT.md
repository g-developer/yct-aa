# Clean Context and Method Contract Audit v4.7

Date: 2026-07-10

## Verdict

STATIC PASS. LIVE MODEL DISPATCH NOT VERIFIED.

The packaged rules, method contracts, role registrations, model assignments, frontmatter, shortcut invocation policy, and installer simulations are internally consistent. A real fresh Codex/Claude session is still required to prove account entitlement, browser-tool availability, automatic role/method choice, and the model actually used by each spawned worker.

## Scope

The audit checked:

- shared criticality, routing precedence, clean-context, and verification rules;
- compact method triggers, detailed method ownership, and Codex/Claude paired-role method markers;
- Claude/Codex agent names, model tiers, permissions/sandboxes, and role overlap;
- all five explicit shortcut modes on both platforms;
- Codex role registration and existing-config merge behavior;
- installer fresh, repeat, warning, backup, malformed-marker, and dry-run paths;
- manifest completeness and the structure/coverage of an unexecuted 28-case routing/method fixture set.

## v4.7 closure

### Method selection and execution

- `AGENTS.md` owns a compact task-signal matrix; `docs/METHODS.md` is the single detailed contract owner.
- User-level installation copies the method owner to both Claude and Codex homes as `METHODS.yct.md`; installed rules do not depend on the source package path.
- Method selection happens before agent routing, and selected method/output contracts are included in clean-context packets.
- L0 work is protected from method ceremony. Fixtures are closed-world: every selected method needs prompt/task trigger evidence, and every catalog method not selected is forbidden until evidence is added.
- First Principles, MECE, Assumption/Invariant ledgers, PDCA, Pre-mortem/FMEA-lite, Steelman/Red Team, trust-boundary abuse cases, bidirectional traceability, ADR/reversibility, staged migration, test-strategy selection, OODA, triangulation, and double-loop learning have explicit triggers and outputs.
- Paired Codex/Claude role files statically contain the same required method-family markers for every method-bearing capability.
- Shortcut skills on both platforms select method contracts consistently for auto, risk, fix, and review modes.
- The shared Risk–Complexity Budget is enforced by paired planners, plan/code reviewers, executors, security reviewers, and verifiers: it keeps safety/product commitments mandatory, but prevents theoretical findings from silently creating durable state or protocol requirements.
- `evals/evals.json` contains criticality, route, selected methods, trigger evidence, closed-world non-method policy, and ordered gates; it remains an unexecuted fixture contract, not live-selection evidence.
- `docs/METHOD_EVAL.md` records two clean-context v4.6/v4.7 qualitative comparisons, the gaps found, revisions, and final re-evaluation boundaries.

### Routing and verification

- Risk-sensitive work now overrides focused-fix routing.
- Shared `AGENTS.md` uses abstract capabilities; platform files own concrete agent/model mappings.
- Delegated source edits require `verify-agent`; `verify-runner-agent` only supplies dynamic command evidence.
- Codex `yct-risk` now includes security review and an explicit L4 approval gate.
- Claude `yct-aa` now routes rule maintenance to `semantic-review-agent`, browser evidence to `browser-agent`, and does not substitute built-in Explore.
- Browser agents are read-only evidence collectors; static verifiers consume their evidence rather than reproducing UI interactions.

### Model routing

- Codex demanding roles use GPT-5.6.
- Codex fast portable roles use GPT-5.6 Terra.
- Codex focused fixes use `focused-fixer-agent` by default.
- Codex Spark remains an explicit, known-available ChatGPT Pro preview route with one fallback to the portable focused fixer.
- Claude uses Haiku/Sonnet/Opus by role, with optional per-invocation Fable escalation for justified L4 planning or plan challenge.
- Claude's L3 implementation route is explicitly Sonnet with stronger planning/security/verification around it.

### Invocation and clean context

- Claude shortcut skills set `disable-model-invocation: true`.
- Codex shortcut skills set `policy.allow_implicit_invocation: false` in `agents/openai.yaml`.
- Agent packets are the sole source of task-specific parent context, not a replacement for system/developer or applicable repository/platform rules.
- Claude agents no longer force background execution; dependency order decides foreground/background.
- Claude read-only roles use `permissionMode: plan` where supported.

### Installer safety

- Malformed, duplicated, reversed, or unclosed YCT marker blocks fail closed before the target file changes.
- Only the first pre-change state of a target is kept in a run's backup path, preventing later steps from overwriting the original backup.
- Backup run directories include the process ID in addition to the timestamp.
- Missing Codex role registrations are appended individually while existing same-name role tables and legal inline role registrations are preserved.
- Unsupported inline, dotted, quoted, or noncanonical `agents` declarations fail closed before any Codex target changes; convert them to canonical `[agents]` and `[agents."role"]` tables before installing.
- Existing role tables pointing somewhere other than the YCT agent file produce a warning.
- `agents.max_depth < 1` and `agents.max_threads < 2` produce explicit compatibility warnings.
- Different-path duplicate agent identities fail before guidance/config writes unless `--replace-conflicts` is explicit.
- Symlinked guidance, config, skill, and agent write targets are rejected rather than followed.
- Completion output lists all five shortcuts.

## Reproducible checks

Run:

```bash
tests/verify_pack.sh
```

The script performs:

- `bash -n install.sh`;
- Python 3.11 `tomllib` parsing through `uv run`;
- manifest-to-files comparison;
- strict release inventory comparison with no temporary-plan filename exemption;
- unique Claude/Codex agent names;
- Codex model and role-registration checks;
- Claude frontmatter, explicit-only skill, permission-mode, and no-forced-background checks;
- routing/method-contract presence, paired-role parity, method-ceremony limits, and unexecuted fixture coverage checks;
- fresh and repeated installation into temporary homes;
- optional local Codex config-load smoke through `codex debug prompt-input`;
- existing Codex config merge and warning checks, including unquoted, leading-indented, child-only, and inline existing role registrations;
- unsupported top-level inline, quoted-inline, and spaced-table agents declaration no-change behavior;
- child-only Codex role-table merge and explicit duplicate-identity conflict handling;
- malformed marker no-change behavior;
- symlinked guidance-target no-change behavior;
- preservation of the first original config backup;
- dry-run target-write checks.

## Residual limits

- No real `$yct-*` or `/yct-*` task was launched in a fresh installed session during this static audit.
- `evals/evals.json` is a prompt/expected-route fixture set, not evidence that a live model selected those routes correctly.
- Static method markers and fixtures do not prove a live model applied the method correctly; live smoke must inspect selected role, selected methods, actual outputs, and model metadata.
- GPT-5.3-Codex-Spark remains account/preview dependent.
- Claude aliases, effort levels, and `permissionMode` may be restricted by local version or organization policy; the runtime must report fallback/downgrade.
- Claude browser routing is conditional: the child profile must expose the browser tool or an allowed CLI. The pack intentionally does not guess local MCP names or hard-code a localhost endpoint.
- The installer remains user-level. Repository-local installation is manual and is not claimed as an automated feature.
- Same-path YCT assets are still replaced after backup by design; different-path identity replacement is explicit. There is no transactional uninstall command in v4.7.
- A future live smoke suite should record selected agent name, actual model metadata, tool/sandbox boundary, and verification closure for every shortcut on both platforms.
