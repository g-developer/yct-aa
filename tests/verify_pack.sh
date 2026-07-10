#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$ROOT/install.sh"

uv run --python 3.11 python - "$ROOT" <<'PY'
import json
import pathlib
import re
import sys
import tomllib

root = pathlib.Path(sys.argv[1])
errors: list[str] = []


def check(condition: bool, message: str) -> None:
    if not condition:
        errors.append(message)


def frontmatter(path: pathlib.Path) -> dict[str, str]:
    lines = path.read_text(encoding="utf-8").splitlines()
    check(bool(lines) and lines[0] == "---", f"missing frontmatter start: {path}")
    try:
        end = lines.index("---", 1)
    except ValueError:
        errors.append(f"missing frontmatter end: {path}")
        return {}
    result: dict[str, str] = {}
    for line in lines[1:end]:
        if ":" not in line or line.startswith((" ", "\t")):
            continue
        key, value = line.split(":", 1)
        result[key.strip()] = value.strip().strip('"\'')
    return result


manifest_lines = (root / "MANIFEST.txt").read_text(encoding="utf-8").splitlines()
manifest = {
    line[2:]
    for line in manifest_lines[manifest_lines.index("## Files") + 1 :]
    if line.startswith("- ")
}
actual = {
    path.relative_to(root).as_posix()
    for path in root.rglob("*")
    if path.is_file()
    and path.name != ".DS_Store"
    and ".git" not in path.relative_to(root).parts
}
check(manifest == actual, f"manifest drift: missing={sorted(actual - manifest)} extra={sorted(manifest - actual)}")

codex_agents: dict[str, dict] = {}
for path in sorted((root / ".codex/agents").glob("*.toml")):
    try:
        data = tomllib.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"invalid TOML {path}: {exc}")
        continue
    name = data.get("name")
    check(isinstance(name, str) and bool(name), f"missing Codex agent name: {path}")
    if isinstance(name, str):
        check(name not in codex_agents, f"duplicate Codex agent name: {name}")
        codex_agents[name] = data
    check("sole source of task-specific facts" in data.get("developer_instructions", ""), f"stale clean-context wording: {path}")
    if data.get("sandbox_mode") == "workspace-write" and name != "verify-runner-agent":
        check("verification handoff" in data.get("developer_instructions", "").lower(), f"write-capable Codex agent lacks handoff: {path}")

expected_codex_models = {
    "alignment-recorder-agent": "gpt-5.6-terra",
    "batch-agent": "gpt-5.6-terra",
    "browser-agent": "gpt-5.6",
    "code-reviewer-agent": "gpt-5.6",
    "docs-agent": "gpt-5.6-terra",
    "executor-agent": "gpt-5.6",
    "explorer-agent": "gpt-5.6-terra",
    "focused-fixer-agent": "gpt-5.6-terra",
    "general-agent": "gpt-5.6-terra",
    "plan-checker": "gpt-5.6",
    "planner-agent": "gpt-5.6",
    "research-agent": "gpt-5.6-terra",
    "security-reviewer-agent": "gpt-5.6",
    "semantic-review-agent": "gpt-5.6",
    "spark-agent": "gpt-5.3-codex-spark",
    "verify-agent": "gpt-5.6",
    "verify-runner-agent": "gpt-5.6-terra",
}
check(set(codex_agents) == set(expected_codex_models), "Codex agent set differs from model contract")
for name, model in expected_codex_models.items():
    check(codex_agents.get(name, {}).get("model") == model, f"wrong Codex model for {name}")

method_contracts = {
    "explorer-agent": ("Hypothesis–Falsification", "OODA"),
    "focused-fixer-agent": ("Hypothesis–Falsification", "PDCA", "characterization test", "Test Strategy Selection", "invariant/oracle", "rejected alternatives"),
    "planner-agent": ("First Principles", "MECE", "Assumption ledger", "Invariant ledger", "one-way door", "FMEA-lite", "Expand–Migrate–Contract", "Minimal solution", "Rejection criteria", "Selected methods: method, trigger evidence, required output, gate/stop condition"),
    "plan-checker": ("Steelman", "counterexamples", "Red Team", "FMEA-lite", "one-way doors", "ACCEPT_WITH_CHANGES", "revised plan challenged again"),
    "executor-agent": ("PDCA", "characterization tests", "requirement-to-diff-to-test", "Expand–Migrate–Contract"),
    "code-reviewer-agent": ("Steelman", "Bidirectional Traceability", "Adjacency Scan", "counterexamples", "Forward trace matrix", "Reverse trace matrix"),
    "verify-agent": ("Bidirectional Traceability", "Adjacency Scan", "Test Strategy Selection", "Expand–Migrate–Contract", "one-way door", "Forward trace matrix", "Reverse trace matrix"),
    "security-reviewer-agent": ("Trust Boundary", "Abuse Cases", "attack path", "negative test", "pre-execution boundary", "post-implementation diff", "Blocker/high findings", "Detection and response"),
    "research-agent": ("Evidence Triangulation", "conflicting"),
    "semantic-review-agent": ("Double-loop Learning", "over-triggering", "under-triggering", "Why existing controls missed it", "Owner and review/expiry condition"),
    "docs-agent": ("ADR", "reversal or expiry condition", "Expand–Migrate–Contract"),
    "alignment-recorder-agent": ("reversibility class", "Double-loop Learning", "regression signal"),
}
for name, markers in method_contracts.items():
    codex_text = codex_agents.get(name, {}).get("developer_instructions", "")
    for marker in markers:
        check(marker in codex_text, f"Codex {name} misses method contract marker: {marker}")

