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
import '../services/gallery_service.dart';
import '../models/photo_dto.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  PhotoRepositoryImpl(this.service, {this.gallery});
  final GalleryService? gallery;
  final PhotoApiService service;
  int _active = 0;
  final _waiting = Queue<Completer<void>>();
  PhotoCandidate? _candidate(GallerySelectionDto? dto) {
    if (dto == null) return null;
    if (dto.bytes.isEmpty ||
        dto.bytes.length > 5242880 ||
        !['image/png', 'image/jpeg'].contains(dto.mime)) {
      throw const FormatException('Invalid selection');
    }
    return PhotoCandidate(bytes: List.unmodifiable(dto.bytes), mime: dto.mime);
  }

  @override
  Future<Result<PhotoCandidate?>> pickFromGallery() async {
    final source = gallery;
    if (source == null) return Failure(AppFailure(FailureCode.configuration));
    return mapRepositoryResult(source.pickFromGallery, _candidate);
  }

  @override
  Future<Result<PhotoCandidate?>> recoverLostSelection() async {
    final source = gallery;
    if (source == null) return Failure(AppFailure(FailureCode.configuration));
    return mapRepositoryResult(source.recoverLostSelection, _candidate);
  }

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
  ) async {
    if (!isAnimalId(animalId) ||
        candidate.bytes.isEmpty ||
        candidate.bytes.length > 5242880 ||
        !['image/png', 'image/jpeg'].contains(candidate.mime) ||
        !RegExp(r'^[A-Za-z0-9_-]{32}$').hasMatch(operationKey)) {
      return Failure(AppFailure(FailureCode.validation));
    }
    return mapRepositoryResult(
      () => service.uploadPrimary(
        animalId,
        candidate.bytes,
        candidate.mime,
        operationKey,
      ),
      _job,
    );
  }

  @override
  Future<Result<PhotoUploadState>> getUpload(String operationKey) =>
      mapRepositoryResult(() => service.getUpload(operationKey), _job);
  PhotoUploadState _job(PhotoJobDto dto) => PhotoUploadState(
    jobId: dto.id,
    status: switch (dto.state) {
      'cleanup_needed' => PhotoJobStatus.cleanupNeeded,
      _ => PhotoJobStatus.values.byName(dto.state),
    },
    photoId: dto.photoId,
  );
}
