"""Drive only Android's native picker for photo_gallery_flow_test.dart.

Start alongside flutter test, after pushing synthetic PNG fixtures into Pictures.
Never interacts with Flutter forms or reads/logs credentials.
"""
import argparse
import re
import subprocess
import time
import xml.etree.ElementTree as ET

parser = argparse.ArgumentParser()
parser.add_argument('--adb', required=True)
parser.add_argument('--serial', default='emulator-5554')
parser.add_argument('--skip-cancel', action='store_true')
parser.add_argument('--start-step', type=int, default=0)
parser.add_argument('--photo-index', type=int)
args = parser.parse_args()


def adb(*commands):
    return subprocess.check_output([args.adb, '-s', args.serial, *commands], stderr=subprocess.DEVNULL)


def snapshot():
    adb('shell', 'uiautomator', 'dump', '/sdcard/abrigo-picker.xml')
    return ET.fromstring(adb('exec-out', 'cat', '/sdcard/abrigo-picker.xml'))


def picker(root):
    return any(any(name in node.get('package','') for name in ('providers.media','documentsui','photopicker')) for node in root.iter('node'))


def tap(node):
    values = list(map(int, re.findall(r'\d+', node.get('bounds', ''))))
    if len(values) != 4:
        raise RuntimeError('Native picker target has no bounds')
    adb('shell', 'input', 'tap', str((values[0]+values[2])//2), str((values[1]+values[3])//2))


for step in range(args.start_step or (1 if args.skip_cancel else 0),3):
    deadline = time.monotonic()+180
    while time.monotonic()<deadline:
        try:
            root = snapshot()
            if picker(root):
                break
        except (subprocess.SubprocessError, ET.ParseError):
            pass
        time.sleep(1)
    else:
        raise RuntimeError('Native picker did not open for step '+str(step))
    if step == 0:
        adb('shell', 'input', 'keyevent', '4')
        print('Native picker cancellation sent.', flush=True)
    else:
        targets = [node for node in root.iter('node') if 'thumbnail' in node.get('resource-id', '').lower() or node.get('content-desc','').startswith('Photo taken on')]
        if not targets:
            raise RuntimeError('No native photo thumbnails found; inspect the fixture media index')
        tap(targets[min(args.photo_index if args.photo_index is not None else step-1, len(targets)-1)])
        print('Native fixture selected for step '+str(step), flush=True)
        time.sleep(1)
        root = snapshot()
        if picker(root):
            buttons = [node for node in root.iter('node') if node.get('text') in ('Add','Select','Done','Open','Adicionar','Selecionar')]
            if buttons:
                tap(buttons[-1])
    # Flutter may open the next picker before a slow UI dump observes the
    # intervening Activity. Wait for the next action instead of requiring a
    # transient closed window to be captured.
    time.sleep(2)
print('All native picker actions completed.', flush=True)