config = tomllib.loads((root / ".codex/config.toml").read_text(encoding="utf-8"))
roles = config.get("agents", {})
for name in expected_codex_models:
    role = roles.get(name)
    check(isinstance(role, dict), f"missing Codex role registration: {name}")
    if isinstance(role, dict):
        check(role.get("config_file") == f"agents/{name}.toml", f"wrong config_file for {name}")

claude_agents: dict[str, dict[str, str]] = {}
read_only_claude = {
    "browser-agent",
    "code-reviewer-agent",
    "explorer-agent",
    "general-agent",
    "plan-checker",
    "planner-agent",
    "research-agent",
    "security-reviewer-agent",
    "semantic-review-agent",
    "verify-agent",
}
for path in sorted((root / ".claude/agents").glob("*.md")):
    meta = frontmatter(path)
    name = meta.get("name")
    check(bool(name), f"missing Claude agent name: {path}")
    if name:
        check(name not in claude_agents, f"duplicate Claude agent name: {name}")
        claude_agents[name] = meta
        if name in read_only_claude:
            check(meta.get("permissionMode") == "plan", f"read-only Claude agent lacks plan permission mode: {name}")
    check("background" not in meta, f"Claude agent forces background execution: {path}")
    check("sole source of task-specific facts" in path.read_text(encoding="utf-8"), f"stale clean-context wording: {path}")
    tools = {item.strip() for item in meta.get("tools", "").split(",") if item.strip()}
    check("Agent" not in tools, f"worker can recursively orchestrate: {path}")
    if tools.intersection({"Edit", "Write"}):
        check("verification handoff" in path.read_text(encoding="utf-8").lower(), f"write-capable Claude agent lacks handoff: {path}")

for name, markers in method_contracts.items():
    path = root / ".claude/agents" / f"{name}.md"
    check(path.exists(), f"missing Claude method role: {name}")
    if path.exists():
        text = path.read_text(encoding="utf-8")
        for marker in markers:
            check(marker in text, f"Claude {name} misses method contract marker: {marker}")

for platform in (".agents/skills", ".claude/skills"):
    for skill_dir in sorted((root / platform).glob("yct-*")):
        skill = skill_dir / "SKILL.md"
        check(skill.exists(), f"missing skill file: {skill_dir}")
        if not skill.exists():
            continue
        meta = frontmatter(skill)
        check(meta.get("name") == skill_dir.name, f"skill name/path mismatch: {skill}")
        if platform == ".claude/skills":
            check(meta.get("disable-model-invocation") == "true", f"Claude shortcut is not explicit-only: {skill}")
        else:
            policy = skill_dir / "agents/openai.yaml"
            check(policy.exists(), f"missing Codex invocation policy: {skill_dir}")
            if policy.exists():
                check("allow_implicit_invocation: false" in policy.read_text(encoding="utf-8"), f"Codex shortcut is not explicit-only: {skill_dir}")

codex_aa = (root / ".agents/skills/yct-aa/SKILL.md").read_text(encoding="utf-8")
for required in ("security-reviewer-agent", "semantic-review-agent", "browser-agent", "verify-agent", "verify-runner-agent", "docs-agent", "alignment-recorder-agent", "general-agent"):
    check(required in codex_aa, f"Codex yct-aa misses route {required}")
