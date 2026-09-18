#!/usr/bin/env python3
"""Install current YCT contracts through TraeX's native discovery paths."""
from __future__ import annotations

import argparse
import datetime
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile
import tomllib

ROOT = Path(__file__).resolve().parents[1]
NL = chr(10)
WORKFLOWS = ('yct-aa', 'yct-direct', 'yct-fix', 'yct-review', 'yct-risk')
LEGACY_FILES = ("CLAUDE.yct.md", "rules/claude-model-routing.md", "rules/method-orchestration.md",
                "rules/subagent-orchestration.md", "rules/instruction-system-maintenance.md")
MODEL_NAMES = {'gpt-6-astra': 'GPT-6-Astra', 'gpt-5.6-sol': 'GPT-5.6-Sol',
               'gpt-5.6-terra': 'GPT-5.6-Terra', 'gpt-5.6-luna': 'GPT-5.6-Luna'}


def marker(text: str, name: str, body: str | None) -> str:
    begin = f'<!-- BEGIN YCT_AGENT_SYSTEM:{name} -->'
    end = f'<!-- END YCT_AGENT_SYSTEM:{name} -->'
    if text.count(begin) != text.count(end) or text.count(begin) > 1:
        raise ValueError(f'malformed YCT marker: {name}')
    if begin in text:
        before, tail = text.split(begin)
        if end not in tail:
            raise ValueError(f'reversed YCT marker: {name}')
        _, after = tail.split(end)
        text = before.rstrip() + NL + after.lstrip(NL)
    if body is not None:
        text = text.rstrip() + NL * 2 + NL.join((begin, body.rstrip(), end, ''))
    return text.lstrip(NL)


def config_with_size(text: str, minimum: int) -> str:
    data = tomllib.loads(text)
    value = data.get('project_doc_max_bytes')
    if isinstance(value, int) and value >= minimum:
        return text
    expected = dict(data, project_doc_max_bytes=minimum)
    if value is None:
        candidate = f'project_doc_max_bytes = {minimum}' + NL + text
        if tomllib.loads(candidate) == expected:
            return candidate
    lines = text.splitlines(keepends=True)
    for i, line in enumerate(lines):
        key = line.partition("=")[0].strip()
        if key not in ("project_doc_max_bytes", '"project_doc_max_bytes"', "'project_doc_max_bytes'"):
            continue
        candidate = ''.join(lines[:i] + [f'{key} = {minimum}' + NL] + lines[i+1:])
        try:
            if tomllib.loads(candidate) == expected:
                return candidate
        except tomllib.TOMLDecodeError:
            continue
    raise ValueError("cannot update project_doc_max_bytes while preserving other configuration")


def read_text(path: Path) -> str:
    return path.read_text(encoding='utf-8') if path.exists() else ''


def skill_name(path: Path) -> str | None:
    lines = read_text(path).splitlines()
    if not lines or lines[0] != '---':
        return None
    for line in lines[1:]:
        if line == '---':
            break
        if line.startswith('name:'):
            return line.split(':', 1)[1].strip().strip(chr(34) + chr(39))
    return None


def role_markdown(path: Path) -> str:
    role = tomllib.loads(path.read_text())
    model = role['model']
    if model == 'gpt-5.3-codex-spark':
        # TraeX exposes no Spark: use the existing portable substitute.
        substitute = 'batch-agent' if role['name'] == 'batch-spark-agent' else 'focused-fixer-agent'
        model = tomllib.loads((path.parent / (substitute + '.toml')).read_text())['model']
    body = role['developer_instructions'].replace('AGENTS/CLAUDE rules', 'AGENTS/TraeX rules')
    return NL.join(('---', f'name: {role["name"]}',
                    f'description: {json.dumps(role["description"])}',
                    f'model: {MODEL_NAMES[model]}', f'effort: {role["model_reasoning_effort"]}',
                    '---', '', 'Use the already injected shared AGENTS.md contract and TraeX operating layer.',
                    'Do not search the business cwd for AGENTS.yct.md or CLAUDE.yct.md.', '', body.rstrip(), ''))


