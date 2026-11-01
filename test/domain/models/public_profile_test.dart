import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/domain/models/animal_draft.dart';
import 'package:abrigo_dos_anjos/utils/civil_date.dart';

void main() {
  const base = AnimalDraft(
    name: 'Luna',
    approximateAge: '2',
    species: AnimalSpecies.dog,
    sex: AnimalSex.female,
    size: AnimalSize.small,
  );
  test('civil date rejects rollover and preserves leap day', () {
    expect(canonicalDate('29/02/2024'), '2024-02-29');
    expect(canonicalDate('31/02/2024'), isNull);
    expect(displayDate('2024-02-29'), '29/02/2024');
    expect(
      validApplicationDate('2026-10-31', now: DateTime.utc(2026, 10, 31, 2)),
      isFalse,
    );
    expect(
      validApplicationDate('2026-10-30', now: DateTime.utc(2026, 10, 31, 2)),
      isTrue,
    );
  });
  test('optional public fields validate independently of private notes', () {
    expect(base.validate(), isEmpty);
    expect(
      base.copyWith(weightKg: double.nan).validate(),
      contains('weightKg'),
    );
    expect(base.copyWith(weightKg: 0).validate(), contains('weightKg'));
    expect(base.copyWith(color: 'a' * 81).validate(), contains('color'));
    expect(
      base.copyWith(temperament: 'ç' * 121).validate(),
      contains('temperament'),
    );
    expect(
      base
          .copyWith(
            temperament: 'ç' * 120,
            weightKg: 4.25,
            lastDewormedOn: '2024-02-29',
          )
          .validate(),
      isEmpty,
    );
    expect(
      base
          .copyWith(
            vaccinations: [
              const PublicVaccination(appliedOn: '2024-02-31', vaccineType: ''),
            ],
          )
          .validate(),
      containsPair('vaccinations.0.appliedOn', 'date'),
    );
  });
}
