import hashlib
import json
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[2]

class PresentationPhotoTest(unittest.TestCase):
    def test_versioned_offline_photos_match_authorized_manifest(self):
        manifest = json.loads((ROOT / 'supabase/demo/animals.json').read_text(encoding='utf-8'))
        for slug in ['amora', 'bento', 'mel']:
            with self.subTest(slug=slug):
                item = next(row for row in manifest['animals'] if row['slug'] == slug)
                data = (ROOT / f'test/fixtures/presentation/{slug}.jpg').read_bytes()
                self.assertEqual(len(data), item['photo']['bytes'])
                self.assertEqual(hashlib.sha256(data).hexdigest(), item['photo']['sha256'])
                self.assertTrue(data.startswith(b'\xff\xd8'))
                self.assertTrue(item['photo']['source_url'].startswith('https://images.unsplash.com/'))

if __name__ == '__main__': unittest.main()
