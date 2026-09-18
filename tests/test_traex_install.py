"""Behavior checks for TraeX installation and legacy migration."""
from pathlib import Path
import importlib.util
import json
import subprocess
import sys
import tempfile
import tomllib
import unittest

ROOT = Path(__file__).resolve().parents[1]
NL = chr(10)


class TraeXInstallTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='yct-traex-install-')
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name).resolve()
        self.home = self.base/'trae'
        self.shared = self.base/'shared'
        self.backup = self.base/'backup'
        self.home.mkdir()

    def run_install(self, *args):
        return subprocess.run([sys.executable, str(ROOT/'scripts/install_traex.py'),
                               '--trae-home', str(self.home), '--shared-skills', str(self.shared),
                               '--backup-dir', str(self.backup), *args], capture_output=True, text=True)

    def test_fresh_repeat_and_config_preservation(self):
        config = 'model = "user-choice"' + NL + '[mcp_servers.local]' + NL + 'command = "retained"' + NL
        (self.home/'traecli.toml').write_text(config)
        result = self.run_install()
        self.assertEqual(result.returncode, 0, result.stderr)
        data = tomllib.loads((self.home/'traecli.toml').read_text())
        self.assertEqual(data['model'], 'user-choice')
        self.assertEqual(data['mcp_servers']['local']['command'], 'retained')
        self.assertGreaterEqual(data['project_doc_max_bytes'], (self.home/'AGENTS.md').stat().st_size + 32768)
        self.assertIn((ROOT/'AGENTS.md').read_text().rstrip(), (self.home/'AGENTS.md').read_text())
        for name in ('yct-aa','yct-fix','yct-risk','yct-review','yct-direct'):
            self.assertEqual((self.home/'skills'/name).resolve(), self.shared/name)
        before = {p:p.read_bytes() for p in self.home.rglob('*') if p.is_file()}
        result = self.run_install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before, {p:p.read_bytes() for p in self.home.rglob('*') if p.is_file()})

    def test_quoted_config_key_preserves_multiline_values_and_nested_keys(self):
        config = NL.join([
            'note = """', 'project_doc_max_bytes = 5', '"""',
            '"project_doc_max_bytes" = 1', 'model = "keep"',
            '[custom]', 'project_doc_max_bytes = 9', ''])
        path = self.home/"traecli.toml"
        path.write_text(config)
        result = self.run_install()
        self.assertEqual(result.returncode, 0, result.stderr)
        expected = tomllib.loads(config)
        actual = tomllib.loads(path.read_text())
        self.assertGreaterEqual(actual.pop("project_doc_max_bytes"), 131072)
        expected.pop("project_doc_max_bytes")
        self.assertEqual(actual, expected)

    def test_physical_overlap_is_rejected_but_system_path_alias_is_allowed(self):
        physical = self.base/"physical"
        physical.mkdir()
        alias = self.base/"alias"
        alias.symlink_to(physical, target_is_directory=True)
        result = self.run_install("--trae-home", str(physical/"trae"),
                                  "--backup-dir", str(alias/"trae/backup"))
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((physical/"trae").exists())
        result = self.run_install("--trae-home", str(alias/"trae"))
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((physical/"trae/AGENTS.md").is_file())

    def test_stale_managed_skill_resource_is_removed_with_recoverable_backup(self):
        old = self.shared/"yct-aa/references/obsolete.md"
        old.parent.mkdir(parents=True)
        old.write_text("retired instruction")
        unrelated = self.shared/"custom/SKILL.md"
        unrelated.parent.mkdir()
        unrelated.write_text("user skill")
        result = self.run_install()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(old.exists())
        self.assertEqual((self.backup/"originals"/str(old).lstrip("/")).read_text(), "retired instruction")
        self.assertEqual(unrelated.read_text(), "user skill")

    def test_migration_preserves_unrelated_and_backs_up_removed_entry(self):
        old = NL.join(('User rule', '<!-- BEGIN YCT_AGENT_SYSTEM:CLAUDE_IMPORTS -->',
                       '@AGENTS.yct.md', '@CLAUDE.yct.md', '<!-- END YCT_AGENT_SYSTEM:CLAUDE_IMPORTS -->', ''))
        (self.home/'AGENTS.override.md').write_text(old)
        duplicate = self.home/'skills/yct-aa.backup'
        duplicate.mkdir(parents=True)
        (duplicate/'SKILL.md').write_text(NL.join(('---','name: yct-aa','---','old')))
        unrelated = self.home/'skills/other/SKILL.md'
        unrelated.parent.mkdir();unrelated.write_text('unchanged')
        result = self.run_install('--replace-conflicts','--dry-run')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual((self.home/'AGENTS.override.md').read_text(), old)
        self.assertFalse(self.backup.exists())
        result = self.run_install('--replace-conflicts')
        self.assertEqual(result.returncode, 0, result.stderr)
        text = (self.home/'AGENTS.override.md').read_text()
        self.assertTrue(text.startswith('User rule'))
        self.assertNotIn('@AGENTS.yct.md', text)
        self.assertFalse(duplicate.exists())
        self.assertEqual(unrelated.read_text(), 'unchanged')
        self.assertEqual((self.backup/'originals'/str(self.home/'AGENTS.override.md').lstrip('/')).read_text(), old)
        self.assertTrue((self.backup/'originals'/str(duplicate).lstrip('/')/'SKILL.md').exists())

    def test_bad_config_or_marker_fails_before_first_write(self):
        for bad_file,bad in [('traecli.toml','broken = ['),('AGENTS.md','<!-- BEGIN YCT_AGENT_SYSTEM:CLAUDE_IMPORTS -->')]:
            with self.subTest(bad_file=bad_file):
                path=self.home/bad_file;path.write_text(bad)
                result=self.run_install()
                self.assertNotEqual(result.returncode,0)
                self.assertEqual(path.read_text(),bad)
                self.assertFalse(self.shared.exists())
                self.assertFalse((self.home/'agents').exists())
                path.unlink()

    def test_symlinked_write_target_is_rejected(self):
        external=self.base/'external';external.mkdir()
        (self.home/'agents').symlink_to(external,target_is_directory=True)
        result=self.run_install('--replace-conflicts')
        self.assertNotEqual(result.returncode,0)
        self.assertFalse(list(external.iterdir()))
        self.assertFalse((self.home/'AGENTS.md').exists())

    def test_file_parent_and_root_alias_fail_without_partial_install(self):
        (self.home/"agents").write_text("not a directory")
        result = self.run_install()
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse((self.home/"AGENTS.md").exists())
        (self.home/"agents").unlink()
        alias = self.base/"alias"
        alias.symlink_to(self.home, target_is_directory=True)
        result = self.run_install("--trae-home", str(alias))
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(list(self.home.iterdir()))

    def test_unmanaged_legacy_named_rule_is_preserved_until_selected(self):
        rule = self.home/"rules/method-orchestration.md"
        rule.parent.mkdir()
        rule.write_text("My rule mentions TraeX and YCT but is user-owned.")
        result = self.run_install("--replace-conflicts")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(rule.exists())
        result = self.run_install("--replace-conflicts", "--retire-legacy", "rules/method-orchestration.md")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(rule.exists())
        self.assertTrue((self.backup/"originals"/str(rule).lstrip("/")).exists())

    def test_existing_canonical_link_migration_does_not_edit_source(self):
        source=self.base/'old-source';source.mkdir()
        (source/'SKILL.md').write_text('old source')
        self.shared.mkdir();(self.shared/'yct-aa').symlink_to(source,target_is_directory=True)
        result=self.run_install('--replace-conflicts')
        self.assertEqual(result.returncode,0,result.stderr)
        self.assertEqual((source/'SKILL.md').read_text(),'old source')
        self.assertFalse((self.shared/'yct-aa').is_symlink())
        self.assertEqual((self.home/'skills/yct-aa').resolve(),self.shared/'yct-aa')


