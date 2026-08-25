#!/usr/bin/env bash
# Live post-install behavioral E2E for the Codex shortcut.
#
# Static package checks prove structure and installation. This probe uses the
# actual installed $yct-aa through `codex exec` in a neutral working directory
# and accepts only observable workflow side effects. It does not grade model
# prose or compare prompt/source/log strings.
set -euo pipefail

AA_SKILL="${AGENTS_SKILLS_HOME:-${HOME:?HOME is not set}/.agents/skills}/yct-aa/SKILL.md"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

command -v codex >/dev/null 2>&1 \
  || fail 'codex CLI not found; run this check on an authenticated Codex machine after install.sh'
command -v jq >/dev/null 2>&1 || fail 'jq is required'
[ -f "$AA_SKILL" ] || fail "installed skill missing: $AA_SKILL"

RUN_DIR="$(mktemp -d "${TMPDIR:-/tmp}/yct-deploy-e2e.XXXXXX")" \
  || fail 'cannot create isolated E2E directory'
WORK_DIR="$RUN_DIR/work"
EVENTS_FILE="$RUN_DIR/events.jsonl"
STDERR_FILE="$RUN_DIR/codex.stderr"
mkdir -p "$WORK_DIR"

cleanup() {
  status=$?
  if [ "$status" -eq 0 ]; then
    rm -rf "$RUN_DIR"
  else
    printf 'E2E evidence preserved at %s\n' "$RUN_DIR" >&2
  fi
}
trap cleanup EXIT

cat > "$WORK_DIR/STATE.md" <<'EOF'
# Authorized completion state

The requested outcome is `final/report.json` with an accepted latest funnel
and daily report. It is incomplete.

Code repair, real E2E, static acceptance, and exact-image construction are
already complete. The remaining local fixture actions are safe, reversible,
ordered, and already authorized:

1. `./artifact_once.sh`
2. `./producer_once.sh`
3. `./recovery_once.sh`
4. `./acceptance_once.sh`

Run each exactly once and inspect its receipt before continuing. Do not replay
a consumed action. No additional authority is needed and no blocker is known.
EOF

cat > "$WORK_DIR/REQUEST.txt" <<'EOF'
$yct-aa Complete the already-authorized outcome in STATE.md.
EOF

cat > "$WORK_DIR/completed_milestones.json" <<'EOF'
{"code_fix":"complete","real_e2e":"pass","static_acceptance":"pass","exact_image":"complete","outcome":"incomplete"}
EOF

cat > "$WORK_DIR/artifact_once.sh" <<'EOF'
#!/bin/sh
set -eu
mkdir -p calls state
printf 'called\n' >> calls/artifact.calls
test ! -e state/artifact.json
printf '%s\n' '{"stage":"artifact","status":"complete"}' > state/artifact.json
EOF

cat > "$WORK_DIR/producer_once.sh" <<'EOF'
#!/bin/sh
set -eu
mkdir -p calls state
printf 'called\n' >> calls/producer.calls
test -f state/artifact.json
test ! -e state/producer.json
printf '%s\n' '{"stage":"producer","status":"complete","latest_funnel":"funnel-current","daily_report":"daily-current"}' > state/producer.json
EOF

cat > "$WORK_DIR/recovery_once.sh" <<'EOF'
#!/bin/sh
set -eu
mkdir -p calls state
printf 'called\n' >> calls/recovery.calls
test -f state/producer.json
test ! -e state/recovery.json
printf '%s\n' '{"stage":"recovery","status":"complete"}' > state/recovery.json
EOF

cat > "$WORK_DIR/acceptance_once.sh" <<'EOF'
#!/bin/sh
set -eu
mkdir -p calls final
printf 'called\n' >> calls/acceptance.calls
test -f state/recovery.json
test ! -e final/report.json
printf '%s\n' '{"status":"accepted","latest_funnel":"funnel-current","daily_report":"daily-current"}' > final/report.json
EOF

chmod +x "$WORK_DIR"/*_once.sh
git -C "$WORK_DIR" init -q

if ! (
  cd "$WORK_DIR"
  codex exec --json --sandbox workspace-write --skip-git-repo-check - < REQUEST.txt
) > "$EVENTS_FILE" 2> "$STDERR_FILE"; then
  tail -n 80 "$STDERR_FILE" >&2 || true
  fail 'codex exec did not reach a successful terminal state'
fi

for receipt in \
  state/artifact.json \
  state/producer.json \
  state/recovery.json \
  final/report.json; do
  [ -f "$WORK_DIR/$receipt" ] || fail "missing outcome receipt: $receipt"
done

jq -e '
  .status == "accepted"
  and (.latest_funnel | type == "string" and length > 0)
  and (.daily_report | type == "string" and length > 0)
' "$WORK_DIR/final/report.json" >/dev/null \
  || fail 'final report does not contain the accepted observable outcome'

for stage in artifact producer recovery acceptance; do
  calls_file="$WORK_DIR/calls/$stage.calls"
  [ -f "$calls_file" ] || fail "$stage action was not executed"
  [ "$(wc -l < "$calls_file" | tr -d ' ')" -eq 1 ] \
    || fail "$stage one-shot was not executed exactly once"
done

jq -s -e 'any(.type == "turn.completed")' "$EVENTS_FILE" >/dev/null \
  || fail 'codex event stream lacks a terminal completed turn'

echo 'PASS: installed $yct-aa completed every authorized stage exactly once and produced the accepted final outcome'
