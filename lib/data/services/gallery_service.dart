import '../../utils/result.dart';
import '../models/photo_dto.dart';

abstract interface class GalleryService {
  Future<Result<GallerySelectionDto?>> pickFromGallery();
  Future<Result<GallerySelectionDto?>> recoverLostSelection();
}
