import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/data/repositories/photo_repository_impl.dart';
import 'package:abrigo_dos_anjos/data/models/photo_dto.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_content.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../support/fakes/fake_photo_api_service.dart';

void main() {
  test(
    'photo reads have four request limit and no stale cache on refresh',
    () async {
      var active = 0, maximum = 0;
      final pending = <Completer<Object?>>[];
      final service = FakePhotoApiService()
        ..handler = (method, args) async {
          active++;
          if (active > maximum) maximum = active;
          final completer = Completer<Object?>();
          pending.add(completer);
          try {
            return await completer.future;
          } finally {
            active--;
          }
        };
      final repo = PhotoRepositoryImpl(service);
      final futures = List.generate(6, (i) => repo.readPrimary('animal', '$i'));
      await Future<void>.delayed(Duration.zero);
      expect(pending.length, 4);
      final dto = PhotoBytesDto(
        bytes: [137, 80, 78, 71, 13, 10, 26, 10],
        mime: 'image/png',
      );
      for (final item in pending.toList()) {
        item.complete(Success(dto));
      }
      await Future<void>.delayed(Duration.zero);
      for (final item in pending.skip(4)) {
        item.complete(Success(dto));
      }
      expect(
        (await Future.wait(futures)).every((r) => r is Success<PhotoContent>),
        isTrue,
      );
      expect(maximum, 4);
      service.handler = (_, args) async =>
          Failure<PhotoBytesDto>(AppFailure(FailureCode.notFound));
      expect(
        (await repo.readPrimary('animal', '0') as Failure).failure.code,
        FailureCode.notFound,
      );
    },
  );
  test(
    'invalid photo data fails without raw exception and upload remains unavailable',
    () async {
      final service = FakePhotoApiService()
        ..handler = (_, args) async =>
            Success(PhotoBytesDto(bytes: [1, 2], mime: 'text/html'));
      final repo = PhotoRepositoryImpl(service);
      expect(await repo.readPrimary('animal', 'photo'), isA<Failure>());
      expect(await repo.pickFromGallery(), isA<Failure>());
    },
  );
}
