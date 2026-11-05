import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/data/models/animal_dto.dart';

String fixtureId(int value) =>
    '00000000-0000-4000-8000-${value.toString().padLeft(12, '0')}';
PublicAnimal fixtureAnimal(int value) => PublicAnimal(
  id: fixtureId(value),
  name: 'Luna $value',
  species: AnimalSpecies.dog,
  sex: AnimalSex.female,
  size: AnimalSize.medium,
  approximateAge: '2 anos',
  isPublished: true,
);
AnimalDto fixtureDto(int value) => AnimalDto.fromJson({
  'id': fixtureId(value),
  'name': 'Luna $value',
  'species': 'dog',
  'sex': 'female',
  'size': 'medium',
  'approximate_age': '2 anos',
  'public_description': 'Publico',
  'status': 'available',
  'is_published': true,
  'is_vaccinated': false,
  'is_neutered': false,
});
