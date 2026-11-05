"""Drive only Android's native picker for photo_gallery_flow_test.dart.

Start alongside flutter test, after pushing synthetic PNG fixtures into Pictures.
Never interacts with Flutter forms or reads/logs credentials.
"""
import argparse
import binascii
from pathlib import Path
import struct
import sys
import zlib
import re
import subprocess
import time
import xml.etree.ElementTree as ET

parser = argparse.ArgumentParser()
parser.add_argument('--adb', required=True)
parser.add_argument('--prepare-media', action='store_true')
parser.add_argument('--serial', default='emulator-5554')
parser.add_argument('--skip-cancel', action='store_true')
parser.add_argument('--start-step', type=int, default=0)
parser.add_argument('--photo-index', type=int)
args = parser.parse_args()


def adb(*commands):
    return subprocess.check_output([args.adb, '-s', args.serial, *commands], stderr=subprocess.DEVNULL)


if args.prepare_media:
    directory=Path('.tools/android').resolve()
    assert directory.is_relative_to(Path.cwd().resolve()), 'Fixture directory must stay in workspace'
    directory.mkdir(parents=True,exist_ok=True)
    adb('shell','mkdir','-p','/sdcard/Pictures')
    for name,color in [('one',(190,40,40,255)),('two',(110,65,30,255))]:
        def chunk(kind,data):
            return struct.pack('>I',len(data))+kind+data+struct.pack('>I',binascii.crc32(kind+data)&0xffffffff)
        raw=b''.join(b'\x00'+bytes(color)*128 for _ in range(96))
        png=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',128,96,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(raw))+chunk(b'IEND',b'')
        target=directory/('abrigo_photo_'+name+'.png')
        target.write_bytes(png)
        destination='/sdcard/Pictures/'+target.name
        adb('push',str(target),destination)
        adb('shell','am','broadcast','-a','android.intent.action.MEDIA_SCANNER_SCAN_FILE','-d','file://'+destination)
    print('Two synthetic native photo fixtures prepared.',flush=True)
    sys.exit(0)


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
