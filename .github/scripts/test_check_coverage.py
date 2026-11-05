"""Check the coverage gate at its actual boundary, without rounding approval."""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


class CoverageGateTest(unittest.TestCase):
    def check_report(self, hits, total, succeeds):
        with tempfile.TemporaryDirectory() as directory:
            report = Path(directory) / 'lcov.info'
            if total is not None:
                report.write_text('SF:example.dart\n' + ''.join(
                    f'DA:{index + 1},{int(index < hits)}\n'
                    for index in range(total)
                ) + 'end_of_record\n', encoding='utf-8')
            result = subprocess.run([
                sys.executable, str(Path(__file__).with_name('check_coverage.py')),
                str(report),
            ], capture_output=True, text=True)
            self.assertEqual(result.returncode == 0, succeeds,
                             result.stdout + result.stderr)

    def test_exactly_99_percent_passes(self):
        self.check_report(99, 100, True)

    def test_rounding_cannot_approve_below_99_percent(self):
        self.check_report(9899, 10000, False)

    def test_full_coverage_passes(self):
        self.check_report(100, 100, True)

    def test_missing_report_fails(self):
        self.check_report(0, None, False)

    def test_empty_executable_report_fails(self):
        self.check_report(0, 0, False)


if __name__ == '__main__':
    unittest.main()