claude_aa = (root / ".claude/skills/yct-aa/SKILL.md").read_text(encoding="utf-8")
check("`CLAUDE.md` is the single owner" in claude_aa, "Claude yct-aa duplicates or loses its route owner")
check("verify-agent" in claude_aa and "verify-runner-agent" in claude_aa, "Claude yct-aa misses verification closure")
check("Never call wait with an empty receiver set" in codex_aa and "child thread/agent ID" in codex_aa, "Codex yct-aa misses fail-closed spawn/wait guard")
check("successful `Task` result" in claude_aa and "do not simulate the child" in claude_aa, "Claude yct-aa misses fail-closed Task identity guard")
for aa_path in (root / ".agents/skills/yct-aa/SKILL.md", root / ".claude/skills/yct-aa/SKILL.md"):
    text = aa_path.read_text(encoding="utf-8")
    check("method dumping is a routing defect" in text, f"auto-router does not prevent method ceremony: {aa_path}")
    check("selected method" in text, f"auto-router does not pass method contracts to workers: {aa_path}")
    check("runner results as evidence" in text, f"auto-router does not order dynamic evidence before final static acceptance: {aa_path}")

skill_method_markers = {
    "yct-risk": ("First Principles", "MECE", "FMEA-lite", "Trust Boundary", "Expand–Migrate–Contract", "Test Strategy"),
    "yct-fix": ("Hypothesis–Falsification", "PDCA", "characterization", "Test Strategy Selection", "invariant/oracle", "Return to"),
    "yct-review": ("Steelman", "Bidirectional Traceability", "Adjacency Scan", "Evidence Triangulation"),
}
for skill_name, markers in skill_method_markers.items():
    for platform in (".agents/skills", ".claude/skills"):
        path = root / platform / skill_name / "SKILL.md"
        text = path.read_text(encoding="utf-8")
        for marker in markers:
            check(marker in text, f"{platform} {skill_name} misses method marker: {marker}")
for platform in (".agents/skills", ".claude/skills"):
    risk_text = (root / platform / "yct-risk/SKILL.md").read_text(encoding="utf-8")
    for marker in ("pre-execution", "again after implementation", "Completion gate", "runner checks `PASS`", "verify-agent` `PASS`"):
        check(marker in risk_text, f"{platform} yct-risk misses composite gate marker: {marker}")

for platform in (".agents/skills", ".claude/skills"):
    review_text = (root / platform / "yct-review/SKILL.md").read_text(encoding="utf-8")
    for marker in (
        "Steelman",
        "Bidirectional Traceability",
        "Test Strategy Selection only when",
        "Forward trace matrix",
        "Reverse trace matrix",
        "Residual uncertainty and the exact next evidence needed",
    ):
        check(marker in review_text, f"{platform} yct-review misses shared review semantic: {marker}")

for platform in (".agents/skills", ".claude/skills"):
    fix_path = root / platform / "yct-fix/SKILL.md"
    fix_text = fix_path.read_text(encoding="utf-8")
    for marker in (
        "immediately",
        "start with `explorer-agent` only",
        "do not start any other agent or writer",
        "evidence localizes the cause",
        "one to three files",
        "risk remains L1/L2",
        "targeted command is known",
        "Before writing",
        "selected technique",
        "rejected alternatives",
        "runner results as evidence",
    ):
        check(marker in fix_text, f"{platform} yct-fix misses diagnostic/write gate marker: {marker}")
    runner_pos = fix_text.find("verify-runner-agent")
    verifier_pos = fix_text.find("verify-agent", runner_pos + 1)
    check(runner_pos >= 0 and verifier_pos > runner_pos, f"{platform} yct-fix does not order runner before verifier")

for direct_path in (root / ".agents/skills/yct-direct/SKILL.md", root / ".claude/skills/yct-direct/SKILL.md"):
    direct = direct_path.read_text(encoding="utf-8")
    check("Do not spawn subagents." in direct, f"Direct Mode does not preserve no-agent intent: {direct_path}")
    check("ask the user to invoke" in direct, f"Direct Mode silently escalates instead of requesting explicit mode: {direct_path}")

agents_text = (root / "AGENTS.md").read_text(encoding="utf-8")
for marker in ("Selected methods:", "Trigger evidence:", "Required output:", "Gate/stop condition:"):
    check(marker in agents_text, f"clean-context packet schema misses method field: {marker}")
for role in ("planner-agent", "executor-agent"):
    codex_text = codex_agents[role].get("developer_instructions", "")
    claude_text = (root / ".claude/agents" / f"{role}.md").read_text(encoding="utf-8")
    for text, platform in ((codex_text, "Codex"), (claude_text, "Claude")):
        check("trigger evidence" in text and "gate/stop condition" in text, f"{platform} {role} does not carry structured method packets")

