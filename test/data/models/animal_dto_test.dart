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
