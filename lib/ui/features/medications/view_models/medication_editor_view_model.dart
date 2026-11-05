import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/medication_treatment.dart';
import '../../../../domain/models/animal.dart';
import '../../../../domain/repositories/animals_repository.dart';
import '../../../../domain/models/medication_schedule.dart';
import '../../../../domain/models/medication_agenda.dart';
import '../../../../domain/models/medication_application.dart';
import '../../../../domain/repositories/medications_repository.dart';
import '../../../../utils/app_failure.dart';
import '../../../../utils/result.dart';
import '../../../../utils/operation_id.dart';
import '../../../../utils/civil_date.dart';
part 'medication_editor_view_model.freezed.dart';

@freezed
abstract class MedicationEditorState with _$MedicationEditorState {
  const factory MedicationEditorState({
    String? animalId,
    @Default('') String animalName,
    @Default([]) List<MedicationTreatment> treatments,
    @Default(MedicationTreatmentDraft()) MedicationTreatmentDraft draft,
    @Default(false) bool hasDraft,
    @Default(false) bool loading,
    @Default(false) bool saving,
    @Default(false) bool loadFailed,
    @Default(false) bool uncertain,
    @Default(false) bool canRetryPending,
    @Default({}) Map<String, String> errors,
    @Default(0) int formVersion,
    @Default(true) bool intervalInHours,
    @Default('8') String intervalInput,
    String? cursor,
    String? confirmedTreatmentId,
    String? message,
  }) = _MedicationEditorState;
}

class MedicationEditorViewModel extends ChangeNotifier {
  MedicationEditorViewModel(
    this.repository, {
    AnimalsRepository? animals,
    VoidCallback? onDispose,
    bool Function()? isAuthorized,
    int Function()? accessEpoch,
    int Function()? privateGeneration,
    Future<bool> Function()? authorize,
  }) : _animals = animals,
       _onDispose = onDispose,
       _isAuthorized = isAuthorized ?? _allowed,
       _accessEpoch = accessEpoch ?? _zero,
       _privateGeneration = privateGeneration ?? _zero,
       _authorize = authorize {
    _boundGeneration = _privateGeneration();
  }
  final MedicationsRepository repository;
  final AnimalsRepository? _animals;
  final VoidCallback? _onDispose;
  final bool Function() _isAuthorized;
  final int Function() _accessEpoch;
  final int Function() _privateGeneration;
  final Future<bool> Function()? _authorize;
  static bool _allowed() => true;
  static int _zero() => 0;
  MedicationEditorState _state = const MedicationEditorState();
  MedicationEditorState get state => _state;
  final _operation = OperationId();
  Future<Result<MedicationCommandResult>> Function()? _pending;
  String? _pendingKey;
  String? _pendingTreatmentId;
  bool _pendingStop = false;
  bool _disposed = false;
  bool _recoverRead = false;
  int _readRecoveries = 0;
  int _revision = 0;
  int _boundGeneration = 0;
  bool get canEdit =>
      !_disposed &&
      _isAuthorized() &&
      state.animalId != null &&
      !state.loading &&
      !state.saving &&
      !state.uncertain &&
      !state.loadFailed;
  String get animalDisplayName =>
      state.animalName.trim().isEmpty ? 'Animal do abrigo' : state.animalName;
  String get animalInitial =>
      String.fromCharCodes(animalDisplayName.runes.take(1));
  bool get canLeave => !_disposed && !state.saving && !state.uncertain;
  bool get canReconcile =>
      !_disposed && _isAuthorized() && state.uncertain && !state.saving;
  bool canModify(MedicationTreatment treatment) =>
      canEdit && treatment.status == MedicationTreatmentStatus.active;
  bool get canLoadMore => canEdit && state.cursor != null;
  String get startDateText => state.draft.schedule.startsOn.isEmpty
      ? ''
      : displayDate(state.draft.schedule.startsOn);
  String get endDateText => state.draft.schedule.endsOn.isEmpty
      ? ''
      : displayDate(state.draft.schedule.endsOn);
  DateTime get firstPickerDate => DateTime(2000);
  DateTime get lastPickerDate => DateTime(2100, 12, 31);
  DateTime? pickerDate(bool start) => DateTime.tryParse(
    canonicalDate(
          start ? state.draft.schedule.startsOn : state.draft.schedule.endsOn,
        ) ??
        '',
  );
  ({int hour, int minute}) pickerTime(String value) {
    if (!MedicationSchedule.validTime(value)) return (hour: 8, minute: 0);
    return (
      hour: int.parse(value.substring(0, 2)),
      minute: int.parse(value.substring(3, 5)),
    );
  }