canonical_packet_fields = (
    "Agent",
    "Route",
    "Criticality level",
    "Goal",
    "Background",
    "Authoritative inputs",
    "Scope",
    "Allowed files",
    "Forbidden files",
    "Non-goals",
    "Constraints",
    "Assumptions",
    "Selected methods",
    "Done criteria",
    "Verification expected",
    "Output format",
    "Stop conditions",
)
for platform, planner_text in (
    ("Codex", codex_agents["planner-agent"].get("developer_instructions", "")),
    ("Claude", (root / ".claude/agents/planner-agent.md").read_text(encoding="utf-8")),
):
    executor_start = planner_text.index("Executor packet:")
    verifier_start = planner_text.index("Verify-agent packet:")
    executor_packet = planner_text[executor_start:verifier_start]
    verifier_packet = planner_text[verifier_start:]
    for field in canonical_packet_fields:
        check(field in executor_packet, f"{platform} planner executor packet misses canonical field: {field}")
        check(field in verifier_packet, f"{platform} planner verifier packet misses canonical field: {field}")

evals = json.loads((root / "evals/evals.json").read_text(encoding="utf-8"))
check(len(evals.get("evals", [])) >= 24, "routing/method eval set is too small")
check(len({case["id"] for case in evals.get("evals", [])}) == len(evals.get("evals", [])), "duplicate eval ids")
eval_expectations = "\n".join(case.get("expected_output", "") for case in evals.get("evals", []))
for route in ("docs-agent", "alignment-recorder-agent", "general-agent"):
    check(route in eval_expectations, f"routing fixture misses fallback/recording route: {route}")
method_names = {
    "First Principles",
    "MECE",
    "Hypothesis–Falsification",
    "PDCA",
    "Pre-mortem + FMEA-lite",
    "Steelman + Red Team",
    "Trust Boundary + Abuse Cases",
    "Bidirectional Traceability + Adjacency Scan",
    "One-way/Two-way Door + ADR",
    "Expand–Migrate–Contract",
    "Test Strategy Selection",
    "OODA",
    "Evidence Triangulation",
    "Double-loop Learning",
}
check(set(evals.get("method_catalog", [])) == method_names, "eval method catalog differs from method contract")
policy = evals.get("expectation_policy", {})
check(policy.get("closed_world") is True, "eval method expectations are not closed-world")
check("absent" in policy.get("forbidden_method_rule", "").lower(), "eval policy does not forbid untriggered methods")
covered_methods: set[str] = set()
for case in evals.get("evals", []):
    expected_methods = case.get("expected_methods")
    check(isinstance(expected_methods, list), f"eval {case.get('id')} misses expected_methods list")
    if isinstance(expected_methods, list):
        covered_methods.update(expected_methods)
        trigger_evidence = case.get("trigger_evidence")
        check(isinstance(trigger_evidence, dict), f"eval {case.get('id')} misses trigger_evidence object")
        if isinstance(trigger_evidence, dict):
            check(set(trigger_evidence) == set(expected_methods), f"eval {case.get('id')} method/trigger evidence mismatch")
            check(all(isinstance(value, str) and value.strip() for value in trigger_evidence.values()), f"eval {case.get('id')} has empty trigger evidence")
        check(case.get("expected_not_methods") == "all_catalog_methods_except_expected_methods", f"eval {case.get('id')} loses closed-world forbidden methods")
        check(not (set(expected_methods) - method_names), f"eval {case.get('id')} names unknown methods")
        forbidden_methods = method_names - set(expected_methods)
        check(not (forbidden_methods & set(expected_methods)), f"eval {case.get('id')} required/forbidden methods overlap")
    check(isinstance(case.get("expected_criticality"), str) and case["expected_criticality"], f"eval {case.get('id')} misses expected criticality")
    check(isinstance(case.get("expected_route"), str) and case["expected_route"], f"eval {case.get('id')} misses expected route")
    check(isinstance(case.get("expected_gates"), list) and case["expected_gates"], f"eval {case.get('id')} misses gate order/closure")

    prompt = case.get("prompt", "").lower()
    criticality = case.get("expected_criticality", "")
    route = case.get("expected_route", "")
    selected = set(expected_methods or [])
    if re.search(r"\bauth\b|\bauthorization\b|payment|production data|production requests|concurrent retries", prompt):
        check(criticality.startswith(("L3", "L4")), f"eval {case.get('id')} downgrades a safety/production signal")
        check("focused" not in route, f"eval {case.get('id')} routes a safety signal to focused execution")
    if prompt.startswith("$yct-risk"):
        check(criticality.startswith(("L3", "L4")) and "risk" in route, f"eval {case.get('id')} violates explicit risk mode")
    if prompt.startswith("$yct-review"):
        check("review" in route, f"eval {case.get('id')} violates review-only mode")
    if prompt.startswith("$yct-direct"):
        check("direct" in route, f"eval {case.get('id')} violates direct mode")
    if "Double-loop Learning" in selected:
        check(any(token in prompt for token in ("third", "recurring", "repeated", "again")), f"eval {case.get('id')} over-triggers double-loop learning")
    if "Test Strategy Selection" in selected:
        check(re.search(r"parser|refactor|\bauth\b|\bauthorization\b|payment|migration|schema|concurr|retr", prompt) is not None, f"eval {case.get('id')} over-triggers test strategy selection")
    if "Pre-mortem + FMEA-lite" in selected:
        check(criticality.startswith(("L3", "L4")), f"eval {case.get('id')} over-triggers FMEA outside L3/L4")
    if "One-way/Two-way Door + ADR" in selected:
        check(re.search(r"architecture|irreversible|schema|migration|public api|global.*cache|cache.*global", prompt) is not None, f"eval {case.get('id')} over-triggers decision/ADR method")