class SessionEvidenceTest(unittest.TestCase):
    def test_copied_parent_turns_and_incremental_results_are_not_new_execution(self):
        spec = importlib.util.spec_from_file_location("verify_traex", ROOT/"tests/verify_traex.py")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        rows = [
            {"type": "session_meta", "payload": {"id": "child", "timestamp": "2026-09-17T10:00:00Z"}},
            {"type": "turn_context", "payload": {"turn_id": "parent-turn"}},
            {"type": "event_msg", "payload": {"type": "task_started", "turn_id": "parent-turn", "started_at": 1789630000}},
            {"type": "event_msg", "payload": {"type": "exec_command_end", "turn_id": "parent-turn", "call_id": "old", "exit_code": 0}},
            {"type": "event_msg", "payload": {"type": "task_started", "turn_id": "child-turn", "started_at": 1789639201}},
            {"type": "event_msg", "payload": {"type": "exec_command_end", "turn_id": "child-turn", "call_id": "new", "exit_code": None}},
            {"type": "event_msg", "payload": {"type": "exec_command_end", "turn_id": "child-turn", "call_id": "new", "exit_code": 2}},
        ]
        with tempfile.TemporaryDirectory() as temp:
            path = Path(temp)/"child.jsonl"
            path.write_text("".join(json.dumps(row) + NL for row in rows))
            result = module.session_commands(path, "child")
        self.assertEqual([(x["call_id"], x["exit_code"]) for x in result], [("new", 2)])


if __name__ == '__main__':
    unittest.main()
