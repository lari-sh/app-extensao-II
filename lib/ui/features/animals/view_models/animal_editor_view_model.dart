import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/animal.dart';
import '../../../../domain/models/animal_draft.dart';
import '../../../../domain/models/clinical_record.dart';
import '../../../../domain/repositories/animals_repository.dart';
import '../../../../utils/app_failure.dart';
import '../../../../utils/result.dart';
import '../../../../utils/operation_id.dart';
part 'animal_editor_view_model.freezed.dart';

@freezed
abstract class AnimalEditorState with _$AnimalEditorState {
  const factory AnimalEditorState({
    @Default(AnimalDraft()) AnimalDraft draft,
    @Default(false) bool loading,
    @Default(false) bool saving,
    @Default(false) bool uncertain,
    @Default(false) bool canRetryPending,
    @Default(false) bool loadFailed,
    @Default({}) Map<String, String> errors,
    @Default(0) int formVersion,
    String? savedId,
    String? message,
  }) = _AnimalEditorState;
}

class AnimalEditorViewModel extends ChangeNotifier {
  AnimalEditorViewModel(
    this.repository, {
    bool Function()? isAuthorized,
    int Function()? accessEpoch,
    Future<bool> Function()? authorize,
  }) : _isAuthorized = isAuthorized ?? _allowed,
       _accessEpoch = accessEpoch ?? _zero,
       _authorize = authorize;
  final AnimalsRepository repository;
  final bool Function() _isAuthorized;
  final int Function() _accessEpoch;
  final Future<bool> Function()? _authorize;
  final _operation = OperationId();
  AnimalEditorState _state = const AnimalEditorState();
  AnimalEditorState get state => _state;
  String get publicationMessage => state.draft.id == null
      ? 'O novo animal será cadastrado como disponível e ficará privado até a publicação pela equipe.'
      : 'Esta edição preserva a situação e a publicação atuais do animal.';
  bool _disposed = false;
  int _revision = 0;
  String? _targetId;
  static bool _allowed() => true;
  static int _zero() => 0;
  bool get canEdit =>
      !_disposed &&
      _isAuthorized() &&
      !state.loading &&
      !state.saving &&
      !state.uncertain &&
      !state.loadFailed;
  void _publish(AnimalEditorState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  void _edit(AnimalDraft draft) {
    if (canEdit) {
      _operation.complete();
      _publish(
        state.copyWith(draft: draft, errors: {}, message: null, savedId: null),
      );
    }
  }

  void setName(String value) => _edit(state.draft.copyWith(name: value));
  void setAge(String value) =>
      _edit(state.draft.copyWith(approximateAge: value));
  void setSpecies(AnimalSpecies? value) =>
      _edit(state.draft.copyWith(species: value));
  void setSex(AnimalSex? value) => _edit(state.draft.copyWith(sex: value));
  void setSize(AnimalSize? value) => _edit(state.draft.copyWith(size: value));
  void setDescription(String value) =>
      _edit(state.draft.copyWith(publicDescription: value));
  void setNotes(String value) =>
      _edit(state.draft.copyWith(clinicalNotes: value));
  void setVaccinated(bool value) =>
      _edit(state.draft.copyWith(isVaccinated: value));
  void setNeutered(bool value) =>
      _edit(state.draft.copyWith(isNeutered: value));
  void addCare(ClinicalRecordKind kind) => _edit(
    state.draft.copyWith(
      careRecords: [
        ...state.draft.careRecords,
        ClinicalRecord(id: OperationId().value, kind: kind, description: ''),
      ],
    ),
  );
  void removeCare(int index) {
    if (index >= 0 && index < state.draft.careRecords.length) {
      final records = state.draft.careRecords.toList()..removeAt(index);
      _edit(state.draft.copyWith(careRecords: records));
    }
  }

  void setCareDescription(int index, String description) {
    if (index >= 0 && index < state.draft.careRecords.length) {
      final records = state.draft.careRecords.toList();
      records[index] = records[index].copyWith(description: description);
      _edit(state.draft.copyWith(careRecords: records));
    }
  }

  void setCareKind(int index, ClinicalRecordKind? kind) {
    if (kind != null && index >= 0 && index < state.draft.careRecords.length) {
      final records = state.draft.careRecords.toList();
      records[index] = records[index].copyWith(kind: kind);
      _edit(state.draft.copyWith(careRecords: records));
    }
  }

  Future<bool> _check() async =>
      !_disposed &&
      (_authorize == null ? _isAuthorized() : await _authorize()) &&
      !_disposed &&
      _isAuthorized();
  bool _current(int revision, int epoch) =>
      !_disposed &&
      revision == _revision &&
      epoch == _accessEpoch() &&
      _isAuthorized();
  AnimalDraft _draft(ManagedAnimal value) => AnimalDraft(
    id: value.animal.id,
    name: value.animal.name,
    species: value.animal.species,
    sex: value.animal.sex,
    size: value.animal.size,
    approximateAge: value.animal.approximateAge,
    publicDescription: value.animal.publicDescription,
    clinicalNotes: value.clinicalNotes,
    isVaccinated: value.animal.isVaccinated,
    isNeutered: value.animal.isNeutered,
    careRecords: value.careRecords,
  );
  Future<void> load(String id) async {
    if (_disposed || state.loading || state.saving) return;
    final revision = ++_revision;
    _targetId = id;
    _publish(
      state.copyWith(
        draft: state.draft.copyWith(id: id),
        loading: true,
        loadFailed: false,
        message: null,
      ),
    );
    try {
      if (!await _check()) {
        _publish(
          state.copyWith(
            loadFailed: true,
            message: 'Verifique seu acesso e tente carregar novamente.',
          ),
        );
        return;
      }
      final epoch = _accessEpoch();
      final result = await repository.getManagement(id);
      if (!_current(revision, epoch)) {
        _publish(
          state.copyWith(
            loadFailed: true,
            message: 'Tente carregar o animal novamente.',
          ),
        );
        return;
      }
      switch (result) {
        case Success<ManagedAnimal>(:final value):
          _publish(
            state.copyWith(
              draft: _draft(value),
              formVersion: state.formVersion + 1,
            ),
          );
        case Failure<ManagedAnimal>(:final failure):
          _publish(state.copyWith(loadFailed: true));
          await _failure(failure);
      }
    } catch (_) {
      if (!_disposed) {
        _publish(
          state.copyWith(
            loadFailed: true,
            message: 'Não foi possível carregar o animal.',
          ),
        );
      }
    } finally {
      if (!_disposed && revision == _revision) {
        _publish(state.copyWith(loading: false));
      }
    }
  }

  Future<void> retryLoad() async {
    if (_targetId != null) await load(_targetId!);
  }

  Future<void> _failure(
    AppFailure failure, {
    bool preserveUncertainty = false,
  }) async {
    final uncertain = [
      FailureCode.timeout,
      FailureCode.network,
      FailureCode.unknown,
      FailureCode.conflict,
    ].contains(failure.code);
    _publish(
      state.copyWith(
        uncertain: preserveUncertainty
            ? state.uncertain
            : state.saving && uncertain,
        message: switch (failure.code) {
          FailureCode.forbidden || FailureCode.unauthenticated =>
            'Seu acesso precisa ser verificado. Entre novamente.',
          FailureCode.validation => 'Revise os dados informados.',
          FailureCode.notFound => 'Animal não encontrado.',
          _ =>
            'Não foi possível confirmar a operação. Verifique o resultado antes de tentar novamente.',
        },
      ),
    );
    if (failure.code == FailureCode.forbidden ||
        failure.code == FailureCode.unauthenticated) {
      await _authorize?.call();
    }
  }

  void _confirmed(ManagedAnimal value) {
    _operation.complete();
    _publish(
      state.copyWith(
        draft: _draft(value),
        formVersion: state.formVersion + 1,
        savedId: value.animal.id,
        uncertain: false,
        canRetryPending: false,
        message: 'Animal salvo com sucesso.',
      ),
    );
  }

  Future<void> save() async {
    if (_disposed ||
        state.saving ||
        state.loading ||
        state.loadFailed ||
        !_isAuthorized()) {
      return;
    }
    if (state.uncertain) {
      await reconcile();
      return;
    }
    final errors = state.draft.validate().map(
      (key, _) => MapEntry(key, switch (key) {
        'name' || 'approximateAge' => 'Informe de 1 a 80 caracteres.',
        'species' || 'sex' || 'size' => 'Selecione uma opção.',
        'publicDescription' || 'clinicalNotes' => 'Use até 3.000 caracteres.',
        _ => 'Descreva o cuidado com 1 a 1.000 caracteres.',
      }),
    );
    if (errors.isNotEmpty) {
      _publish(
        state.copyWith(errors: errors, message: 'Revise os campos indicados.'),
      );
      return;
    }
    final revision = ++_revision;
    final draft = state.draft;
    _publish(
      state.copyWith(saving: true, errors: {}, savedId: null, message: null),
    );
    try {
      if (!await _check()) return;
      final epoch = _accessEpoch();
      _publish(state.copyWith(uncertain: true, canRetryPending: false));
      final result = await repository.saveAnimal(draft, _operation.value);
      if (!_current(revision, epoch)) return;
      switch (result) {
        case Success<ManagedAnimal>(:final value):
          _confirmed(value);
        case Failure<ManagedAnimal>(:final failure):
          await _failure(failure);
      }
    } catch (_) {
      if (!_disposed) {
        _publish(
          state.copyWith(
            uncertain: true,
            message:
                'Não foi possível confirmar a operação. Verifique o resultado.',
          ),
        );
      }
    } finally {
      if (!_disposed && revision == _revision) {
        _publish(state.copyWith(saving: false));
      }
    }
  }

  Future<void> reconcile() async {
    if (_disposed || state.saving || !state.uncertain || !_isAuthorized()) {
      return;
    }
    final revision = ++_revision;
    _publish(state.copyWith(saving: true));
    try {
      if (!await _check()) return;
      final epoch = _accessEpoch();
      final result = await repository.getOperation(_operation.value);
      if (!_current(revision, epoch)) return;
      switch (result) {
        case Success<ManagedAnimal?>(:final value):
          if (value != null) {
            _confirmed(value);
          } else {
            _publish(
              state.copyWith(
                canRetryPending: true,
                message:
                    'Ainda não foi possível confirmar. Verifique novamente ou tente salvar mais uma vez.',
              ),
            );
          }
        case Failure<ManagedAnimal?>(:final failure):
          await _failure(failure, preserveUncertainty: true);
      }
    } catch (_) {
      if (!_disposed) {
        _publish(
          state.copyWith(
            message: 'Não foi possível verificar. Tente novamente.',
          ),
        );
      }
    } finally {
      if (!_disposed && revision == _revision) {
        _publish(state.copyWith(saving: false));
      }
    }
  }

  Future<void> retryPending() async {
    if (_disposed ||
        !state.canRetryPending ||
        state.saving ||
        !_isAuthorized()) {
      return;
    }
    _publish(state.copyWith(uncertain: false, canRetryPending: false));
    await save();
  }

  @override
  void dispose() {
    _disposed = true;
    _targetId = null;
    ++_revision;
    _state = const AnimalEditorState();
    _operation.complete();
    super.dispose();
  }
}