check(covered_methods == method_names, f"method fixture coverage drift: missing={sorted(method_names - covered_methods)} extra={sorted(covered_methods - method_names)}")

cases_by_id = {case["id"]: case for case in evals.get("evals", [])}
for case_id in (2, 4):
    case = cases_by_id[case_id]
    check(case["expected_criticality"] == "L3" and case["expected_route"] == "risk-overlay", f"eval {case_id} does not lock auth risk overlay")
    for method in ("PDCA", "Test Strategy Selection", "Trust Boundary + Abuse Cases"):
        check(method in case["expected_methods"], f"eval {case_id} misses required auth method: {method}")
check("Test Strategy Selection" not in cases_by_id[5]["expected_methods"], "generic review over-triggers Test Strategy Selection")
check("Double-loop Learning" not in cases_by_id[6]["expected_methods"], "instruction edit invents recurrence for Double-loop Learning")
check(not cases_by_id[14]["expected_methods"], "alignment recording reruns a consequential-decision method without trigger evidence")
for method in ("First Principles", "MECE"):
    check(method in cases_by_id[19]["expected_methods"], f"migration risk fixture misses {method}")
for method in ("MECE", "PDCA", "Bidirectional Traceability + Adjacency Scan"):
    check(method in cases_by_id[20]["expected_methods"], f"payment concurrency fixture misses {method}")

parser_eval = next((case for case in evals.get("evals", []) if case.get("id") == 17), None)
check(parser_eval is not None, "missing parser/combinatorial method fixture")
if parser_eval is not None:
    check(
        parser_eval.get("expected_gates") == [
            "diagnostic-first",
            "explorer-only",
            "no-writer-before-localization",
            "focused-return-evidence",
            "test-strategy-before-writer",
            "runner-before-verifier",
        ],
        "parser fixture does not lock diagnostic, writer, return, and verification gates",
    )
    parser_expected = parser_eval.get("expected_output", "")
    for marker in ("explorer-only", "no other agent or writer", "before writing", "invariant/oracle", "selected", "rejected alternatives", "L1-L2-risk", "return to focused", "runner before verifier"):
        check(marker in parser_expected, f"parser fixture expected output misses semantic marker: {marker}")

methods_doc = (root / "docs/METHODS.md").read_text(encoding="utf-8")
for method in method_names:
    base = method.split(" + ", 1)[0].split("–", 1)[0].split("/", 1)[0]
    check(base in methods_doc, f"METHODS.md misses method family: {method}")
method_rule = root / ".claude/rules/method-orchestration.md"
check(method_rule.exists(), "missing Claude method orchestration rule")
if method_rule.exists():
    rule_text = method_rule.read_text(encoding="utf-8")
    check("method chain by ritual" in rule_text, "Claude method rule does not prevent ceremony")
    check("docs/METHODS.md" in rule_text, "Claude method rule loses detailed contract owner")
check((root / "AGENTS.md").stat().st_size < 22000, "AGENTS.md exceeds the compact shared-contract budget")
check((root / "docs/METHODS.md").stat().st_size < 16000, "METHODS.md is too large for a focused reference")

if errors:
    for error in errors:
        print(f"FAIL: {error}", file=sys.stderr)
    raise SystemExit(1)

print("PASS: package, routes, models, method parity, frontmatter, TOML, skills, and eval contracts")
PY

tmp_root="$(mktemp -d "${TMPDIR:-/tmp}/yct-pack-test.XXXXXX")"
trap 'rm -rf "$tmp_root"' EXIT

