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
  const PhotoJobDto({required this.id, required this.state, this.photoId});
  final String id;
  final String state;
  final String? photoId;
}