class Installer:
    def __init__(self, home: Path, shared: Path, backup: Path, dry_run: bool, replace: bool, retire: list[str] | None = None):
        self.home = home.absolute()
        self.shared = shared.absolute()
        self.backup = backup.absolute()
        self.dry_run = dry_run
        self.replace = replace
        self.retire = retire or []
        self.actions: list[tuple[str, Path, str]] = []
        self.backed: set[Path] = set()
        if any(p.is_symlink() or (p.exists() and not p.is_dir()) for p in (self.home, self.shared, self.backup)):
            raise ValueError("installation roots must be regular directories, not links or files")
        physical = [p.resolve() for p in (self.home, self.shared, self.backup)]
        if any(a.is_relative_to(b) or b.is_relative_to(a)
               for i, a in enumerate(physical) for b in physical[i+1:]):
            raise ValueError("backup must be outside discovery roots; TraeX home and shared skills must differ")

    def check_parent(self, path: Path) -> None:
        # /home itself may resolve to /data00/home; descendant aliases must not
        # turn an installation into edits of another checkout.
        for base in (self.home, self.shared):
            if path.is_relative_to(base):
                parent = path.parent
                while parent != base and parent.is_relative_to(base):
                    removed = any(a == 'remove' and p == parent for a, p, _ in self.actions)
                    if parent.is_symlink() and not removed:
                        raise ValueError(f'refusing symlinked parent: {parent}')
                    if parent.exists() and not parent.is_dir() and not removed:
                        raise ValueError(f"installation parent is not a directory: {parent}")
                    parent = parent.parent
                break

    def write(self, path: Path, body: str) -> None:
        self.check_parent(path)
        if path.is_symlink() or (path.exists() and not path.is_file()):
            raise ValueError(f'refusing symlinked file: {path}')
        if path.exists() and read_text(path) == body:
            return
        self.actions.append(('write', path, body))

    def move_out(self, path: Path) -> None:
        if path.exists() or path.is_symlink():
            if not self.replace:
                raise ValueError(f'conflicting discovery entry: {path}; review dry-run and use --replace-conflicts')
            if not any(a == 'remove' and p == path for a, p, _ in self.actions):
                self.actions.append(('remove', path, ''))

    def plan(self) -> None:
        shared_contract = (ROOT / 'AGENTS.md').read_text()
        layer = (ROOT / 'platforms/TRAEX.md').read_text()
        guidance = NL.join((shared_contract.rstrip(), '', '---', '', layer))
        target = self.home / ('AGENTS.override.md' if (self.home/'AGENTS.override.md').exists() else 'AGENTS.md')
        text = read_text(target)
        for old in ('CLAUDE_IMPORTS', 'CODEX_AGENTS'):
            text = marker(text, old, None)
        text = marker(text, 'TRAEX_AGENTS', guidance)
        self.write(target, text)
        self.write(self.home/'AGENTS.yct.md', shared_contract)
        self.write(self.home/'TRAEX.yct.md', layer)
        self.write(self.home/'METHODS.yct.md', (ROOT/'docs/METHODS.md').read_text())
        cfg = self.home/'traecli.toml'
        minimum = max(131072, len(text.encode()) + len(shared_contract.encode()) + 32768)
        minimum = ((minimum + 4095)//4096)*4096
        self.write(cfg, config_with_size(read_text(cfg), minimum))
        roles = {p.stem:role_markdown(p) for p in sorted((ROOT/'.codex/agents').glob('*.toml'))}
        for path in (self.home/'agents').glob('*.md'):
            name = skill_name(path)
            if name in roles and path.name != name + '.md':
                self.move_out(path)
        for name, body in roles.items():
            self.write(self.home/'agents'/f'{name}.md', body)
        for relative in self.retire:
            path = self.home/relative
            self.move_out(path)
        for name in WORKFLOWS:
            canonical = self.shared/name
            source = ROOT/'.agents/skills'/name
            source_entries = sorted(source.rglob('*'))
            rebuild = canonical.is_symlink()
            if canonical.is_symlink():
                self.move_out(canonical)
            elif canonical.is_dir():
                expected_entries = {p.relative_to(source) for p in source_entries}
                stale = any(p.relative_to(canonical) not in expected_entries
                            for p in canonical.rglob('*'))
                if stale:
                    # Same-path YCT assets are replaced as a unit after backup.
                    self.actions.append(("remove", canonical, ""))
                    rebuild = True
            for src in source_entries:
                if src.is_file():
                    dst = canonical/src.relative_to(source)
                    if rebuild:
                        self.actions.append(('write', dst, src.read_text()))
                    else:
                        self.write(dst, src.read_text())
            target = self.home/'skills'/name
            if target.is_symlink() and target.resolve() == canonical.resolve():
                continue
            if target.exists() or target.is_symlink():
                self.move_out(target)
            self.check_parent(target)
            self.actions.append(('link', target, str(canonical)))
        for path in sorted((self.home/'skills').glob('*/SKILL.md')):
            name = skill_name(path)
            if name in WORKFLOWS and path.parent.name != name:
                self.move_out(path.parent)
        for _, path, _ in self.actions:
            self.check_parent(path)

    def save_backup(self, path: Path) -> None:
        if path in self.backed or not (path.exists() or path.is_symlink()):
            return
        self.backed.add(path)
        destination = self.backup/'originals'/str(path).lstrip('/')
        destination.parent.mkdir(parents=True, exist_ok=True)
        if path.is_symlink():
            destination.symlink_to(os.readlink(path))
        elif path.is_dir():
            shutil.copytree(path, destination, symlinks=True)
        else:
            shutil.copy2(path, destination)

    def apply(self) -> None:
        if self.actions and not self.dry_run:
            self.backup.mkdir(parents=True, exist_ok=True)
            self.backup.chmod(0o700)
            removed = {p for a, p, _ in self.actions if a == "remove"}
            # Back up before mutations. A replaced directory owns its original
            # children; do not follow a saved symlink while backing them up.
            for _, path, _ in self.actions:
                if not any(path != parent and path.is_relative_to(parent) for parent in removed):
                    self.save_backup(path)
            receipt = {"source": str(ROOT), "trae_home": str(self.home), "shared_skills": str(self.shared),
                       "actions": [{"action": a, "path": str(p),
                                    "backup": str(self.backup/"originals"/str(p).lstrip("/")) if p in self.backed else None}
                                   for a, p, _ in self.actions]}
            (self.backup/"install.json").write_text(json.dumps(receipt, indent=2) + NL)
        for action, path, body in self.actions:
            print(f'{"[dry-run] " if self.dry_run else ""}{action}: {path}')
            if self.dry_run:
                continue
            if action == 'remove':
                if path.is_symlink() or path.is_file():
                    path.unlink()
                else:
                    shutil.rmtree(path)
            elif action == 'link':
                path.parent.mkdir(parents=True, exist_ok=True)
                path.symlink_to(body, target_is_directory=True)
            else:
                path.parent.mkdir(parents=True, exist_ok=True)
                mode = path.stat().st_mode & 0o777 if path.exists() else 0o600
                with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', dir=path.parent, delete=False) as stream:
                    stream.write(body)
                    temp = Path(stream.name)
                temp.chmod(mode)
                temp.replace(path)
        if self.actions and not self.dry_run:
            print(f'Backup and changed-path receipt: {self.backup}')
        print('Open a new TraeX session to load the installed instructions and roles.')


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--trae-home', type=Path, default=Path(os.environ.get('TRAE_HOME', Path.home()/'.trae')))
    parser.add_argument('--shared-skills', type=Path, default=Path(os.environ.get('CODEX_SKILLS_HOME', Path.home()/'.agents/skills')))
    parser.add_argument('--backup-dir', type=Path)
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--replace-conflicts', action='store_true')
    parser.add_argument("--retire-legacy", action="append", choices=LEGACY_FILES, default=[],
                        help="explicitly reviewed old YCT file to back up and retire; never inferred from text")
    args = parser.parse_args()
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S') + '-' + str(os.getpid())
    backup = args.backup_dir or Path.home()/'.yct-agent-backups'/('traex-'+stamp)
    try:
        installer = Installer(args.trae_home, args.shared_skills, backup, args.dry_run, args.replace_conflicts, args.retire_legacy)
        installer.plan()
        installer.apply()
    except (OSError, ValueError, KeyError) as exc:
        print(f'TraeX install failed: {exc}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
