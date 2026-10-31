import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/photo_repository_impl.dart';
import 'package:abrigo_dos_anjos/data/models/photo_dto.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_candidate.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_upload_state.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/fakes/fake_photo_api_service.dart';
import '../../support/fakes/fake_gallery_service.dart';
import '../../support/public_fixtures.dart';

void main() {
  test(
    'gallery cancellation, recovery and permission failure never trigger upload',
    () async {
      final api = FakePhotoApiService();
      final gallery = FakeGalleryService()
        ..handler = (_, _) async => const Success<GallerySelectionDto?>(null);
      final repo = PhotoRepositoryImpl(api, gallery: gallery);
      expect((await repo.pickFromGallery() as Success).value, isNull);
      gallery.handler = (_, _) async => Success<GallerySelectionDto?>(
        GallerySelectionDto(bytes: [255, 216, 255], mime: 'image/jpeg'),
      );
      expect(
        (await repo.recoverLostSelection() as Success<PhotoCandidate?>)
            .value
            ?.mime,
        'image/jpeg',
      );
      gallery.handler = (_, _) async => Failure<GallerySelectionDto?>(
        AppFailure(FailureCode.permissionDenied),
      );
      expect(
        (await repo.pickFromGallery() as Failure).failure.code,
        FailureCode.permissionDenied,
      );
      expect(api.calls, isEmpty);
    },
  );
  test(
    'upload preserves operation identity and maps server job without plugin types',
    () async {
      final api = FakePhotoApiService()
        ..handler = (_, _) async => const Success(
          PhotoJobDto(id: 'job', state: 'attached', photoId: 'photo'),
        );
      final repo = PhotoRepositoryImpl(api);
      final result = await repo.uploadPrimary(
        fixtureId(1),
        const PhotoCandidate(bytes: [255, 216, 255], mime: 'image/jpeg'),
        'a' * 32,
      );
      expect(
        (result as Success<PhotoUploadState>).value.status,
        PhotoJobStatus.attached,
      );
      expect(api.calls.single.arguments.last, 'a' * 32);
      expect(await repo.getUpload('a' * 32), isA<Success>());
      api.handler = (_, _) async => throw StateError('private');
      expect(await repo.getUpload('a' * 32), isA<Failure>());
    },
  );
}
