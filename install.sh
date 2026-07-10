#!/usr/bin/env bash
set -euo pipefail

# YCT Agent System Installer
# macOS/Linux compatible. Installs user-level Claude Code and Codex agents/rules/skills.
# Policy: preserve unrelated files; update same-path YCT assets and same declared agent identities only after backup.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:?HOME is not set}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME_DIR/.claude}"
CODEX_HOME="${CODEX_HOME:-$HOME_DIR/.codex}"
CODEX_SKILLS_HOME="${CODEX_SKILLS_HOME:-$HOME_DIR/.agents/skills}"
BACKUP_ROOT="${YCT_BACKUP_DIR:-$HOME_DIR/.yct-agent-backups}"
TS="$(date +%Y%m%d-%H%M%S)-$$"
BACKUP_DIR="$BACKUP_ROOT/$TS"
DRY_RUN=0
INSTALL_CLAUDE=1
INSTALL_CODEX=1
REPLACE_CONFLICTS=0

usage() {
  cat <<USAGE
Usage: ./install.sh [options]

Default user-level install:
  Claude agents/rules/skills -> ~/.claude
  Claude root guidance       -> merge into ~/.claude/CLAUDE.md, with YCT source files saved beside it
  Codex agents/config        -> ~/.codex
  Codex global guidance      -> merge into ~/.codex/AGENTS.md or AGENTS.override.md when present
  Codex skills               -> ~/.agents/skills

Merge policy:
  - Existing unrelated skills are never deleted.
  - Existing unrelated non-YCT agents/rules are preserved.
  - Same-name YCT files/directories are backed up, then overwritten.
  - Different-path agent identity conflicts stop by default; --replace-conflicts backs up and replaces them.
  - Existing CLAUDE.md / AGENTS.md are merged using YCT marker blocks, not replaced.
  - Symlinked write targets are rejected instead of modifying the linked file or directory.

Options:
  --dry-run          Print actions without writing target files (temporary scratch files may be created)
  --claude-only      Install only Claude files
  --codex-only       Install only Codex files
  --replace-conflicts
                     Replace a different-path agent with the same declared name after backup
  --help             Show this help

Environment overrides:
  CLAUDE_HOME=/path/to/.claude
  CODEX_HOME=/path/to/.codex
  CODEX_SKILLS_HOME=/path/to/.agents/skills
  YCT_BACKUP_DIR=/path/to/backups
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --claude-only) INSTALL_CODEX=0 ;;
    --codex-only) INSTALL_CLAUDE=0 ;;
    --replace-conflicts) REPLACE_CONFLICTS=1 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

OS_NAME="$(uname -s 2>/dev/null || echo unknown)"
case "$OS_NAME" in
  Darwin|Linux) : ;;
  *) echo "Warning: unsupported OS '$OS_NAME'. This installer is tested for macOS and Linux." >&2 ;;
esac

log() { printf '%s\n' "$*"; }

reject_symlink_target() {
  target="$1"
  if [ -L "$target" ]; then
    printf 'ERROR: refusing to modify symlink target %s. Replace it with a regular file/directory or choose a different install home.\n' "$target" >&2
    return 1
  fi
}

ensure_dir() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] mkdir -p %s\n' "$1"
  else
    mkdir -p "$1"
  fi
}

make_temp_file() {
  tmp_parent="${TMPDIR:-/tmp}"
  [ -d "$tmp_parent" ] || tmp_parent="/tmp"
  mktemp "$tmp_parent/yct-agent.XXXXXX"
}

backup_path() {
  src_path="$1"
  rel_path="$2"
  [ -e "$src_path" ] || return 0
  dest="$BACKUP_DIR/$rel_path"
  if [ -e "$dest" ]; then
    log "kept first backup: $dest"
    return 0
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] backup %s -> %s\n' "$src_path" "$dest"
  else
    mkdir -p "$(dirname "$dest")"
    cp -R "$src_path" "$dest"
  fi
}

