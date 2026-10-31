final class AnimalDto {
  AnimalDto(Map<String, Object?> values) : values = Map.unmodifiable(values);
  final Map<String, Object?> values;
  factory AnimalDto.fromJson(Map<String, dynamic> json) {
    final values = <String, Object?>{};
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
