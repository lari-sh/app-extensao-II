import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/models/animal_dto.dart';

void main() {
  final json = <String, dynamic>{
    'id': 'id',
    'name': 'Luna',
    'species': 'dog',
    'sex': 'female',
    'size': 'medium',
    'approximate_age': '2 anos',
    'public_description': 'Publico',
    'status': 'available',
    'is_published': true,
    'is_vaccinated': false,
    'is_neutered': false,
    'primary_photo_id': null,
  };
  test(
    'rejects invalid photo and optional public attribute types and lengths',
    () {
      for (final change in <Map<String, dynamic>>[
        {'primary_photo_id': 42},
        {'color': false},
        {'temperament': 12},
        {'color': '  '},
        {'temperament': List.filled(121, 'a').join()},
      ]) {
        expect(
          () => AnimalDto.fromJson({...json, ...change}),
          throwsFormatException,
        );
      }
    },
  );
  test(
    'public profile validates dates and rejects private vaccination attributes',
    () {
      expect(AnimalDto.fromJson(json).values['vaccinations'], isEmpty);
      expect(
        () => AnimalDto.fromJson({...json, 'last_dewormed_on': '2024-02-31'}),
        throwsFormatException,
      );
      expect(
        () => AnimalDto.fromJson({...json, 'weight_kg': -1}),
        throwsFormatException,
      );
      expect(
        () => AnimalDto.fromJson({
          ...json,
          'vaccinations': [
            {
              'applied_on': '2024-02-29',
              'vaccine_type': 'V4',
              'notes': 'secret',
            },
          ],
        }),
        throwsFormatException,
      );
      expect(
        AnimalDto.fromJson({
          ...json,
          'weight_kg': 4,
          'vaccinations': [
            {'applied_on': '2024-02-29', 'vaccine_type': 'V4'},
          ],
        }).values['weight_kg'],
        4.0,
      );
    },
  );
  test(
    'public DTO discards private fields and rejects malformed API values',
    () {
      final dto = AnimalDto.fromJson({
        ...json,
        'clinical_notes': 'secret',
        'created_by': 'actor',
      });
      expect(dto.values.containsKey('clinical_notes'), isFalse);
      expect(dto.values.containsKey('created_by'), isFalse);
      expect(() => dto.values.clear(), throwsUnsupportedError);
      expect(
        () => AnimalDto.fromJson({...json, 'species': 'bird'}),
        throwsFormatException,
      );
      expect(
        () => AnimalDto.fromJson({...json, 'is_published': 'true'}),
        throwsFormatException,
      );
      expect(
        () => AnimalDto.fromJson({...json}..remove('name')),
        throwsFormatException,
      );
    },
  );
}