validate_marker_block() {
  target="$1"
  begin="$2"
  end="$3"
  [ -e "$target" ] || return 0

  if awk -v begin="$begin" -v end="$end" '
    BEGIN { state = 0; begins = 0; ends = 0; invalid = 0 }
    $0 == begin {
      begins++
      if (state != 0) invalid = 1
      state = 1
      next
    }
    $0 == end {
      ends++
      if (state != 1) invalid = 1
      state = 0
      next
    }
    END {
      if (state != 0 || begins != ends || begins > 1 || invalid != 0) exit 1
    }
  ' "$target"; then
    return 0
  fi

  printf 'ERROR: malformed YCT marker block in %s; file was not modified. Restore or remove the unmatched/duplicate markers, then retry.\n' "$target" >&2
  return 1
}

install_file() {
  src="$1"
  dst="$2"
  rel="$3"
  reject_symlink_target "$dst"
  ensure_dir "$(dirname "$dst")"
  if [ -e "$dst" ]; then
    if cmp -s "$src" "$dst"; then
      log "unchanged: $dst"
      return 0
    fi
    backup_path "$dst" "$rel"
  fi
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] install file %s -> %s\n' "$src" "$dst"
  else
    cp "$src" "$dst"
  fi
  log "installed: $dst"
}

install_dir_contents() {
  src_dir="$1"
  dst_dir="$2"
  rel_prefix="$3"
  [ -d "$src_dir" ] || return 0
  ensure_dir "$dst_dir"
  find "$src_dir" -type f | while IFS= read -r src; do
    rel="${src#$src_dir/}"
    install_file "$src" "$dst_dir/$rel" "$rel_prefix/$rel"
  done
}

