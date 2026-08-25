#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash -n "$ROOT/install.sh" "$ROOT/tests/verify_deploy.sh"

uv run --python 3.11 python - "$ROOT" <<'PY'
import json
import pathlib
import sys
import tomllib

root = pathlib.Path(sys.argv[1])
errors: list[str] = []
warnings: list[str] = []


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
    # .serena 是 Serena 工具的本地项目缓存，不属于包内容
    and ".serena" not in path.relative_to(root).parts
}
check(manifest == actual, f"manifest drift: missing={sorted(actual - manifest)} extra={sorted(manifest - actual)}")

# codex-cli >=0.147 rejects role files containing any unknown field and then
# ignores the whole file, silently disabling the role. Custom metadata must be
# comment-form, never a parsed key.
codex_role_fields = {
    "name",
    "description",
    "nickname_candidates",
    "model",
    "model_reasoning_effort",
    "default_permissions",
    "web_search",
    "developer_instructions",
    "permissions",
}
codex_agents: dict[str, dict] = {}
for path in sorted((root / ".codex/agents").glob("*.toml")):
    try:
        data = tomllib.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"invalid TOML {path}: {exc}")
        continue
    unknown_fields = set(data) - codex_role_fields
    check(
        not unknown_fields,
        f"codex-cli would ignore the whole role file over unknown fields {sorted(unknown_fields)}: {path.name}",
    )
    # Old sandbox_mode/[sandbox_workspace_write] must not compose with
    # permission profiles (official docs: mutually exclusive). Every role
    # declares default_permissions; writers carry the self-contained
    # yct-writer profile (workspace write, network disabled).
    perms = data.get("default_permissions")
    check(
        perms in {":read-only", "yct-writer"},
        f"codex role must pin default_permissions to :read-only or yct-writer, got {perms!r}: {path.name}",
    )
    if perms == "yct-writer":
        profile = data.get("permissions", {}).get("yct-writer", {})
        check(
            profile.get("extends") == ":workspace"
            and profile.get("network", {}).get("enabled") is False,
            f"yct-writer profile must extend :workspace with network disabled: {path.name}",
        )
    name = data.get("name")
    check(isinstance(name, str) and bool(name), f"missing Codex agent name: {path}")
    if isinstance(name, str):
        check(name not in codex_agents, f"duplicate Codex agent name: {name}")
        codex_agents[name] = data
    check(
        isinstance(data.get("model"), str) and bool(data["model"]),
        f"missing Codex model: {path}",
    )

# 目录漂移探测：模型目录随账号/时间变化，只 WARN 不 FAIL，避免离线或异地环境误红。
models_cache_path = pathlib.Path.home() / ".codex/models_cache.json"
if models_cache_path.exists():
    try:
        catalog_slugs = {
            entry.get("slug")
            for entry in json.loads(models_cache_path.read_text(encoding="utf-8")).get("models", [])
            if isinstance(entry, dict)
        }
    except Exception:
        catalog_slugs = set()
    if catalog_slugs:
        for agent_name, data in sorted(codex_agents.items()):
            pinned = data.get("model")
            if pinned not in catalog_slugs:
                warnings.append(
                    f"pinned Codex model '{pinned}' ({agent_name}) is absent from ~/.codex/models_cache.json — possibly retired"
                )

config = tomllib.loads((root / ".codex/config.toml").read_text(encoding="utf-8"))
roles = config.get("agents", {})
registered_roles = {
    name: role
    for name, role in roles.items()
    if isinstance(role, dict) and "config_file" in role
}
check(set(registered_roles) == set(codex_agents), "Codex role files and registrations differ")
for name, role in registered_roles.items():
    check(role.get("config_file") == f"agents/{name}.toml", f"wrong config_file for {name}")

claude_agents: dict[str, dict[str, str]] = {}
read_only_claude = {
    name
    for name, data in codex_agents.items()
    if data.get("default_permissions") == ":read-only"
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
    tools = {item.strip() for item in meta.get("tools", "").split(",") if item.strip()}
    check("Agent" not in tools, f"worker can recursively orchestrate: {path}")

check(set(claude_agents) == set(codex_agents), "Claude and Codex agent sets differ")

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

evals = json.loads((root / "evals/evals.json").read_text(encoding="utf-8"))
cases = evals.get("evals")
check(isinstance(cases, list), "evals must be a list")
case_ids: list[int] = []
for case in cases if isinstance(cases, list) else []:
    check(isinstance(case, dict), "each eval must be an object")
    if not isinstance(case, dict):
        continue
    case_id = case.get("id")
    check(isinstance(case_id, int), f"eval id must be an integer: {case_id!r}")
    if isinstance(case_id, int):
        case_ids.append(case_id)
    for field in ("prompt", "expected_criticality", "expected_route", "expected_output"):
        check(isinstance(case.get(field), str) and bool(case[field].strip()), f"eval {case_id} misses {field}")
    for field in ("expected_methods", "expected_gates", "files"):
        check(isinstance(case.get(field), list), f"eval {case_id} misses {field} list")
    check(isinstance(case.get("trigger_evidence"), dict), f"eval {case_id} misses trigger_evidence object")
check(len(case_ids) == len(set(case_ids)), "duplicate eval ids")

method_catalog = evals.get("method_catalog")
check(isinstance(method_catalog, list), "method_catalog must be a list")
if isinstance(method_catalog, list):
    valid_methods = [method for method in method_catalog if isinstance(method, str) and method]
    check(len(valid_methods) == len(method_catalog), "method_catalog has an invalid entry")
    check(len(valid_methods) == len(set(valid_methods)), "method_catalog has duplicates")

for warning in warnings:
    print(f"WARN: {warning}", file=sys.stderr)

if errors:
    for error in errors:
        print(f"FAIL: {error}", file=sys.stderr)
    raise SystemExit(1)

print("PASS: package structure, permissions, frontmatter, TOML, skills, and eval schema")
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
