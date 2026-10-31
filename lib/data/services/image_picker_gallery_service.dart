import 'dart:async';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/app_failure.dart';
import '../../utils/result.dart';
import '../models/photo_dto.dart';
import 'gallery_service.dart';

class ImagePickerGalleryService implements GalleryService {
  ImagePickerGalleryService({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;
  Future<Result<GallerySelectionDto?>> _select(
    Future<XFile?> Function() action,
  ) async {
    try {
      final file = await action();
      if (file == null) return const Success(null);
      final size = await file.length().timeout(const Duration(seconds: 20));
      if (size < 1 || size > 5242880) {
        return Failure(AppFailure(FailureCode.validation));
      }
      final bytes = await file.readAsBytes().timeout(
        const Duration(seconds: 20),
      );
      if (bytes.length != size) {
        return Failure(AppFailure(FailureCode.validation));
      }
      final png =
          bytes.length >= 8 &&
          [
            137,
            80,
            78,
            71,
            13,
            10,
            26,
            10,
          ].asMap().entries.every((entry) => bytes[entry.key] == entry.value);
      final jpeg =
          bytes.length >= 3 &&
          bytes[0] == 255 &&
          bytes[1] == 216 &&
          bytes[2] == 255;
      if (!png && !jpeg) return Failure(AppFailure(FailureCode.validation));
      return Success(
        GallerySelectionDto(
          bytes: bytes,
          mime: png ? 'image/png' : 'image/jpeg',
        ),
      );
    } on PlatformException {
      return Failure(AppFailure(FailureCode.permissionDenied));
    } on TimeoutException {
      return Failure(AppFailure(FailureCode.timeout));
    } catch (_) {
      return Failure(AppFailure(FailureCode.unknown));
    }
  }

  @override
  Future<Result<GallerySelectionDto?>> pickFromGallery() => _select(
    () => _picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    ),
  );
  @override
  Future<Result<GallerySelectionDto?>> recoverLostSelection() =>
      _select(() async {
        final result = await _picker.retrieveLostData();
        if (result.exception != null) throw result.exception!;
        if (result.isEmpty) return null;
        return result.files?.firstOrNull ?? result.file;
      });
}