install_skill_dirs() {
  src_dir="$1"
  dst_dir="$2"
  rel_prefix="$3"
  [ -d "$src_dir" ] || return 0
  ensure_dir "$dst_dir"

      found=0
  for skill_dir in "$src_dir"/*; do
    [ -d "$skill_dir" ] || continue
    found=1
    skill="$(basename "$skill_dir")"
    dst="$dst_dir/$skill"
    reject_symlink_target "$dst"
    if [ -e "$dst" ]; then
      backup_path "$dst" "$rel_prefix/$skill"
    fi
    if [ "$DRY_RUN" -eq 1 ]; then
      printf '[dry-run] install skill dir %s -> %s\n' "$skill_dir" "$dst"
    else
      rm -rf "$dst"
      cp -R "$skill_dir" "$dst"
    fi
    log "installed skill: $dst"
  done
  [ "$found" -eq 1 ] || log "no skills found in: $src_dir"
}


extract_claude_agent_name() {
  file="$1"
  awk '
    BEGIN { in_frontmatter = 0 }
    /^---[[:space:]]*$/ {
      if (in_frontmatter == 0) { in_frontmatter = 1; next }
      exit
    }
    in_frontmatter == 1 && /^[[:space:]]*name[[:space:]]*:/ {
      val = $0
      sub(/^[[:space:]]*name[[:space:]]*:[[:space:]]*/, "", val)
      sub(/^[\"'\'' ]*/, "", val)
      sub(/[\"'\'' ]*$/, "", val)
      print val
      exit
    }
  ' "$file"
}

extract_codex_agent_name() {
  file="$1"
  awk '
    /^[[:space:]]*name[[:space:]]*=/ {
      val = $0
      sub(/^[^=]*=[[:space:]]*/, "", val)
      sub(/[[:space:]]*#.*/, "", val)
      sub(/^[\"'\'' ]*/, "", val)
      sub(/[\"'\'' ]*$/, "", val)
      print val
      exit
    }
  ' "$file"
}

extract_agent_name() {
  kind="$1"
  file="$2"
  case "$kind" in
    claude) extract_claude_agent_name "$file" ;;
    codex) extract_codex_agent_name "$file" ;;
    *) return 1 ;;
  esac
}

prepare_agent_name_conflicts() {
  src_dir="$1"
  dst_dir="$2"
  rel_prefix="$3"
  kind="$4"
  [ -d "$src_dir" ] || return 0
  [ -d "$dst_dir" ] || return 0

  for src in "$src_dir"/*; do
    [ -f "$src" ] || continue
    src_name="$(extract_agent_name "$kind" "$src" || true)"
    [ -n "$src_name" ] || continue
    intended_dst="$dst_dir/$(basename "$src")"

    find "$dst_dir" -type f | while IFS= read -r existing; do
      case "$kind" in
        claude) case "$existing" in *.md) : ;; *) continue ;; esac ;;
        codex) case "$existing" in *.toml) : ;; *) continue ;; esac ;;
      esac
      [ "$existing" = "$intended_dst" ] && continue
      existing_name="$(extract_agent_name "$kind" "$existing" || true)"
      if [ "$existing_name" = "$src_name" ]; then
        if [ "$REPLACE_CONFLICTS" -ne 1 ]; then
          printf 'ERROR: conflicting %s agent identity %s already exists at %s. Re-run with --replace-conflicts only after reviewing that file.\n' "$kind" "$src_name" "$existing" >&2
          exit 1
        fi
        existing_rel="${existing#$dst_dir/}"
        backup_path "$existing" "$rel_prefix/$existing_rel"
        if [ "$DRY_RUN" -eq 1 ]; then
          printf '[dry-run] remove conflicting same-name agent %s\n' "$existing"
        else
          rm -f "$existing"
        fi
        log "removed conflicting same-name agent: $existing"
      fi
    done
  done
}

merge_text_block() {
  target="$1"
  rel="$2"
  block_name="$3"
  block_file="$4"
  begin="<!-- BEGIN YCT_AGENT_SYSTEM:$block_name -->"
  end="<!-- END YCT_AGENT_SYSTEM:$block_name -->"
  reject_symlink_target "$target"
  validate_marker_block "$target" "$begin" "$end"
  ensure_dir "$(dirname "$target")"
  tmp="$(make_temp_file)"
  newblock="$(make_temp_file)"
  {
    printf '%s\n' "$begin"
    cat "$block_file"
    printf '\n%s\n' "$end"
  } > "$newblock"

  if [ ! -e "$target" ]; then
    if [ "$DRY_RUN" -eq 1 ]; then
      printf '[dry-run] create merged file %s using block %s\n' "$target" "$block_name"
    else
      cp "$newblock" "$target"
    fi
    rm -f "$tmp" "$newblock"
    log "created merged file: $target"
    return 0
  fi

  if grep -Fqx "$begin" "$target"; then
    if [ "$DRY_RUN" -eq 1 ]; then
      printf '[dry-run] replace existing YCT block %s in %s\n' "$block_name" "$target"
      rm -f "$tmp" "$newblock"
      return 0
    fi
    backup_path "$target" "$rel"
    awk -v begin="$begin" -v end="$end" '
      $0 == begin { skip=1; next }
      $0 == end { skip=0; next }
      skip != 1 { print }
    ' "$target" > "$tmp"
    {
      cat "$tmp"
      printf '\n'
      cat "$newblock"
    } > "$target"
    log "updated YCT block: $target"
  else
    if [ "$DRY_RUN" -eq 1 ]; then
      printf '[dry-run] append YCT block %s to %s\n' "$block_name" "$target"
      rm -f "$tmp" "$newblock"
      return 0
    fi
    backup_path "$target" "$rel"
    {
      printf '\n'
      cat "$newblock"
    } >> "$target"
    log "appended YCT block: $target"
  fi
  rm -f "$tmp" "$newblock"
}

merge_inline_block() {
  target="$1"
  rel="$2"
  block_name="$3"
  content="$4"
  tmp_content="$(make_temp_file)"
  printf '%s\n' "$content" > "$tmp_content"
  merge_text_block "$target" "$rel" "$block_name" "$tmp_content"
  rm -f "$tmp_content"
}

ensure_codex_project_doc_max_bytes() {
  config_dst="$1"
  [ -e "$config_dst" ] || return 0

  # Codex reads project_doc_max_bytes as a top-level key. A same-named key
  # inside a TOML table does not protect AGENTS.md from truncation.
  status="$(awk '
    BEGIN { section = ""; found = 0; value = "" }
    /^[[:space:]]*\[/ { section = "table" }
    section == "" && /^[[:space:]]*project_doc_max_bytes[[:space:]]*=/ {
      found = 1
      line = $0
      sub(/^[^=]*=/, "", line)
      gsub(/[[:space:]]/, "", line)
      value = line
    }
    END {
      if (found == 0) print "missing"
      else if (value ~ /^[0-9]+$/ && value >= 65536) print "ok"
      else print "update"
    }
  ' "$config_dst")"

  if [ "$status" = "ok" ]; then
    log "kept existing config: $config_dst already sets top-level project_doc_max_bytes >= 65536"
    return 0
  fi

  backup_path "$config_dst" ".codex/config.toml"
  if [ "$DRY_RUN" -eq 1 ]; then
    if [ "$status" = "missing" ]; then
      printf '[dry-run] insert top-level project_doc_max_bytes into %s\n' "$config_dst"
    else
      printf '[dry-run] update top-level project_doc_max_bytes in %s\n' "$config_dst"
    fi
    return 0
  fi

  tmp="$(make_temp_file)"
  if [ "$status" = "missing" ]; then
    awk '
      BEGIN { inserted = 0 }
      /^[[:space:]]*\[/ && inserted == 0 {
        print "# BEGIN YCT project document size default"
        print "project_doc_max_bytes = 65536"
        print "# END YCT project document size default"
        print ""
        inserted = 1
      }
      { print }
      END {
        if (inserted == 0) {
          print ""
          print "# BEGIN YCT project document size default"
          print "project_doc_max_bytes = 65536"
          print "# END YCT project document size default"
        }
      }
    ' "$config_dst" > "$tmp"
  else
    awk '
      BEGIN { section = ""; updated = 0 }
      /^[[:space:]]*\[/ { section = "table" }
      section == "" && /^[[:space:]]*project_doc_max_bytes[[:space:]]*=/ && updated == 0 {
        print "project_doc_max_bytes = 65536"
        updated = 1
        next
      }
      { print }
    ' "$config_dst" > "$tmp"
  fi

  cp "$tmp" "$config_dst"
  rm -f "$tmp"
  if [ "$status" = "missing" ]; then
    log "inserted project_doc_max_bytes into: $config_dst"
  else
    log "updated project_doc_max_bytes in: $config_dst"
  fi
}

extract_codex_agents_section() {
  config_src="$1"
  awk '
    /^\[agents\]/ { print_section = 1 }
    print_section == 1 { print }
  ' "$config_src"
}

append_missing_codex_agent_roles() {
  config_src="$1"
  config_dst="$2"

  grep -E '^\[agents\."[^"]+"\][[:space:]]*$' "$config_src" | while IFS= read -r header; do
    role="${header#\[agents.\"}"
    role="${role%\"\]}"
    if awk -v role="$role" '
      /^[[:space:]]*\[agents\][[:space:]]*$/ { in_agents = 1; next }
      in_agents == 1 && /^[[:space:]]*\[/ { in_agents = 0 }
      in_agents == 1 && /=/ {
        key = $0
        sub(/=.*/, "", key)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
        sub(/^"/, "", key)
        sub(/"$/, "", key)
        if (key == role) found = 1
      }
      /^[[:space:]]*\[agents\./ {
        line = $0
        sub(/^[[:space:]]*\[agents\./, "", line)
        sub(/\][[:space:]]*$/, "", line)
        sub(/^"/, "", line)
        sub(/"$/, "", line)
        if (line == role) found = 1
      }
      END { exit(found == 1 ? 0 : 1) }
    ' "$config_dst"; then
      log "kept existing Codex role registration: $header"
      existing_role_file="$(awk -v role="$role" '
        /^[[:space:]]*\[agents\][[:space:]]*$/ { in_agents = 1; next }
        in_agents == 1 && /^[[:space:]]*\[/ { in_agents = 0 }
        in_agents == 1 && /=/ {
          key = $0
          sub(/=.*/, "", key)
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
          sub(/^"/, "", key)
          sub(/"$/, "", key)
          if (key == role) {
            line = $0
            if (line ~ /config_file[[:space:]]*=[[:space:]]*"/) {
              sub(/^.*config_file[[:space:]]*=[[:space:]]*"/, "", line)
              sub(/".*$/, "", line)
              print line
            } else {
              print "<inline table without double-quoted config_file>"
            }
            exit
          }
        }
        /^[[:space:]]*\[agents\./ {
          line = $0
          sub(/^[[:space:]]*\[agents\./, "", line)
          sub(/\][[:space:]]*$/, "", line)
          sub(/^"/, "", line)
          sub(/"$/, "", line)
          in_role = (line == role)
          next
        }
        in_role == 1 && /^[[:space:]]*config_file[[:space:]]*=/ {
          line = $0
          sub(/^[^=]*=[[:space:]]*/, "", line)
          sub(/^["'\'' ]*/, "", line)
          sub(/["'\'' ]*$/, "", line)
          print line
          exit
        }
      ' "$config_dst")"
      if [ "$existing_role_file" != "agents/$role.toml" ]; then
        printf 'WARNING: existing Codex role %s points to %s instead of agents/%s.toml; preserved without override.\n' "$role" "${existing_role_file:-<no config_file>}" "$role" >&2
      fi
      continue
    fi

    if [ "$DRY_RUN" -eq 1 ]; then
      printf '[dry-run] append Codex role registration %s to %s\n' "$header" "$config_dst"
      continue
    fi

    backup_path "$config_dst" ".codex/config.toml"
    tmp_role="$(make_temp_file)"
    awk -v header="$header" '
      $0 == header { emit = 1 }
      emit == 1 && /^\[/ && $0 != header { exit }
      emit == 1 { print }
    ' "$config_src" > "$tmp_role"
    {
      printf '\n'
      cat "$tmp_role"
    } >> "$config_dst"
    rm -f "$tmp_role"
    log "added Codex role registration: $header"
  done
}

warn_codex_agent_limits() {
  config_dst="$1"
  limits="$(awk '
    /^[[:space:]]*\[agents\][[:space:]]*$/ { in_agents = 1; next }
    in_agents == 1 && /^[[:space:]]*\[/ { exit }
    in_agents == 1 && /^[[:space:]]*max_depth[[:space:]]*=/ {
      line = $0; sub(/^[^=]*=/, "", line); gsub(/[[:space:]]/, "", line); depth = line
    }
    in_agents == 1 && /^[[:space:]]*max_threads[[:space:]]*=/ {
      line = $0; sub(/^[^=]*=/, "", line); gsub(/[[:space:]]/, "", line); threads = line
    }
    END { print depth " " threads }
  ' "$config_dst")"
  depth="${limits%% *}"
  threads="${limits#* }"

  if [ -n "$depth" ] && [ "$depth" -lt 1 ] 2>/dev/null; then
    printf 'WARNING: %s sets agents.max_depth=%s; yct-aa cannot spawn a child agent. Set max_depth >= 1.\n' "$config_dst" "$depth" >&2
  fi
  if [ -n "$threads" ] && [ "$threads" -lt 2 ] 2>/dev/null; then
    printf 'WARNING: %s sets agents.max_threads=%s; parallel yct-aa routing is constrained. Set max_threads >= 2 for parallel read-only work.\n' "$config_dst" "$threads" >&2
  fi
}

preflight_codex_config() {
  config_dst="$CODEX_HOME/config.toml"
  [ -e "$config_dst" ] || return 0
  reject_symlink_target "$config_dst"

  # Noncanonical agents declarations cannot be extended safely by this
  # shell-only merger. Refuse before any Codex files change.
  if awk '
    BEGIN { at_top = 1; found = 0; sq = sprintf("%c", 39) }
    {
      raw = $0
      line = raw
      sub(/^[[:space:]]*/, "", line)

      if (at_top == 1) {
        single_quoted = sq "agents" sq
        if (line ~ /^agents([[:space:]]*=|[[:space:]]*\.)/ ||
            line ~ /^"agents"([[:space:]]*=|[[:space:]]*\.)/ ||
            (index(line, single_quoted) == 1 && substr(line, length(single_quoted) + 1) ~ /^[[:space:]]*(=|\.)/)) {
          found = 1
        }
      }

      if (line ~ /^\[/) {
        at_top = 0
        semantic = line
        gsub(/[[:space:]]/, "", semantic)
        gsub(/"/, "", semantic)
        gsub(sq, "", semantic)
        if ((semantic ~ /^\[agents(\]|\.)/ || semantic ~ /^\[\[agents(\]\]|\.)/) &&
            raw !~ /^[[:space:]]*\[agents\][[:space:]]*$/ &&
            raw !~ /^[[:space:]]*\[agents\.("[^"]+"|[A-Za-z0-9_-]+)\][[:space:]]*$/) {
          found = 1
        }
      }
    }
    END { exit(found == 1 ? 0 : 1) }
  ' "$config_dst"; then
    printf 'ERROR: unsupported inline, dotted, quoted, or noncanonical agents declaration in %s; no Codex files were modified. Convert it to canonical [agents] and [agents."role"] tables, then retry.\n' "$config_dst" >&2
    return 1
  fi
}

install_codex_config() {
  ensure_dir "$CODEX_HOME"
  config_src="$SCRIPT_DIR/.codex/config.toml"
  config_dst="$CODEX_HOME/config.toml"
  example_dst="$CODEX_HOME/config.yct.example.toml"

  [ -f "$config_src" ] || return 0
  reject_symlink_target "$config_dst"
  install_file "$config_src" "$example_dst" ".codex/config.yct.example.toml"

  if [ ! -e "$config_dst" ]; then
    install_file "$config_src" "$config_dst" ".codex/config.toml"
    return 0
  fi

  ensure_codex_project_doc_max_bytes "$config_dst"

  if grep -Eq '^[[:space:]]*\[agents(\]|\.)' "$config_dst"; then
    append_missing_codex_agent_roles "$config_src" "$config_dst"
    warn_codex_agent_limits "$config_dst"
    log "kept existing agent values and merged missing YCT role registrations; recommended config saved to $example_dst"
    return 0
  fi

  backup_path "$config_dst" ".codex/config.toml"
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '[dry-run] append YCT [agents] block to %s\n' "$config_dst"
  else
    {
      printf '\n# BEGIN YCT agent defaults\n'
      extract_codex_agents_section "$config_src"
      printf '# END YCT agent defaults\n'
    } >> "$config_dst"
  fi
  log "updated config with YCT [agents] block: $config_dst"
  warn_codex_agent_limits "$config_dst"
}

install_claude_yct_guidance() {
  # Package-level CLAUDE.md starts with @AGENTS.md for repo installs.
  # User-level install imports AGENTS.yct.md from ~/.claude/CLAUDE.md already,
  # so strip the package-relative @AGENTS.md line to avoid an unresolved or duplicated import.
  src="$SCRIPT_DIR/CLAUDE.md"
  dst="$CLAUDE_HOME/CLAUDE.yct.md"
  tmp="$(make_temp_file)"
  awk 'NR == 1 && $0 == "@AGENTS.md" { next } { print }' "$src" > "$tmp"
  install_file "$tmp" "$dst" ".claude/CLAUDE.yct.md"
  rm -f "$tmp"
}

install_claude() {
  log "Installing Claude files into $CLAUDE_HOME"
  ensure_dir "$CLAUDE_HOME"

  prepare_agent_name_conflicts "$SCRIPT_DIR/.claude/agents" "$CLAUDE_HOME/agents" ".claude/agents" "claude"

  # Save source files separately, then merge a small import block into CLAUDE.md.
  install_file "$SCRIPT_DIR/AGENTS.md" "$CLAUDE_HOME/AGENTS.yct.md" ".claude/AGENTS.yct.md"
  install_file "$SCRIPT_DIR/docs/METHODS.md" "$CLAUDE_HOME/METHODS.yct.md" ".claude/METHODS.yct.md"
  install_claude_yct_guidance
  merge_inline_block "$CLAUDE_HOME/CLAUDE.md" ".claude/CLAUDE.md" "CLAUDE_IMPORTS" "@AGENTS.yct.md
@CLAUDE.yct.md"

  install_dir_contents "$SCRIPT_DIR/.claude/agents" "$CLAUDE_HOME/agents" ".claude/agents"
  install_dir_contents "$SCRIPT_DIR/.claude/rules" "$CLAUDE_HOME/rules" ".claude/rules"
  install_skill_dirs "$SCRIPT_DIR/.claude/skills" "$CLAUDE_HOME/skills" ".claude/skills"
  install_file "$SCRIPT_DIR/.claude/settings.example.json" "$CLAUDE_HOME/settings.yct.example.json" ".claude/settings.yct.example.json"
}

install_codex() {
  log "Installing Codex files into $CODEX_HOME"
  ensure_dir "$CODEX_HOME"

  preflight_codex_config
  prepare_agent_name_conflicts "$SCRIPT_DIR/.codex/agents" "$CODEX_HOME/agents" ".codex/agents" "codex"

  install_file "$SCRIPT_DIR/AGENTS.md" "$CODEX_HOME/AGENTS.yct.md" ".codex/AGENTS.yct.md"
  install_file "$SCRIPT_DIR/docs/METHODS.md" "$CODEX_HOME/METHODS.yct.md" ".codex/METHODS.yct.md"
  codex_agents_target="$CODEX_HOME/AGENTS.md"
  if [ -e "$CODEX_HOME/AGENTS.override.md" ]; then
    codex_agents_target="$CODEX_HOME/AGENTS.override.md"
    log "detected AGENTS.override.md; merging YCT guidance there because Codex reads it before AGENTS.md"
  fi
  merge_text_block "$codex_agents_target" ".codex/$(basename "$codex_agents_target")" "CODEX_AGENTS" "$SCRIPT_DIR/AGENTS.md"

  install_codex_config
  install_dir_contents "$SCRIPT_DIR/.codex/agents" "$CODEX_HOME/agents" ".codex/agents"

  log "Installing Codex skills into $CODEX_SKILLS_HOME"
  install_skill_dirs "$SCRIPT_DIR/.agents/skills" "$CODEX_SKILLS_HOME" ".agents/skills"
}

main() {
  log "YCT Agent System installer"
  log "OS: $OS_NAME"
  log "Package: $SCRIPT_DIR"
  log "Backup dir: $BACKUP_DIR"
  log "Policy: merge/append; preserve unrelated files; update same-path YCT assets after backup; require --replace-conflicts for different-path duplicate agent identities."

  if [ "$INSTALL_CLAUDE" -eq 1 ]; then
    install_claude
  fi
  if [ "$INSTALL_CODEX" -eq 1 ]; then
    install_codex
  fi

  log "Done."
  log "Claude shortcuts: /yct-aa, /yct-fix, /yct-direct, /yct-risk, /yct-review."
  log "Codex shortcuts:  \$yct-aa, \$yct-fix, \$yct-direct, \$yct-risk, \$yct-review."
  log "Backups, if any, are under: $BACKUP_DIR"
}

main "$@"
