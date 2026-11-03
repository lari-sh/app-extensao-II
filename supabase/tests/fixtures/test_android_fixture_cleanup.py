"""Real loopback cleanup regression. Uses only newly created local test rows."""
from http.server import HTTPServer
from threading import Thread
from urllib.request import Request, urlopen
from urllib.error import HTTPError
from datetime import date
import json
import subprocess
import unittest
import uuid
import medication_flow as fixtures
from android_auth_control import Handler

class AndroidMedicationCleanupTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = HTTPServer(('127.0.0.1', 0), Handler)
        cls.thread = Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.url = 'http://127.0.0.1:' + str(cls.server.server_port)

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join(timeout=5)

    def sql(self, statement):
        result = subprocess.run(['docker', 'exec', '-i', fixtures.container, 'psql', '-X', '-Atq', '-v', 'ON_ERROR_STOP=1', '-U', 'postgres', '-d', 'postgres'], input=statement, encoding='utf-8', capture_output=True, timeout=20)
        self.assertEqual(result.returncode, 0, 'Local fixture SQL failed')
        return result.stdout.strip()

    def post(self, payload):
        request = Request(self.url + '/cleanup-medication-fixture', data=json.dumps(payload).encode(), headers={'Content-Type':'application/json'}, method='POST')
        try:
            with urlopen(request, timeout=30) as response:
                return response.status
        except HTTPError as error:
            status = error.code
            error.close()
            return status

    def test_invalid_payload_is_rejected(self):
        for payload in [{}, {'animal_id':'invalid'}, {'animal_id':'x' * 1500}]:
            with self.subTest(payload_size=len(str(payload))):
                self.assertEqual(self.post(payload), 400)

    def test_cleanup_removes_only_owned_fixture_and_restores_total(self):
        baseline = int(self.sql('select count(*) from public.animals;'))
        token = fixtures.request('/auth/v1/token?grant_type=password', {'email':'fixture-staff@example.test','password':fixtures.environment['FIXTURE_PASSWORD']})['access_token']
        owned = None
        control = None
        control_name = 'Fixture cleanup control ' + uuid.uuid4().hex
        try:
            def create(name):
                return fixtures.rpc('save_animal', {'p_operation_key':uuid.uuid4().hex, 'p_payload':{'name':name,'species':'cat','sex':'female','size':'small','approximate_age':'1 ano'}}, token)['animal']['id']
            owned = create(fixtures.prefix + uuid.uuid4().hex)
            control = create(control_name)
            day = date.today().isoformat()
            fixtures.rpc('save_medication_treatment', {'p_operation_key':uuid.uuid4().hex,'p_payload':{'animal_id':owned,'medication_name':'Ilustrativa limpeza','schedule_mode':'fixed_times','starts_on':day,'starts_time':'00:00','ends_on':day,'ends_time':'23:59','fixed_times':['08:00']}}, token)
            self.assertEqual(self.post({'animal_id':control}), 400)
            self.assertEqual(self.sql("select count(*) from public.animals where id='"+control+"';"), '1')
            self.assertEqual(self.post({'animal_id':owned}), 204)
            self.assertEqual(self.sql("select count(*) from public.animals where id='"+owned+"';"), '0')
            self.assertEqual(int(self.sql('select count(*) from public.animals;')), baseline + 1)
            counts = fixtures.rpc('get_animal_status_counts', {}, token)
            self.assertEqual(sum(counts.values()), baseline + 1)
        finally:
            if owned and self.sql("select count(*) from public.animals where id='"+owned+"';") == '1':
                fixtures.cleanup(owned)
            if control:
                # UUID and exact unique name belong to this test; no manual row is used.
                control = str(uuid.UUID(control))
                self.sql("begin; delete from public.write_operations where result#>>'{animal,id}'='"+control+"'; delete from public.animals where id='"+control+"' and name='"+control_name+"'; commit;")
            fixtures.request('/auth/v1/logout?scope=local', {}, token, expected=204)
            self.assertEqual(int(self.sql('select count(*) from public.animals;')), baseline)

if __name__ == '__main__':
    unittest.main(verbosity=2)
