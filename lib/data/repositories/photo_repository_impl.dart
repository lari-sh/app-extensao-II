import 'dart:async';
import 'dart:collection';
import '../../utils/app_failure.dart';
import 'repository_result.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_candidate.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_content.dart';
import 'package:abrigo_dos_anjos/domain/models/photo_upload_state.dart';
import '../../domain/repositories/photo_repository.dart';
import '../services/photo_api_service.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  PhotoRepositoryImpl(this.service);
  final PhotoApiService service;
  int _active = 0;
  final _waiting = Queue<Completer<void>>();
  @override
  Future<Result<PhotoCandidate?>> pickFromGallery() async =>
      Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<PhotoCandidate?>> recoverLostSelection() async =>
      Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<PhotoContent>> readPrimary(
    String animalId,
    String photoId,
  ) async {
    if (_active >= 4) {
      final wait = Completer<void>();
      _waiting.add(wait);
      await wait.future;
    } else {
      _active++;
    }
    try {
      return await mapRepositoryResult(
        () => service.readPrimary(animalId, photoId),
        (dto) {
          if (!['image/png', 'image/jpeg'].contains(dto.mime) ||
              dto.bytes.length < 3 ||
              dto.bytes.length > 5242880) {
            throw const FormatException('Invalid photo');
          }
          return PhotoContent(
            bytes: List<int>.unmodifiable(dto.bytes),
            mime: dto.mime,
          );
        },
      );
    } finally {
      if (_waiting.isNotEmpty) {
        _waiting.removeFirst().complete();
      } else {
        _active--;
      }
    }
  }

  @override
  Future<Result<PhotoUploadState>> uploadPrimary(
    String animalId,
    PhotoCandidate candidate,
    String operationKey,
  ) async => Failure(AppFailure(FailureCode.configuration));
  @override
  Future<Result<PhotoUploadState>> getUpload(String operationKey) async =>
      Failure(AppFailure(FailureCode.configuration));
}