fresh="$tmp_root/fresh"
CLAUDE_HOME="$fresh/.claude" \
CODEX_HOME="$fresh/.codex" \
CODEX_SKILLS_HOME="$fresh/.agents/skills" \
YCT_BACKUP_DIR="$fresh/backups" \
HOME="$fresh" \
  "$ROOT/install.sh" > "$tmp_root/fresh.log"

CLAUDE_HOME="$fresh/.claude" \
CODEX_HOME="$fresh/.codex" \
CODEX_SKILLS_HOME="$fresh/.agents/skills" \
YCT_BACKUP_DIR="$fresh/backups" \
HOME="$fresh" \
  "$ROOT/install.sh" > "$tmp_root/repeat.log"

[ "$(grep -Fc '<!-- BEGIN YCT_AGENT_SYSTEM:CLAUDE_IMPORTS -->' "$fresh/.claude/CLAUDE.md")" -eq 1 ]
[ "$(grep -Fc '<!-- BEGIN YCT_AGENT_SYSTEM:CODEX_AGENTS -->' "$fresh/.codex/AGENTS.md")" -eq 1 ]
cmp -s "$ROOT/docs/METHODS.md" "$fresh/.claude/METHODS.yct.md"
cmp -s "$ROOT/docs/METHODS.md" "$fresh/.codex/METHODS.yct.md"
if command -v codex >/dev/null 2>&1; then
  CODEX_HOME="$fresh/.codex" codex debug prompt-input 'validate yct config' > "$tmp_root/codex-prompt-input.json"
fi

existing="$tmp_root/existing"
mkdir -p "$existing/.codex"
printf '[agents]\nmax_depth = 0\nmax_threads = 1\n\n[agents.focused-fixer-agent]\ndescription = "custom"\nconfig_file = "agents/custom-focused.toml"\n' > "$existing/.codex/config.toml"
CODEX_HOME="$existing/.codex" \
CODEX_SKILLS_HOME="$existing/.agents/skills" \
YCT_BACKUP_DIR="$existing/backups" \
HOME="$existing" \
  "$ROOT/install.sh" --codex-only > "$tmp_root/existing.log" 2>&1
grep -Fq 'agents.max_depth=0' "$tmp_root/existing.log"
grep -Fq 'agents.max_threads=1' "$tmp_root/existing.log"
[ "$(grep -Ec '^\[agents\.("?focused-fixer-agent"?)\]$' "$existing/.codex/config.toml")" -eq 1 ]
grep -Fq 'config_file = "agents/custom-focused.toml"' "$existing/.codex/config.toml"
grep -Fq '[agents."executor-agent"]' "$existing/.codex/config.toml"

child_only="$tmp_root/child-only"
mkdir -p "$child_only/.codex"
printf '[agents.focused-fixer-agent]\ndescription = "custom"\nconfig_file = "agents/custom-focused.toml"\n' > "$child_only/.codex/config.toml"
CODEX_HOME="$child_only/.codex" \
CODEX_SKILLS_HOME="$child_only/.agents/skills" \
YCT_BACKUP_DIR="$child_only/backups" \
HOME="$child_only" \
  "$ROOT/install.sh" --codex-only > "$tmp_root/child-only.log" 2>&1
[ "$(grep -Ec '^\[agents\.("?focused-fixer-agent"?)\]$' "$child_only/.codex/config.toml")" -eq 1 ]
grep -Fq '[agents."executor-agent"]' "$child_only/.codex/config.toml"
uv run --python 3.11 python - "$child_only/.codex/config.toml" <<'PY'
import pathlib
import sys
import tomllib

tomllib.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
PY

inline_role="$tmp_root/inline-role"
mkdir -p "$inline_role/.codex"
printf '%s\n' '[agents]' 'max_depth = 1' 'max_threads = 2' '"focused-fixer-agent" = { description = "custom", config_file = "agents/custom-focused.toml" }' > "$inline_role/.codex/config.toml"
CODEX_HOME="$inline_role/.codex" \
CODEX_SKILLS_HOME="$inline_role/.agents/skills" \
YCT_BACKUP_DIR="$inline_role/backups" \
HOME="$inline_role" \
  "$ROOT/install.sh" --codex-only > "$tmp_root/inline-role.log" 2>&1
grep -Fq '"focused-fixer-agent" = { description = "custom", config_file = "agents/custom-focused.toml" }' "$inline_role/.codex/config.toml"
[ "$(grep -Ec '^\[agents\.("?focused-fixer-agent"?)\]$' "$inline_role/.codex/config.toml")" -eq 0 ]
grep -Fq '[agents."executor-agent"]' "$inline_role/.codex/config.toml"
uv run --python 3.11 python - "$inline_role/.codex/config.toml" <<'PY'
import pathlib
import sys
import tomllib