  void setPickedDate(bool start, DateTime value) {
    final text =
        '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
    if (start) {
      setStartDate(text);
    } else {
      setEndDate(text);
    }
    if (canEdit) _publish(state.copyWith(formVersion: state.formVersion + 1));
  }

  void setPickedTime(int? index, bool start, int hour, int minute) {
    final text =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    if (index != null) {
      setTime(index, text);
    } else if (start) {
      setStartTime(text);
    } else {
      setEndTime(text);
    }
    if (canEdit) _publish(state.copyWith(formVersion: state.formVersion + 1));
  }

  String scheduleLabel(MedicationTreatment t) =>
      t.schedule.mode == MedicationScheduleMode.fixedTimes
      ? t.schedule.fixedTimes.join(' e ')
      : 'A cada ${t.schedule.intervalMinutes! % 60 == 0 ? '${t.schedule.intervalMinutes! ~/ 60} h' : '${t.schedule.intervalMinutes} min'}';
  String get scheduleSummary =>
      state.draft.schedule.mode == MedicationScheduleMode.fixedTimes
      ? 'Horários informados: ${state.draft.schedule.fixedTimes.join(' e ')}. A agenda será confirmada ao salvar.'
      : 'Intervalo informado: ${state.draft.schedule.intervalMinutes ?? 0} minutos, a partir do início. A agenda será confirmada ao salvar.';
  void _publish(MedicationEditorState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  void _clear() {
    _recoverRead = false;
    _readRecoveries = 0;
    _revision++;
    _pending = null;
    _pendingKey = null;
    _pendingTreatmentId = null;
    _operation.complete();
    _state = const MedicationEditorState();
  }

  void _recoverStaleRead(int request) {
    if (!_disposed &&
        request == _revision &&
        _boundGeneration == _privateGeneration()) {
      _recoverRead = true;
    }
  }

  void _scheduleReadRecovery() {
    if (_disposed ||
        !_recoverRead ||
        !_isAuthorized() ||
        state.loading ||
        state.saving ||
        state.uncertain) {
      return;
    }
    _recoverRead = false;
    if (++_readRecoveries > 1) {
      _publish(
        state.copyWith(
          loadFailed: true,
          message: 'Não foi possível carregar as medicações. Tente novamente.',
        ),
      );
      return;
    }
    // The session has just been confirmed. A fresh read must not start another
    // authorization cycle and invalidate sibling readers again.
    Future<void>.microtask(() => _load(verifyAccess: false));
  }

  void refreshAccess() {
    if (_disposed) return;
    if (_boundGeneration != _privateGeneration()) {
      _boundGeneration = _privateGeneration();
      _clear();
    }
    _scheduleReadRecovery();
    notifyListeners();
  }

  bool _current(int request, int epoch) =>
      !_disposed &&
      request == _revision &&
      epoch == _accessEpoch() &&
      _isAuthorized();
  Future<bool> _check() async =>
      !_disposed &&
      (_authorize == null ? _isAuthorized() : await _authorize()) &&
      !_disposed &&
      _isAuthorized();
  Future<void> bindAnimal(String? id, String name) async {
    if (_disposed) return;
    if (state.animalId == id) {
      if (state.animalName != name) _publish(state.copyWith(animalName: name));
      return;
    }
    _clear();
    _boundGeneration = _privateGeneration();
    _publish(state.copyWith(animalId: id, animalName: name));
    if (id != null) await load();
  }

  List<MedicationTreatment> _sorted(Iterable<MedicationTreatment> items) {
    final result = items.toList()
      ..sort((a, b) {
        final order = a.medicationName.compareTo(b.medicationName);
        return order == 0 ? a.id.compareTo(b.id) : order;
      });
    return result;
  }

  Future<void> load({bool more = false}) {
    _readRecoveries = 0;
    return _load(more: more);
  }

  Future<void> _load({bool more = false, bool verifyAccess = true}) async {
    if (_disposed ||
        state.animalId == null ||
        state.loading ||
        state.saving ||
        state.uncertain ||
        (!_isAuthorized() && _authorize == null) ||
        (more && state.cursor == null)) {
      return;
    }
    final request = ++_revision,
        id = state.animalId!,
        cursor = more ? state.cursor : null;
    _publish(state.copyWith(loading: true, loadFailed: false, message: null));
    try {
      if (!(verifyAccess ? await _check() : _isAuthorized())) {
        // Another reader may still be checking this session. Retry the read
        // only after a later access event confirms the same private context.
        if (!_isAuthorized()) _recoverStaleRead(request);
        _publish(
          state.copyWith(
            loadFailed: true,
            message: 'Verifique seu acesso para carregar as medicações.',
          ),
        );
        return;
      }
      final epoch = _accessEpoch();
      if (state.animalName.isEmpty && _animals != null) {
        final animal = await _animals.getManagement(id);
        if (!_current(request, epoch)) {
          _recoverStaleRead(request);
          return;
        }
        if (animal case Failure<ManagedAnimal>(:final failure)) {
          _publish(state.copyWith(loadFailed: true));
          await _failure(failure);
          return;
        }
        _publish(
          state.copyWith(
            animalName: (animal as Success<ManagedAnimal>).value.animal.name,
          ),
        );
      }
      final result = await repository.listTreatments(id, cursor: cursor);
      if (!_current(request, epoch)) {
        _recoverStaleRead(request);
        return;
      }
      switch (result) {
        case Success<MedicationTreatmentPage>(:final value):
          if (more && value.cursor == cursor && cursor != null) {
            throw StateError('Repeated cursor');
          }
          final items = <String, MedicationTreatment>{
            if (more)
              for (final t in state.treatments) t.id: t,
            for (final t in value.items) t.id: t,
          };
          _recoverRead = false;
          _readRecoveries = 0;
          _publish(
            state.copyWith(
              treatments: _sorted(items.values),
              cursor: value.cursor,
              loadFailed: false,
            ),
          );
        case Failure<MedicationTreatmentPage>(:final failure):
          _publish(state.copyWith(loadFailed: !more));
          await _failure(failure);
      }
    } catch (_) {
      if (!_disposed && request == _revision) {
        _publish(
          state.copyWith(
            loadFailed: !more,
            message: 'Não foi possível carregar as medicações.',
          ),
        );
      }
    } finally {
      if (!_disposed && request == _revision) {
        _publish(state.copyWith(loading: false));
        _scheduleReadRecovery();
      }
    }
  }

  Future<void> openTreatment(String? treatmentId) async {
    if (treatmentId == null) {
      startCreate();
      return;
    }
    while (canLoadMore &&
        !state.treatments.any((item) => item.id == treatmentId)) {
      final before = state.cursor;
      await load(more: true);
      if (state.cursor == before) break;
    }
    final matching = state.treatments.where((item) => item.id == treatmentId);
    if (matching.isEmpty) {
      _publish(state.copyWith(message: 'Tratamento não encontrado.'));
      return;
    }
    beginEdit(matching.first);
  }

  void startCreate() {
    if (!canEdit) return;
    _operation.complete();
    _publish(
      state.copyWith(
        hasDraft: true,
        draft: MedicationTreatmentDraft(animalId: state.animalId!),
        formVersion: state.formVersion + 1,
        errors: {},
        message: null,
        confirmedTreatmentId: null,
      ),
    );
  }

  void beginEdit(MedicationTreatment treatment) {
    if (!canEdit ||
        treatment.animalId != state.animalId ||
        treatment.status != MedicationTreatmentStatus.active) {
      return;
    }
    _operation.complete();
    _publish(
      state.copyWith(
        hasDraft: true,
        draft: _draft(treatment),
        intervalInHours:
            treatment.schedule.intervalMinutes == null ||
            treatment.schedule.intervalMinutes! % 60 == 0,
        intervalInput: treatment.schedule.intervalMinutes == null
            ? '8'
            : (treatment.schedule.intervalMinutes! % 60 == 0
                      ? treatment.schedule.intervalMinutes! ~/ 60
                      : treatment.schedule.intervalMinutes!)
                  .toString(),
        formVersion: state.formVersion + 1,
        errors: {},
        message: null,
        confirmedTreatmentId: null,
      ),
    );
  }

  MedicationTreatmentDraft _draft(MedicationTreatment t) =>
      MedicationTreatmentDraft(
        treatmentId: t.id,
        animalId: t.animalId,
        expectedRevision: t.revision,
        expectedVersion: t.version,
        medicationName: t.medicationName,
        instructions: t.instructions,
        schedule: t.schedule,
      );
  void cancelDraft() {
    if (!canEdit) return;
    _publish(state.copyWith(hasDraft: false, errors: {}, message: null));
  }

  void _edit(MedicationTreatmentDraft draft) {
    if (canEdit && state.hasDraft) {
      _operation.complete();
      _publish(
        state.copyWith(
          draft: draft,
          errors: {},
          message: null,
          confirmedTreatmentId: null,
        ),
      );
    }
  }

  void _schedule(MedicationSchedule schedule) =>
      _edit(state.draft.copyWith(schedule: schedule));
  void setName(String value) =>
      _edit(state.draft.copyWith(medicationName: value));
  void setInstructions(String value) =>
      _edit(state.draft.copyWith(instructions: value));
  void setStartDate(String value) => _schedule(
    state.draft.schedule.copyWith(startsOn: canonicalDate(value) ?? value),
  );
  void setEndDate(String value) => _schedule(
    state.draft.schedule.copyWith(endsOn: canonicalDate(value) ?? value),
  );
  void setStartTime(String value) =>
      _schedule(state.draft.schedule.copyWith(startsTime: value));
  void setEndTime(String value) =>
      _schedule(state.draft.schedule.copyWith(endsTime: value));
  void setMode(MedicationScheduleMode mode) {
    if (!canEdit || !state.hasDraft || mode == state.draft.schedule.mode) {
      return;
    }
    _schedule(
      state.draft.schedule.copyWith(
        mode: mode,
        fixedTimes: mode == MedicationScheduleMode.fixedTimes
            ? ['08:00', '20:00']
            : [],
        intervalMinutes: mode == MedicationScheduleMode.interval ? 480 : null,
      ),
    );
    _publish(state.copyWith(intervalInHours: true, intervalInput: '8'));
  }

  void setInterval(String value, {required bool hours}) {
    final parsed = int.tryParse(value);
    if (!canEdit || !state.hasDraft) return;
    _schedule(
      state.draft.schedule.copyWith(
        intervalMinutes: parsed == null ? null : parsed * (hours ? 60 : 1),
      ),
    );
    _publish(state.copyWith(intervalInHours: hours, intervalInput: value));
  }

  void setIntervalUnit(bool hours) =>
      setInterval(state.intervalInput, hours: hours);
  void addTime() {
    if (state.draft.schedule.fixedTimes.length < 24) {
      _schedule(
        state.draft.schedule.copyWith(
          fixedTimes: [...state.draft.schedule.fixedTimes, ''],
        ),
      );
    }
  }

  void removeTime(int index) {
    final times = state.draft.schedule.fixedTimes.toList();
    if (index < 0 || index >= times.length) return;
    times.removeAt(index);
    _schedule(state.draft.schedule.copyWith(fixedTimes: times));
    if (canEdit) _publish(state.copyWith(formVersion: state.formVersion + 1));
  }

  void setTime(int index, String value) {
    final times = state.draft.schedule.fixedTimes.toList();
    if (index < 0 || index >= times.length) return;
    times[index] = value;
    _schedule(state.draft.schedule.copyWith(fixedTimes: times));
  }

  String _error(String key) => switch (key) {
    'medicationName' => 'Informe de 1 a 120 caracteres.',
    'instructions' => 'Use até 1.000 caracteres.',
    'startsOn' || 'endsOn' => 'Informe uma data válida entre 2000 e 2100.',
    'startsTime' || 'endsTime' => 'Informe um horário válido (HH:mm).',
    'period' => 'Revise a ordem e o limite de 366 dias.',
    'fixedTimes' => 'Informe de 1 a 24 horários válidos e diferentes.',
    'intervalMinutes' => 'Informe um intervalo de 1 minuto a 7 dias.',
    _ => 'Revise o tratamento e tente novamente.',
  };
  Future<void> _failure(AppFailure failure, {bool reconciling = false}) async {
    final uncertain =
        reconciling ||
        [
          FailureCode.timeout,
          FailureCode.network,
          FailureCode.unknown,
        ].contains(failure.code);
    _publish(
      state.copyWith(
        uncertain: state.saving && uncertain,
        message: switch (failure.code) {
          FailureCode.forbidden || FailureCode.unauthenticated =>
            'Verifique seu acesso. O rascunho foi preservado.',
          FailureCode.validation =>
            'Revise a programação. O servidor não confirmou os dados.',
          FailureCode.conflict =>
            'O tratamento mudou. Atualize os dados antes de tentar novamente.',
          _ =>
            'Não foi possível confirmar. Verifique o resultado antes de repetir.',
        },
      ),
    );
    if (!uncertain) {
      _pending = null;
      _pendingKey = null;
      _operation.complete();
    }
    if (failure.code == FailureCode.forbidden ||
        failure.code == FailureCode.unauthenticated) {
      await _authorize?.call();
    }
  }

  bool _confirmed(MedicationCommandResult result) {
    final t = result.treatment;
    if (t == null ||
        result.operationKey != _pendingKey ||
        t.animalId != state.animalId ||
        (_pendingTreatmentId != null && t.id != _pendingTreatmentId)) {
      throw StateError('Invalid confirmation');
    }
    final items = {for (final item in state.treatments) item.id: item, t.id: t};
    final stopped = _pendingStop;
    _pending = null;
    _pendingKey = null;
    _pendingTreatmentId = null;
    _operation.complete();
    _publish(
      state.copyWith(
        treatments: _sorted(items.values),
        draft: _draft(t),
        hasDraft: false,
        confirmedTreatmentId: t.id,
        uncertain: false,
        canRetryPending: false,
        formVersion: state.formVersion + 1,
        message: stopped
            ? 'Tratamento interrompido. Aplicações atrasadas foram preservadas.'
            : 'Programação salva com sucesso.',
      ),
    );
    return true;
  }

  Future<bool> save() async {
    if (!canEdit || !state.hasDraft) return false;
    final errors = state.draft.validate().map(
      (key, _) => MapEntry(key, _error(key)),
    );
    if (errors.isNotEmpty) {
      _publish(
        state.copyWith(errors: errors, message: 'Revise os campos indicados.'),
      );
      return false;
    }
    final draft = state.draft, key = _operation.value;
    _pendingKey = key;
    _pendingTreatmentId = draft.treatmentId;
    _pendingStop = false;
    _pending = () => repository.saveTreatment(draft, key);
    return _run();
  }

  Future<bool> stop(MedicationTreatment treatment) async {
    if (!canEdit || treatment.animalId != state.animalId) return false;
    final key = _operation.value;
    _pendingKey = key;
    _pendingTreatmentId = treatment.id;
    _pendingStop = true;
    _pending = () => repository.stopTreatment(treatment, key);
    return _run();
  }

  Future<bool> _run() async {
    if (_disposed || state.saving || _pending == null || !_isAuthorized()) {
      return false;
    }
    final request = ++_revision;
    _publish(
      state.copyWith(saving: true, canRetryPending: false, message: null),
    );
    try {
      if (!await _check()) {
        await _failure(AppFailure(FailureCode.forbidden));
        return false;
      }
      final epoch = _accessEpoch();
      _publish(state.copyWith(uncertain: true));
      final result = await _pending!();
      if (!_current(request, epoch)) return false;
      switch (result) {
        case Success<MedicationCommandResult>(:final value):
          return _confirmed(value);
        case Failure<MedicationCommandResult>(:final failure):
          await _failure(failure);
          return false;
      }
    } catch (_) {
      if (!_disposed && request == _revision) {
        await _failure(AppFailure(FailureCode.unknown));
      }
      return false;
    } finally {
      if (!_disposed && request == _revision) {
        _publish(state.copyWith(saving: false));
      }
    }
  }

  Future<bool> reconcile() async {
    if (_disposed ||
        !state.uncertain ||
        state.saving ||
        _pendingKey == null ||
        !_isAuthorized()) {
      return false;
    }
    final request = ++_revision;
    _publish(state.copyWith(saving: true));
    try {
      if (!await _check()) return false;
      final epoch = _accessEpoch();
      final result = await repository.getOperation(_pendingKey!);
      if (!_current(request, epoch)) return false;
      switch (result) {
        case Success<MedicationCommandResult?>(:final value):
          if (value != null) return _confirmed(value);
          _publish(
            state.copyWith(
              canRetryPending: true,
              message:
                  'Ainda sem confirmação. Você pode verificar novamente ou repetir a mesma operação.',
            ),
          );
          return false;
        case Failure<MedicationCommandResult?>(:final failure):
          await _failure(failure, reconciling: true);
          return false;
      }
    } catch (_) {
      if (!_disposed && request == _revision) {
        await _failure(AppFailure(FailureCode.unknown), reconciling: true);
      }
      return false;
    } finally {
      if (!_disposed && request == _revision) {
        _publish(state.copyWith(saving: false));
      }
    }
  }

  Future<bool> retryPending() async {
    if (!state.canRetryPending ||
        !state.uncertain ||
        !_isAuthorized() ||
        state.saving) {
      return false;
    }
    return _run();
  }

  @override
  void dispose() {
    _disposed = true;
    _clear();
    _onDispose?.call();
    super.dispose();
  }
}
