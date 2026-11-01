import '../../../../domain/models/medication_treatment.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/medication_agenda.dart';
import '../../../../domain/models/medication_application.dart';
import '../../../../domain/models/medication_schedule.dart';
import '../../../../domain/repositories/medications_repository.dart';
import '../../../../utils/app_failure.dart';
import '../../../../utils/operation_id.dart';
import '../../../../utils/result.dart';
import '../../../core/view_models/public_list_view_model.dart'
    show failureMessage;
part 'medication_application_view_model.freezed.dart';

@freezed
abstract class MedicationApplicationStateData
    with _$MedicationApplicationStateData {
  const factory MedicationApplicationStateData({
    MedicationApplication? application,
    @Default([]) List<MedicationApplicationEvent> events,
    String? cursor,
    DateTime? serverNow,
    @Default('Vinculada à ficha do animal') String scheduleLabel,
    @Default(false) bool loading,
    @Default(false) bool busy,
    @Default(false) bool uncertain,
    @Default(false) bool canRetry,
    @Default(false) bool loadFailed,
    String? message,
  }) = _MedicationApplicationStateData;
}

class MedicationApplicationViewModel extends ChangeNotifier {
  MedicationApplicationViewModel(
    this.repository, {
    bool Function()? isAuthorized,
    int Function()? accessEpoch,
    int Function()? privateGeneration,
    Future<bool> Function()? authorize,
    VoidCallback? onDispose,
  }) : _isAuthorized = isAuthorized ?? _allowed,
       _accessEpoch = accessEpoch ?? _zero,
       _privateGeneration = privateGeneration ?? _zero,
       _authorize = authorize,
       _onDispose = onDispose {
    _generation = _privateGeneration();
  }
  final MedicationsRepository repository;
  final bool Function() _isAuthorized;
  final int Function() _accessEpoch, _privateGeneration;
  final Future<bool> Function()? _authorize;
  final VoidCallback? _onDispose;
  static bool _allowed() => true;
  static int _zero() => 0;
  MedicationApplicationStateData _state =
      const MedicationApplicationStateData();
  MedicationApplicationStateData get state => _state;
  bool _disposed = false;
  int _request = 0, _generation = 0;
  String? _id, _pendingKey;
  MedicationApplication? _pending;
  final _operation = OperationId();
  bool get canLeave => !state.busy && !state.uncertain;
  bool get canComplete =>
      !_disposed &&
      _isAuthorized() &&
      !state.loading &&
      !state.loadFailed &&
      !state.busy &&
      !state.uncertain &&
      state.application != null &&
      state.serverNow != null &&
      state.application!.isDue(state.serverNow!);
  bool get canReconcile =>
      !_disposed && _isAuthorized() && state.uncertain && !state.busy;
  bool get canLoadMore =>
      !_disposed &&
      _isAuthorized() &&
      !state.loading &&
      !state.busy &&
      !state.uncertain &&
      state.cursor != null;
  String get animalName => state.application?.animalName ?? 'Aplicação';
  String get initial => animalName.isEmpty
      ? '?'
      : String.fromCharCode(animalName.runes.first).toUpperCase();
  String get medicationName => state.application?.medicationName ?? '';
  String get instructions => state.application?.instructions.isNotEmpty == true
      ? state.application!.instructions
      : 'Conforme as instruções da ficha do animal.';
  String get scheduledDate => _date(state.application?.scheduledLocalDate);
  String get scheduledTime => state.application?.scheduledLocalTime ?? '—';
  String get actorLabel => state.application?.actorLabel ?? '—';
  String get actualTime => state.application?.performedAt == null
      ? '—'
      : '${_date(state.application!.performedLocalDate)} às ${state.application!.performedLocalTime}';
  String get stateLabel => switch (state.application?.state) {
    MedicationApplicationState.completed => 'Realizada',
    MedicationApplicationState.cancelled => 'Cancelada',
    _ =>
      state.application != null &&
              state.serverNow != null &&
              state.application!.isOverdue(state.serverNow!)
          ? 'Atrasada'
          : 'Pendente',
  };
  bool get isCompleted =>
      state.application?.state == MedicationApplicationState.completed;
  String eventTitle(MedicationApplicationEvent event) => switch (event.type) {
    MedicationEventType.completed => 'Aplicação realizada',
    MedicationEventType.completionReversed => 'Registro corrigido',
    MedicationEventType.cancelled => 'Aplicação cancelada',
  };
  String eventDescription(MedicationApplicationEvent event) =>
      '${event.actorLabel} · ${_date(event.occurredLocalDate)} às ${event.occurredLocalTime}${event.reason == null ? '' : '\n${event.reason}'}';
  String _date(String? value) => value == null
      ? '—'
      : '${value.substring(8)}/${value.substring(5, 7)}/${value.substring(0, 4)}';
  void _publish(MedicationApplicationStateData value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  void _clear() {
    _request++;
    _id = null;
    _pending = null;
    _pendingKey = null;
    _operation.complete();
    _state = const MedicationApplicationStateData();
  }

  void refreshAccess() {
    if (_disposed) return;
    if (_generation != _privateGeneration()) {
      _generation = _privateGeneration();
      _clear();
    }
    notifyListeners();
  }

  bool _current(int request, int epoch) =>
      !_disposed &&
      request == _request &&
      epoch == _accessEpoch() &&
      _generation == _privateGeneration() &&
      _isAuthorized();
  Future<bool> _check() async =>
      !_disposed &&
      (_authorize == null ? _isAuthorized() : await _authorize()) &&
      !_disposed &&
      _isAuthorized();
  Future<void> _readFailure(AppFailure failure) async {
    if (failure.code == FailureCode.forbidden ||
        failure.code == FailureCode.unauthenticated) {
      _publish(
        state.copyWith(
          application: null,
          events: [],
          cursor: null,
          loadFailed: true,
          message: 'Entre novamente para acessar a aplicação.',
        ),
      );
      await _authorize?.call();
    } else {
      _publish(
        state.copyWith(loadFailed: true, message: failureMessage(failure)),
      );
    }
  }

  Future<void> open(String id) async {
    if (_disposed || !isMedicationIdentifier(id) || !canLeave) return;
    _clear();
    _id = id;
    await load();
  }

  Future<void> load({bool more = false}) async {
    if (_disposed ||
        _id == null ||
        state.loading ||
        !canLeave ||
        (more && state.cursor == null)) {
      return;
    }
    final request = ++_request, id = _id!, cursor = more ? state.cursor : null;
    _publish(
      state.copyWith(
        loading: true,
        loadFailed: false,
        message: null,
        events: more ? state.events : [],
        cursor: more ? state.cursor : null,
      ),
    );
    try {
      if (!await _check()) return;
      final epoch = _accessEpoch();
      final result = await repository.loadApplicationHistory(
        id,
        cursor: cursor,
      );
      if (!_current(request, epoch)) return;
      if (result case Failure<MedicationHistoryPage>(:final failure)) {
        await _readFailure(failure);
        return;
      }
      final page = (result as Success<MedicationHistoryPage>).value;
      if (more && page.application.version != state.application?.version) {
        _publish(state.copyWith(loading: false));
        await load();
        return;
      }
      if (more &&
          (page.cursor == cursor ||
              page.items.any(
                (e) => state.events.any((old) => old.id == e.id),
              ))) {
        await _readFailure(AppFailure(FailureCode.unknown));
        return;
      }
      var serverNow = state.serverNow;
      var schedule = state.scheduleLabel;
      if (!more) {
        // Day read supplies the authoritative server clock; no device-clock eligibility.
        final day = await repository.loadDay(
          page.application.scheduledLocalDate,
        );
        if (!_current(request, epoch)) return;
        if (day case Failure<MedicationDayPage>(:final failure)) {
          await _readFailure(failure);
          return;
        }
        serverNow = (day as Success<MedicationDayPage>).value.serverNow;
        String? next;
        final visited = <String>{};
        var found = false;
        do {
          final treatments = await repository.listTreatments(
            page.application.animalId,
            cursor: next,
          );
          if (!_current(request, epoch)) return;
          if (treatments case Failure<MedicationTreatmentPage>(
            :final failure,
          )) {
            await _readFailure(failure);
            return;
          }
          final treatmentPage =
              (treatments as Success<MedicationTreatmentPage>).value;
          for (final treatment in treatmentPage.items) {
            if (treatment.id == page.application.treatmentId) {
              schedule = treatment.revision != page.application.revision
                  ? 'Revisão ${page.application.revision} da ficha'
                  : treatment.schedule.mode == MedicationScheduleMode.fixedTimes
                  ? 'Diariamente às ${treatment.schedule.fixedTimes.join(' / ')}'
                  : treatment.schedule.intervalMinutes! % 60 == 0
                  ? 'A cada ${treatment.schedule.intervalMinutes! ~/ 60} horas'
                  : 'A cada ${treatment.schedule.intervalMinutes} minutos';
              found = true;
              break;
            }
          }
          next = treatmentPage.cursor;
          if (next != null && !visited.add(next)) {
            await _readFailure(AppFailure(FailureCode.unknown));
            return;
          }
        } while (!found && next != null);
      }
      final events = [if (more) ...state.events, ...page.items]
        ..sort((a, b) {
          final order = a.applicationVersion.compareTo(b.applicationVersion);
          return order == 0 ? a.id.compareTo(b.id) : order;
        });
      _publish(
        state.copyWith(
          application: page.application,
          events: events,
          cursor: page.cursor,
          serverNow: serverNow,
          scheduleLabel: schedule,
        ),
      );
    } catch (_) {
      if (!_disposed && request == _request) {
        await _readFailure(AppFailure(FailureCode.unknown));
      }
    } finally {
      if (!_disposed && request == _request) {
        _publish(state.copyWith(loading: false));
      }
    }
  }

  Future<bool> complete() async {
    if (!canComplete) return false;
    _pending = state.application;
    _pendingKey = _operation.value;
    return _run();
  }

  bool _confirm(MedicationCommandResult result) {
    final app = result.application, event = result.event;
    if (app == null ||
        event == null ||
        _pending == null ||
        result.operationKey != _pendingKey ||
        app.id != _pending!.id ||
        app.state != MedicationApplicationState.completed ||
        app.version != _pending!.version + 1 ||
        event.applicationId != app.id ||
        event.actorId != app.performedBy ||
        event.occurredAt != app.performedAt) {
      throw StateError('Invalid confirmation');
    }
    final events =
        {for (final e in state.events) e.id: e, event.id: event}.values.toList()
          ..sort(
            (a, b) => a.applicationVersion.compareTo(b.applicationVersion),
          );
    _pending = null;
    _pendingKey = null;
    _operation.complete();
    _publish(
      state.copyWith(
        application: app,
        events: events,
        serverNow: result.serverNow,
        uncertain: false,
        canRetry: false,
        message: 'Aplicação registrada com sucesso.',
      ),
    );
    return true;
  }

  Future<void> _commandFailure(
    AppFailure failure, {
    bool reconciling = false,
  }) async {
    final uncertain =
        reconciling ||
        [
          FailureCode.network,
          FailureCode.timeout,
          FailureCode.unknown,
        ].contains(failure.code);
    _publish(
      state.copyWith(
        uncertain: uncertain,
        canRetry: false,
        message: uncertain
            ? 'Não foi possível confirmar. Verifique o resultado antes de repetir.'
            : failure.code == FailureCode.conflict
            ? 'A aplicação mudou. Confira o registro atualizado.'
            : failureMessage(failure),
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

  Future<bool> _run() async {
    if (_disposed || state.busy || _pending == null) return false;
    final request = ++_request;
    _publish(state.copyWith(busy: true, canRetry: false, message: null));
    var conflict = false;
    try {
      if (!await _check()) return false;
      final epoch = _accessEpoch();
      _publish(state.copyWith(uncertain: true));
      final result = await repository.completeApplication(
        _pending!,
        _pendingKey!,
      );
      if (!_current(request, epoch)) return false;
      if (result case Success<MedicationCommandResult>(:final value)) {
        return _confirm(value);
      }
      final failure = (result as Failure<MedicationCommandResult>).failure;
      conflict = failure.code == FailureCode.conflict;
      await _commandFailure(failure);
      return false;
    } catch (_) {
      if (!_disposed && request == _request) {
        await _commandFailure(AppFailure(FailureCode.unknown));
      }
      return false;
    } finally {
      if (!_disposed && request == _request) {
        _publish(state.copyWith(busy: false));
        if (conflict) {
          await load();
          _publish(
            state.copyWith(
              message: 'A aplicação mudou. Confira o registro atualizado.',
            ),
          );
        }
      }
    }
  }

  Future<bool> reconcile() async {
    if (!canReconcile || _pendingKey == null) return false;
    final request = ++_request;
    _publish(state.copyWith(busy: true, canRetry: false));
    try {
      if (!await _check()) return false;
      final epoch = _accessEpoch();
      final result = await repository.getOperation(_pendingKey!);
      if (!_current(request, epoch)) return false;
      if (result case Success<MedicationCommandResult?>(:final value)) {
        if (value != null) return _confirm(value);
        _publish(
          state.copyWith(
            canRetry: true,
            message:
                'Sem confirmação. Verifique novamente ou repita a mesma operação.',
          ),
        );
        return false;
      }
      await _commandFailure(
        (result as Failure<MedicationCommandResult?>).failure,
        reconciling: true,
      );
      return false;
    } catch (_) {
      if (!_disposed && request == _request) {
        await _commandFailure(
          AppFailure(FailureCode.unknown),
          reconciling: true,
        );
      }
      return false;
    } finally {
      if (!_disposed && request == _request) {
        _publish(state.copyWith(busy: false));
      }
    }
  }

  Future<bool> retryPending() async {
    if (!canReconcile || !state.canRetry) return false;
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
