import '../../utils/civil_date.dart';
import '../../utils/animal_code.dart';

final class AnimalDto {
  AnimalDto(Map<String, Object?> values) : values = Map.unmodifiable(values);
  final Map<String, Object?> values;
  factory AnimalDto.fromJson(Map<String, dynamic> json) {
    final values = <String, Object?>{};
    final code = json['animal_code'];
    if (code != null && (code is! String || !isAnimalCode(code))) {
      throw const FormatException('Invalid animal code');
    }
    // Immutable pre-migration operation replays may omit the newly added field.
    if (json.containsKey('animal_code')) values['animal_code'] = code;
    for (final key in [
      'id',
      'name',
      'species',
      'sex',
      'size',
      'approximate_age',
      'public_description',
      'status',
    ]) {
      if (json[key] is! String) {
        throw FormatException('Invalid animal field: $key');
      }
      values[key] = json[key];
    }
    for (final entry in {
      'species': ['dog', 'cat'],
      'sex': ['female', 'male'],
      'size': ['small', 'medium', 'large'],
      'status': ['available', 'treatment', 'quarantine', 'adopted'],
    }.entries) {
      if (!entry.value.contains(values[entry.key])) {
        throw FormatException('Invalid enum: ${entry.key}');
      }
    }
    for (final key in ['is_published', 'is_vaccinated', 'is_neutered']) {
      if (json[key] is! bool) {
        throw FormatException('Invalid animal field: $key');
      }
      values[key] = json[key];
    }
    if (json['primary_photo_id'] != null &&
        json['primary_photo_id'] is! String) {
      throw const FormatException('Invalid photo id');
    }
    values['primary_photo_id'] = json['primary_photo_id'];
    for (final key in ['last_dewormed_on', 'temperament', 'color']) {
      if (json[key] != null && json[key] is! String) {
        throw FormatException('Invalid $key');
      }
      values[key] = json[key];
    }
    for (final entry in {'temperament': 120, 'color': 80}.entries) {
      final text = json[entry.key] as String?;
      if (text != null &&
          (text.trim().isEmpty || text.runes.length > entry.value)) {
        throw FormatException('Invalid ${entry.key}');
      }
    }
    final date = json['last_dewormed_on'];
    if (date != null && canonicalDate(date as String) != date) {
      throw const FormatException('Invalid date');
    }
    final weight = json['weight_kg'];
    if (weight != null &&
        (weight is! num || !weight.isFinite || weight <= 0 || weight > 1000)) {
      throw const FormatException('Invalid weight');
    }
    values['weight_kg'] = (weight as num?)?.toDouble();
    final vaccinations = json['vaccinations'] ?? <dynamic>[];
    if (vaccinations is! List || vaccinations.length > 100) {
      throw const FormatException('Invalid vaccinations');
    }
    values['vaccinations'] = List<Map<String, String>>.unmodifiable(
      vaccinations.map((item) {
        if (item is! Map ||
            item.length != 2 ||
            item['applied_on'] is! String ||
            item['vaccine_type'] is! String ||
            canonicalDate(item['applied_on'] as String) != item['applied_on'] ||
            (item['vaccine_type'] as String).trim().isEmpty ||
            (item['vaccine_type'] as String).runes.length > 120) {
          throw const FormatException('Invalid vaccination');
        }
        return Map<String, String>.unmodifiable({
          'applied_on': item['applied_on'] as String,
          'vaccine_type': item['vaccine_type'] as String,
        });
      }),
    );
    return AnimalDto(values);
  }
}

final class AnimalsPageDto {
  AnimalsPageDto({
    required List<AnimalDto> items,
    required this.total,
    this.cursor,
  }) : items = List.unmodifiable(items);
  final List<AnimalDto> items;
  final int total;
  final String? cursor;
}

final class ManagedAnimalDto {
  ManagedAnimalDto({
    required this.animal,
    required this.clinicalNotes,
    required List<Map<String, dynamic>> careRecords,
  }) : careRecords = List.unmodifiable(
         careRecords.map((item) => Map<String, dynamic>.unmodifiable(item)),
       );
  factory ManagedAnimalDto.fromJson(Map<String, dynamic> json) {
    final notes = json['clinical_notes'];
    final records = json['care_records'];
    if (notes is! String || records is! List) {
      throw const FormatException('Invalid private data');
    }
    return ManagedAnimalDto(
      animal: AnimalDto.fromJson(
        (json['animal'] as Map).cast<String, dynamic>(),
      ),
      clinicalNotes: notes,
      careRecords: records
          .map((item) => (item as Map).cast<String, dynamic>())
          .toList(),
    );
  }
  final AnimalDto animal;
  final String clinicalNotes;
  final List<Map<String, dynamic>> careRecords;
}

final class ManagedAnimalsPageDto {
  ManagedAnimalsPageDto({
    required List<ManagedAnimalDto> items,
    required this.total,
    this.cursor,
  }) : items = List.unmodifiable(items);
  final List<ManagedAnimalDto> items;
  final int total;
  final String? cursor;
}