data = tomllib.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
assert data["agents"]["focused-fixer-agent"]["config_file"] == "agents/custom-focused.toml"
PY

indented_agents="$tmp_root/indented-agents"
mkdir -p "$indented_agents/.codex"
printf '%s\n' 'model = "custom"' '  [agents]' '  max_depth = 0' '  max_threads = 1' '' '  [agents.focused-fixer-agent]' '  description = "custom"' '  config_file = "agents/custom-focused.toml"' > "$indented_agents/.codex/config.toml"
CODEX_HOME="$indented_agents/.codex" \
CODEX_SKILLS_HOME="$indented_agents/.agents/skills" \
YCT_BACKUP_DIR="$indented_agents/backups" \
HOME="$indented_agents" \
  "$ROOT/install.sh" --codex-only > "$tmp_root/indented-agents.log" 2>&1
grep -Fq 'agents.max_depth=0' "$tmp_root/indented-agents.log"
grep -Fq 'agents.max_threads=1' "$tmp_root/indented-agents.log"
grep -Fq '  [agents]' "$indented_agents/.codex/config.toml"
grep -Fq '  [agents.focused-fixer-agent]' "$indented_agents/.codex/config.toml"
grep -Fq 'config_file = "agents/custom-focused.toml"' "$indented_agents/.codex/config.toml"
grep -Fq '[agents."executor-agent"]' "$indented_agents/.codex/config.toml"
uv run --python 3.11 python - "$indented_agents/.codex/config.toml" <<'PY'
import pathlib
import sys
import tomllib

data = tomllib.loads(pathlib.Path(sys.argv[1]).read_text(encoding="utf-8"))
assert data["agents"]["max_depth"] == 0
assert data["agents"]["focused-fixer-agent"]["config_file"] == "agents/custom-focused.toml"
assert data["agents"]["executor-agent"]["config_file"] == "agents/executor-agent.toml"
PY

inline_agents="$tmp_root/inline-agents"
mkdir -p "$inline_agents/.codex"
printf '%s\n' 'model = "custom"' 'agents = { max_depth = 1, max_threads = 2 }' > "$inline_agents/.codex/config.toml"
cp "$inline_agents/.codex/config.toml" "$tmp_root/inline-agents.before"
if CODEX_HOME="$inline_agents/.codex" CODEX_SKILLS_HOME="$inline_agents/.agents/skills" \
  YCT_BACKUP_DIR="$inline_agents/backups" HOME="$inline_agents" \
  "$ROOT/install.sh" --codex-only > "$tmp_root/inline-agents.log" 2>&1; then
  echo 'FAIL: unsupported top-level inline agents config unexpectedly succeeded' >&2
  exit 1
fi
cmp -s "$tmp_root/inline-agents.before" "$inline_agents/.codex/config.toml"
[ ! -e "$inline_agents/.codex/AGENTS.md" ]
[ ! -e "$inline_agents/.codex/AGENTS.yct.md" ]
[ ! -e "$inline_agents/.codex/config.yct.example.toml" ]

for variant in quoted-inline spaced-dotted spaced-table array-table; do
  variant_home="$tmp_root/$variant"
  mkdir -p "$variant_home/.codex"
  if [ "$variant" = "quoted-inline" ]; then
    printf '%s\n' '"agents" = { max_depth = 1, max_threads = 2 }' > "$variant_home/.codex/config.toml"
  elif [ "$variant" = "spaced-dotted" ]; then
    printf '%s\n' 'agents . max_depth = 1' > "$variant_home/.codex/config.toml"
  elif [ "$variant" = "spaced-table" ]; then
    printf '%s\n' '[ agents ]' 'max_depth = 1' 'max_threads = 2' > "$variant_home/.codex/config.toml"
  else
    printf '%s\n' '[[agents]]' 'name = "unsupported"' > "$variant_home/.codex/config.toml"
  fi
  cp "$variant_home/.codex/config.toml" "$tmp_root/$variant.before"
  if CODEX_HOME="$variant_home/.codex" CODEX_SKILLS_HOME="$variant_home/.agents/skills" \
    YCT_BACKUP_DIR="$variant_home/backups" HOME="$variant_home" \
    "$ROOT/install.sh" --codex-only > "$tmp_root/$variant.log" 2>&1; then
    echo "FAIL: unsupported $variant agents config unexpectedly succeeded" >&2
    exit 1
  fi
  cmp -s "$tmp_root/$variant.before" "$variant_home/.codex/config.toml"
  [ ! -e "$variant_home/.codex/AGENTS.md" ]
