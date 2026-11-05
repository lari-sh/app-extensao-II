import 'fake_behavior.dart';
import 'package:abrigo_dos_anjos/data/services/gallery_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/data/models/photo_dto.dart';

class FakeGalleryService extends FakeBehavior implements GalleryService {
  @override
  Future<Result<GallerySelectionDto?>> pickFromGallery() =>
      invoke<GallerySelectionDto?>('pickFromGallery', []);
  @override
  Future<Result<GallerySelectionDto?>> recoverLostSelection() =>
      invoke<GallerySelectionDto?>('recoverLostSelection', []);
}
