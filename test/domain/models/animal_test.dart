import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_draft.dart';
import 'package:abrigo_dos_anjos/domain/models/clinical_record.dart';

void main() {
  const valid = AnimalDraft(
    name: 'Luna',
    approximateAge: '2 anos',
    species: AnimalSpecies.dog,
    sex: AnimalSex.female,
    size: AnimalSize.medium,
  );
  test('copyWith retains original and compares immutable values', () {
    final copy = valid.copyWith(name: 'Mia');
    expect(valid.name, 'Luna');
    expect(copy.name, 'Mia');
    expect(valid.copyWith(), valid);
    final source = <ClinicalRecord>[];
    final draft = valid.copyWith(careRecords: source);
    expect(
      () => draft.careRecords.add(
        const ClinicalRecord(
          kind: ClinicalRecordKind.medication,
          description: 'Registro',
        ),
      ),
      throwsUnsupportedError,
    );
  });
  test('required text boundaries and enums are validated', () {
    for (final length in [0, 81]) {
      expect(valid.copyWith(name: 'a' * length).validate(), contains('name'));
      expect(
        valid.copyWith(approximateAge: 'a' * length).validate(),
        contains('approximateAge'),
      );
    }
    for (final length in [1, 80]) {
      expect(valid.copyWith(name: 'a' * length).validate(), isEmpty);
    }
    expect(valid.copyWith(species: null).validate(), contains('species'));
    expect(valid.copyWith(name: '   ').validate(), contains('name'));
  });
  test('description and care limits apply to all draft fields', () {
    expect(
      valid
          .copyWith(publicDescription: 'a' * 3000, clinicalNotes: 'a' * 3000)
          .validate(),
      isEmpty,
    );
    expect(
      valid.copyWith(publicDescription: 'a' * 3001).validate(),
      contains('publicDescription'),
    );
    expect(
      valid.copyWith(clinicalNotes: 'a' * 3001).validate(),
      contains('clinicalNotes'),
    );
    for (final length in [0, 1001]) {
      expect(
        valid
            .copyWith(
              careRecords: [
                ClinicalRecord(
                  kind: ClinicalRecordKind.vaccination,
                  description: 'a' * length,
                ),
              ],
            )
            .validate(),
        contains('careRecords.0.description'),
      );
    }
    for (final length in [1, 1000]) {
      expect(
        valid
            .copyWith(
              careRecords: [
                ClinicalRecord(
                  kind: ClinicalRecordKind.vaccination,
                  description: 'a' * length,
                ),
              ],
            )
            .validate(),
        isEmpty,
      );
    }
  });
}
