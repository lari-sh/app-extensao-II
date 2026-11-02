import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/managed_animal_search_filter.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/animal_code.dart';

void main() {
  test('criteria normalize and all five filters activate global search', () {
    expect(const ManagedAnimalSearchFilter().hasCriteria, isFalse);
    expect(
      const ManagedAnimalSearchFilter(query: '  ', color: ' ').hasCriteria,
      isFalse,
    );
    final value = const ManagedAnimalSearchFilter(
      query: ' Luna ',
      color: ' preto ',
      species: AnimalSpecies.dog,
      sex: AnimalSex.female,
      size: AnimalSize.small,
      status: AnimalStatus.quarantine,
    ).normalized;
    expect(value.query, 'Luna');
    expect(value.color, 'preto');
    expect(value.hasCriteria, isTrue);
    expect(value.validate(), isEmpty);
    for (final value in [
      const ManagedAnimalSearchFilter(species: AnimalSpecies.cat),
      const ManagedAnimalSearchFilter(sex: AnimalSex.male),
      const ManagedAnimalSearchFilter(size: AnimalSize.large),
      const ManagedAnimalSearchFilter(status: AnimalStatus.adopted),
      const ManagedAnimalSearchFilter(color: 'preto'),
    ]) {
      expect(value.hasCriteria, isTrue);
    }
    expect(
      ManagedAnimalSearchFilter(
        query: 'ç' * 81,
        color: 'x' * 81,
      ).validate().keys,
      containsAll(['query', 'color']),
    );
  });
  test(
    'readable codes are canonical, do not truncate and are not invented',
    () {
      for (final value in [
        'A0001',
        'A9999',
        'A10000',
        'A9223372036854775807',
      ]) {
        expect(isAnimalCode(value), isTrue);
      }
      for (final value in [
        null,
        '',
        'a0001',
        'A0000',
        'A00001',
        'A1',
        'uuid',
        'A12345678901234567890',
      ]) {
        expect(isAnimalCode(value), isFalse);
      }
    },
  );
}