done

malformed="$tmp_root/malformed"
mkdir -p "$malformed/.claude"
printf 'keep-before\n<!-- BEGIN YCT_AGENT_SYSTEM:CLAUDE_IMPORTS -->\nkeep-after\n' > "$malformed/.claude/CLAUDE.md"
cp "$malformed/.claude/CLAUDE.md" "$tmp_root/malformed.before"
if CLAUDE_HOME="$malformed/.claude" YCT_BACKUP_DIR="$malformed/backups" HOME="$malformed" \
  "$ROOT/install.sh" --claude-only > "$tmp_root/malformed.log" 2>&1; then
  echo 'FAIL: malformed marker install unexpectedly succeeded' >&2
  exit 1
fi
cmp -s "$tmp_root/malformed.before" "$malformed/.claude/CLAUDE.md"

symlinked="$tmp_root/symlinked"
mkdir -p "$symlinked/.claude"
printf 'do-not-change\n' > "$symlinked/real-claude.md"
cp "$symlinked/real-claude.md" "$tmp_root/symlink.before"
ln -s "$symlinked/real-claude.md" "$symlinked/.claude/CLAUDE.md"
if CLAUDE_HOME="$symlinked/.claude" YCT_BACKUP_DIR="$symlinked/backups" HOME="$symlinked" \
  "$ROOT/install.sh" --claude-only > "$tmp_root/symlink.log" 2>&1; then
  echo 'FAIL: symlinked guidance target install unexpectedly succeeded' >&2
  exit 1
fi
cmp -s "$tmp_root/symlink.before" "$symlinked/real-claude.md"
[ -L "$symlinked/.claude/CLAUDE.md" ]

conflict="$tmp_root/conflict"
mkdir -p "$conflict/.claude/agents/legacy"
printf '%s\n' '---' 'name: executor-agent' 'description: custom' '---' 'custom agent' > "$conflict/.claude/agents/legacy/custom.md"
if CLAUDE_HOME="$conflict/.claude" YCT_BACKUP_DIR="$conflict/backups" HOME="$conflict" \
  "$ROOT/install.sh" --claude-only > "$tmp_root/conflict.log" 2>&1; then
  echo 'FAIL: duplicate agent identity unexpectedly replaced without explicit flag' >&2
  exit 1
fi
[ -f "$conflict/.claude/agents/legacy/custom.md" ]
[ ! -e "$conflict/.claude/CLAUDE.md" ]
CLAUDE_HOME="$conflict/.claude" YCT_BACKUP_DIR="$conflict/backups" HOME="$conflict" \
  "$ROOT/install.sh" --claude-only --replace-conflicts > "$tmp_root/conflict-replace.log"
[ ! -e "$conflict/.claude/agents/legacy/custom.md" ]
[ -f "$conflict/.claude/agents/executor-agent.md" ]
conflict_backup="$(find "$conflict/backups" -type f -path '*/.claude/agents/legacy/custom.md' | head -n 1)"
[ -n "$conflict_backup" ]

backup="$tmp_root/backup"
mkdir -p "$backup/.codex"
printf 'model = "custom"\n' > "$backup/.codex/config.toml"
cp "$backup/.codex/config.toml" "$tmp_root/config.original"
CODEX_HOME="$backup/.codex" \
CODEX_SKILLS_HOME="$backup/.agents/skills" \
YCT_BACKUP_DIR="$backup/backups" \
HOME="$backup" \
  "$ROOT/install.sh" --codex-only > "$tmp_root/backup.log"
saved_config="$(find "$backup/backups" -type f -path '*/.codex/config.toml' | head -n 1)"
[ -n "$saved_config" ]
cmp -s "$tmp_root/config.original" "$saved_config"

dry="$tmp_root/dry"
CLAUDE_HOME="$dry/.claude" \
CODEX_HOME="$dry/.codex" \
CODEX_SKILLS_HOME="$dry/.agents/skills" \
YCT_BACKUP_DIR="$dry/backups" \
HOME="$dry" \
  "$ROOT/install.sh" --dry-run > "$tmp_root/dry.log"
[ ! -e "$dry/.claude" ]
[ ! -e "$dry/.codex" ]
[ ! -e "$dry/.agents" ]

echo 'PASS: installer fresh/repeat/existing-config/indented-agents/child-table/inline-role/noncanonical-agents-fail/conflict/malformed-marker/symlink/backup/dry-run checks'
