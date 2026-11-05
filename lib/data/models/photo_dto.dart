final class GallerySelectionDto {
  GallerySelectionDto({required List<int> bytes, required this.mime})
    : bytes = List.unmodifiable(bytes);
  final List<int> bytes;
  final String mime;
}

final class PhotoBytesDto {
  PhotoBytesDto({required List<int> bytes, required this.mime})
    : bytes = List.unmodifiable(bytes);
  final List<int> bytes;
  final String mime;
}

final class PhotoJobDto {
  const PhotoJobDto({
    required this.id,
    required this.state,
    this.photoId,
    this.currentPhotoId,
  });
  final String id;
  final String state;
  final String? photoId;
  final String? currentPhotoId;
  factory PhotoJobDto.fromJson(Map<String, dynamic> data) {
    if (data['job_id'] is! String ||
        ![
          'pending',
          'validated',
          'attached',
          'cleanup_needed',
          'cleaned',
          'failed',
        ].contains(data['state']) ||
        (data['photo_id'] != null && data['photo_id'] is! String) ||
        (data['current_photo_id'] != null &&
            data['current_photo_id'] is! String)) {
      throw const FormatException('Invalid photo job');
    }
    return PhotoJobDto(
      id: data['job_id'] as String,
      state: data['state'] as String,
      photoId: data['photo_id'] as String?,
      currentPhotoId: data['current_photo_id'] as String?,
    );
  }
}
