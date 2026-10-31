final class ClinicalRecordDto {
  const ClinicalRecordDto({
    this.id,
    required this.kind,
    required this.description,
  });
  final String? id;
  final String kind;
  final String description;
  factory ClinicalRecordDto.fromJson(Map<String, dynamic> json) {
    if (json['description'] is! String ||
        !['vaccination', 'deworming', 'medication'].contains(json['kind'])) {
      throw const FormatException('Invalid care record');
    }
    return ClinicalRecordDto(
      id: json['id'] as String?,
      kind: json['kind'] as String,
      description: json['description'] as String,
    );
  }
  Map<String, Object?> toJson() => {
    'id': id,
    'kind': kind,
    'description': description,
  };
}
