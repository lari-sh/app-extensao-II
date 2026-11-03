"""Verify that CI runs every Android journey and never hides a failed gate."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / '.github/scripts/run_android_journeys.sh'
EXPECTED = [
    'public_catalog', 'visitor_detail', 'authentication',
    'management_dashboard', 'animal_editor', 'medication_calendar',
    'adoption_contact', 'team_access', 'password_recovery', 'management_search',
]


class AndroidJourneyRunnerTest(unittest.TestCase):
    def setUp(self):
        git_bash = Path('C:/Program Files/Git/bin/bash.exe')
        self.bash = str(git_bash) if os.name == 'nt' and git_bash.exists() else shutil.which('bash')
        if not self.bash:
            self.skipTest('Bash is required for the Linux CI runner')
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.folder = Path(self.temp.name)
        self.commands = self.folder / 'commands.txt'
        stubs = {
            'adb': '''#!/usr/bin/env bash
if [[ "$*" == *get-state ]]; then printf '%s\\n' "$ADB_STATE"; fi
''',
            'timeout': '''#!/usr/bin/env bash
if [[ "$1" == --signal=* ]]; then shift 3; else shift; fi
exec "$@"
''',
            'flutter': '''#!/usr/bin/env bash
printf '%s\\n' "$*" >> "$JOURNEY_COMMANDS"
if [[ -n "$FAIL_TARGET" && "$*" == *"$FAIL_TARGET"* ]]; then exit 7; fi
''',
        }
        for name, content in stubs.items():
            path = self.folder / name
            path.write_text(content, encoding='utf-8', newline='\n')
            path.chmod(0o755)

    def run_runner(self, **overrides):
        env = os.environ.copy()
        env.update(
            PATH=str(self.folder) + os.pathsep + env['PATH'],
            SUPABASE_ANON_KEY='public-test-key', ADB_STATE='device',
            FAIL_TARGET='', JOURNEY_COMMANDS=self.commands.as_posix(),
        )
        env.update(overrides)
        # Git Bash resets PATH on startup; prepend the fixture directory in
        # the child shell too, without interpolating it as shell source.
        result = subprocess.run(
            [self.bash, '-c',
             'fixture=$1; if command -v cygpath >/dev/null; then fixture=$(cygpath -u "$fixture"); fi; export PATH="$fixture:$PATH"; bash "$2"',
             'runner-test', self.folder.as_posix(), SCRIPT.as_posix()],
            cwd=ROOT, env=env, capture_output=True, text=True, timeout=20,
        )
        commands = self.commands.read_text(encoding='utf-8').splitlines() if self.commands.exists() else []
        return result, commands

    def test_all_ten_journeys_have_independent_dds_invocations(self):
        result, commands = self.run_runner()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(commands), 10)
        for name, command in zip(EXPECTED, commands):
            self.assertIn(f'integration_test/{name}_flow_test.dart', command)
            self.assertIn('--dds', command)
            self.assertNotIn('--no-dds', command)
            self.assertIn('-d emulator-5554', command)

    def test_failed_journey_keeps_its_exit_code_and_stops_later_tests(self):
        result, commands = self.run_runner(FAIL_TARGET='visitor_detail_flow_test.dart')
        self.assertEqual(result.returncode, 7, result.stderr)
        self.assertEqual(len(commands), 2)
        self.assertIn('failed (exit 7)', result.stderr)

    def test_offline_device_cannot_be_reported_as_a_pass(self):
        result, commands = self.run_runner(ADB_STATE='offline')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(commands, [])
        self.assertIn('transport unavailable', result.stderr)

    def test_missing_test_configuration_stops_before_flutter(self):
        result, commands = self.run_runner(SUPABASE_ANON_KEY='')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(commands, [])


if __name__ == '__main__':
    unittest.main()
