import unittest
from retire_technical_animals import retired_ids

class RetireTechnicalAnimalsTest(unittest.TestCase):
    def test_only_exact_owned_examples_are_selected(self):
        old = {'id': '00000000-0000-4000-8000-000000000001', 'name': 'Animal de teste 01', 'public_description': 'Fixture isolada; nunca importar para producao.'}
        calendar = {'id': 'a2347c67-ffc3-40d4-9a65-607fb7a762a7', 'name': 'Teste de agenda - Bento', 'public_description': '', 'clinical_notes': 'Animal fictício para testes da agenda. Não administrar medicamentos.', 'creator': 'fixture-staff@example.test'}
        new = {'id': '41d0b718-7d0b-4a75-9981-7e168865b174', 'name': 'Bento', 'public_description': 'Apresentação'}
        self.assertEqual(retired_ids([old, calendar, new]), [old['id'], calendar['id']])
        self.assertEqual(retired_ids([new]), [])
    def test_edited_legacy_or_unconfirmed_calendar_is_rejected(self):
        for row in [
            {'id': '00000000-0000-4000-8000-000000000001', 'name': 'Animal manual', 'public_description': ''},
            {'id': 'a2347c67-ffc3-40d4-9a65-607fb7a762a7', 'name': 'Teste de agenda - Bento', 'public_description': '', 'clinical_notes': 'Animal fictício para testes da agenda. Não administrar medicamentos.', 'creator': 'someone-else@example.test'},
        ]:
            with self.assertRaises(ValueError): retired_ids([row])

if __name__ == '__main__': unittest.main()
