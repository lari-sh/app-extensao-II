// Fictional presentation animals; photos are illustrative, never medical records.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'public_fixtures.dart';

PublicAnimal presentationAnimal(String slug) {
  final manifest =
      jsonDecode(File('supabase/demo/animals.json').readAsStringSync())
          as Map<String, dynamic>;
  final records = manifest['animals'] as List;
  final index = records.indexWhere((row) => row['slug'] == slug);
  final payload = Map<String, dynamic>.from(records[index]['payload'] as Map);
  return PublicAnimal(
    id: fixtureId(100 + index),
    name: payload['name'] as String,
    species: AnimalSpecies.values.byName(payload['species'] as String),
    sex: AnimalSex.values.byName(payload['sex'] as String),
    size: AnimalSize.values.byName(payload['size'] as String),
    approximateAge: payload['approximate_age'] as String,
    publicDescription: payload['public_description'] as String,
    isPublished: true,
    isNeutered: payload['is_neutered'] as bool,
    isVaccinated: payload['is_vaccinated'] as bool,
    weightKg: (payload['weight_kg'] as num).toDouble(),
    color: payload['color'] as String,
    temperament: payload['temperament'] as String,
    lastDewormedOn: payload['last_dewormed_on'] as String,
    vaccinations: (payload['vaccinations'] as List)
        .map(
          (v) => PublicVaccination(
            appliedOn: v['applied_on'] as String,
            vaccineType: v['vaccine_type'] as String,
          ),
        )
        .toList(),
    primaryPhotoId: fixtureId(200 + index),
  );
}

Uint8List presentationPhoto(String slug) =>
    File('test/fixtures/presentation/$slug.jpg').readAsBytesSync();
