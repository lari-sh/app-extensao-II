"""Enforce the agreed global line coverage using every line in Flutter's LCOV."""
from pathlib import Path
import sys
path=Path(sys.argv[1] if len(sys.argv)>1 else 'coverage/lcov.info')
if not path.is_file():
 raise SystemExit('FAIL: coverage report missing')
lines=[line[3:].split(',') for line in path.read_text(encoding='utf-8').splitlines() if line.startswith('DA:')]
if not lines:
 raise SystemExit('FAIL: coverage report has no executable lines')
hits=sum(int(value)>0 for _,value,*_ in lines)
total=len(lines)
print(f'Global line coverage: {hits}/{total} = {100*hits/total:.2f}% (required: 99%)')
if hits*100<total*99:
 raise SystemExit('FAIL: global line coverage below 99%')
