const medicationAnimalId = '77000000-0000-4000-8000-000000000001';
const medicationTreatmentId = '87000000-0000-4000-8000-000000000001';
const medicationApplicationId = '97000000-0000-4000-8000-000000000001';
Map<String, dynamic> medicationTreatmentJson() => {
  'id': medicationTreatmentId,
  'animal_id': medicationAnimalId,
  'revision': 1,
  'version': 1,
  'medication_name': 'Medicação de teste',
  'instructions': 'Instrução de teste',
  'status': 'active',
  'schedule_mode': 'fixed_times',
  'starts_on': '2026-11-01',
  'starts_time': '08:00',
  'ends_on': '2026-11-02',
  'ends_time': '20:00',
  'fixed_times': ['08:00', '20:00'],
  'interval_minutes': null,
  'timezone': 'America/Sao_Paulo',
};
Map<String, dynamic> medicationApplicationJson() => {
  'id': medicationApplicationId,
  'treatment_id': medicationTreatmentId,
  'animal_id': medicationAnimalId,
  'animal_name': 'Animal de teste',
  'medication_name': 'Medicação de teste',
  'instructions': 'Instrução de teste',
  'revision': 1,
  'version': 1,
  'scheduled_at': '2026-11-01T11:00:00Z',
  'scheduled_local_date': '2026-11-01',
  'scheduled_local_time': '08:00',
  'state': 'pending',
  'performed_by': null,
  'actor_label': null,
  'performed_at': null,
  'performed_local_date': null,
  'performed_local_time': null,
};
Map<String, dynamic> medicationCommandJson() => {
  'operation_key': 'k' * 32,
  'server_now': '2026-11-01T12:00:00Z',
  'result': {'treatment': medicationTreatmentJson()},
};

class MutableMedicationClock {
  MutableMedicationClock(this.value);
  DateTime value;
  DateTime call() => value;
  void advance(Duration duration) {
    value = value.add(duration);
  }
}
