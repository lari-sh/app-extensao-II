import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:abrigo_dos_anjos/data/services/image_picker_gallery_service.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

class Picker extends ImagePicker {
  XFile? selection;
  Object? error;
  LostDataResponse lost = LostDataResponse.empty();
  bool? metadata;
  ImageSource? source;
  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    metadata = requestFullMetadata;
    this.source = source;
    if (error != null) throw error!;
    return selection;
  }

  @override
  Future<LostDataResponse> retrieveLostData() async => lost;
}

class OversizedFile extends XFile {
  OversizedFile() : super('unused');
  bool read = false;
  @override
  Future<int> length() async => 5242881;
  @override
  Future<Uint8List> readAsBytes() async {
    read = true;
    return Uint8List(1);
  }
}

class MismatchedFile extends XFile {
  MismatchedFile() : super('unused');
  @override
  Future<int> length() async => 3;
  @override
  Future<Uint8List> readAsBytes() async => Uint8List(2);
}

void main() {
  test(
    'gallery validates actual bytes, recognizes JPEG, and sanitizes timeout/unknown failures',
    () async {
      final picker = Picker();
      final service = ImagePickerGalleryService(picker: picker);
      picker.selection = MismatchedFile();
      expect(
        (await service.pickFromGallery() as Failure).failure.code,
        FailureCode.validation,
      );
      picker.selection = XFile.fromData(Uint8List.fromList([255, 216, 255]));
      expect(
        (await service.pickFromGallery() as Success).value.mime,
        'image/jpeg',
      );
      picker.error = TimeoutException('private');
      expect(
        (await service.pickFromGallery() as Failure).failure.code,
        FailureCode.timeout,
      );
      picker.error = StateError('private');
      expect(
        (await service.pickFromGallery() as Failure).failure.code,
        FailureCode.unknown,
      );
    },
  );

  test(
    'gallery requests no full metadata, maps signature, cancellation and recovered selection',
    () async {
      final picker = Picker();
      final service = ImagePickerGalleryService(picker: picker);
      expect((await service.pickFromGallery() as Success).value, isNull);
      expect(picker.metadata, false);
      expect(picker.source, ImageSource.gallery);
      picker.selection = XFile.fromData(
        Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]),
        name: 'fake.jpg',
      );
      expect(
        (await service.pickFromGallery() as Success).value.mime,
        'image/png',
      );
      picker.lost = LostDataResponse(files: [picker.selection!]);
      expect(
        (await service.recoverLostSelection() as Success).value,
        isNotNull,
      );
    },
  );
  test(
    'permission denial and lost-data errors are typed without reading oversized bytes',
    () async {
      final picker = Picker()
        ..error = PlatformException(
          code: 'photo_access_denied',
          message: 'private',
        );
      final service = ImagePickerGalleryService(picker: picker);
      expect(
        (await service.pickFromGallery() as Failure).failure.code,
        FailureCode.permissionDenied,
      );
      picker.error = null;
      final oversized = OversizedFile();
      picker.selection = oversized;
      expect(
        (await service.pickFromGallery() as Failure).failure.code,
        FailureCode.validation,
      );
      expect(oversized.read, false);
      picker.lost = LostDataResponse(
        exception: PlatformException(code: 'photo_access_denied'),
      );
      expect(
        (await service.recoverLostSelection() as Failure).failure.code,
        FailureCode.permissionDenied,
      );
      picker.selection = XFile.fromData(Uint8List.fromList([1, 2, 3]));
      expect(await service.pickFromGallery(), isA<Failure>());
    },
  );
}
