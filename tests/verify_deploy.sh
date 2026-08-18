#!/usr/bin/env bash
# Dynamic post-deployment verification for the Codex side of the pack.
#
# verify_pack.sh proves the REPO is internally consistent; install.sh proves the
# TARGETS are byte-identical to the repo. Neither proves a fresh Codex session
# actually behaves as designed. This script closes that gap with two live
# `codex exec` probes against the INSTALLED pack:
#
#   Probe 1 (ambient inventory): the five explicit-only workflow skills
#     (yct-aa/direct/fix/review/risk) must be ABSENT from the ambient skill
#     inventory — their `agents/openai.yaml` sets
#     `policy.allow_implicit_invocation: false`, whose official semantics hide
#     them from default context. If one appears, the policy file was lost.
#
#   Probe 2 (explicit invocation): `$yct-aa` must inject the full SKILL.md.
#     Acceptance is NOT the model's self-report: the probe carries a nonce, and
#     the script locates the probe session's rollout JSONL under
#     ~/.codex/sessions/ by that nonce, then greps it for a marker line taken
#     from the installed ~/.agents/skills/yct-aa/SKILL.md. Marker present in
#     the session ground truth == the injected content matches the installed
#     version.
#
# Cost/requirements: needs the `codex` CLI, network access, and spends real
# tokens (~25k per probe). Probes disable MCP servers (`-c 'mcp_servers={}'`)
# because MCP startup once hung a headless probe for 19 minutes.
set -uo pipefail

SESSIONS_DIR="${CODEX_HOME:-$HOME/.codex}/sessions"
AA_SKILL="${AGENTS_SKILLS_HOME:-$HOME/.agents/skills}/yct-aa/SKILL.md"
WORKFLOW_SKILLS=(yct-aa yct-direct yct-fix yct-review yct-risk)

fail() { echo "FAIL: $*" >&2; exit 1; }
info() { echo "  $*"; }

command -v codex >/dev/null 2>&1 \
  || fail "codex CLI not found; dynamic deploy verification requires it (run on the Codex machine after install.sh)"
[ -f "$AA_SKILL" ] || fail "installed skill missing: $AA_SKILL (run install.sh first)"

probe() {
  codex exec -s read-only --skip-git-repo-check -c 'mcp_servers={}' "$1" 2>/dev/null
}

echo "probe 1: ambient inventory must hide explicit-only workflow skills"
LIST=$(probe 'Do not use any tools. From the skills list available in this session context, output ONLY the skill names that start with "yct", comma-separated on a single line. If there are none, output exactly: none' \
  | grep -v '^\s*$' | tail -1)
[ -n "$LIST" ] || fail "inventory probe returned no output"
info "inventory answer: $LIST"
NORMALIZED=",$(echo "$LIST" | tr -d '[:space:]'),"
for s in "${WORKFLOW_SKILLS[@]}"; do
  case "$NORMALIZED" in
    *",$s,"*) fail "workflow skill '$s' appeared in the ambient inventory — allow_implicit_invocation policy not honored (check agents/openai.yaml under the installed skill)" ;;
  esac
done
echo "ok: all five workflow skills absent from ambient inventory (policy honored)"

echo "probe 2: explicit \$yct-aa invocation must inject the installed SKILL.md"
# 标记行取安装文件正文（跳过 frontmatter，注入时可能被剥离）中最长的、不含
# 引号/反斜杠的行：长句几乎不会与其他注入源撞车，且在 rollout JSONL 的 JSON
# 字符串里以原文出现，可直接 grep -F 对账，并随安装版本自动更新。
MARKER=$(awk 'f >= 2 { print } /^---[[:space:]]*$/ { f++ }' "$AA_SKILL" \
  | grep -v '["\\]' | grep -v '^\s*$' \
  | awk '{ if (length($0) > m) { m = length($0); line = $0 } } END { print line }' \
  | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
[ -n "$MARKER" ] || fail "could not derive a marker line from $AA_SKILL"
info "marker: $MARKER"
NONCE="yctdeployprobe$(date +%s)$$"
ANSWER=$(probe "\$yct-aa Nonce: $NONCE. Do not use any tools and do not start the task. Answer one line: are the full yct-aa skill instructions present in your context this turn, yes or no?" \
  | grep -v '^\s*$' | tail -1)
info "model self-report (informational only): ${ANSWER:-<empty>}"

SESSION_FILE=$(grep -rl --include='*.jsonl' "$NONCE" "$SESSIONS_DIR/$(date +%Y/%m/%d)" 2>/dev/null | head -1)
[ -n "$SESSION_FILE" ] || fail "probe session rollout JSONL not found under $SESSIONS_DIR for nonce $NONCE"
info "session ground truth: $SESSION_FILE"
grep -qF -- "$MARKER" "$SESSION_FILE" \
  || fail "marker from installed SKILL.md not found in the probe session JSONL — explicit invocation did not inject the installed version"
echo "ok: installed-version marker found in probe session JSONL (double-source check passed)"

echo "PASS: dynamic deploy verification (ambient policy + explicit \$yct-aa injection vs installed marker)"
