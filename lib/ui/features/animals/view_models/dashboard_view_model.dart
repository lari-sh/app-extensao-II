import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/animal.dart';
import '../../../../domain/repositories/animals_repository.dart';
import '../../../../utils/result.dart';
import '../../../../utils/app_failure.dart';
import '../../../../utils/operation_id.dart';
import '../../../core/view_models/public_list_view_model.dart'
    show failureMessage;
part 'dashboard_view_model.freezed.dart';

enum DashboardMode { kanban, list, calendar }

@freezed
abstract class DashboardState with _$DashboardState {
  const DashboardState._();
  bool get listMode => mode == DashboardMode.list;
  const factory DashboardState({
    @Default({}) Map<AnimalStatus, ManagedAnimalPage> pages,
    @Default({}) Map<AnimalStatus, int> counts,
    @Default(false) bool loading,
    @Default(false) bool busy,
    @Default(DashboardMode.kanban) DashboardMode mode,
    @Default(false) bool uncertain,
    @Default(false) bool canRetry,
    ManagedAnimal? focusedAnimal,
    String? message,
  }) = _DashboardState;
}

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(
    this.repository, {
    required this.isAuthorized,
    this.authorize,
    this.onCalendarSelected,
    this.canManageTeam,
    this.accessEpoch,
    Future<void> Function(Duration)? delay,
  }) : delay = delay ?? Future<void>.delayed;
  final bool Function()? canManageTeam;
  bool get showTeam => canManage && canManageTeam?.call() == true;
  final AnimalsRepository repository;
  final Future<void> Function()? onCalendarSelected;
  bool get isCalendar => state.mode == DashboardMode.calendar;
  bool get showRegistration => !isCalendar;
  final bool Function() isAuthorized;
  final Future<bool> Function()? authorize;
  final int Function()? accessEpoch;
  final Future<void> Function(Duration) delay;
  DashboardState _state = const DashboardState();
  DashboardState get state => _state;
  bool _disposed = false;
  int _revision = 0;
  String? _focusedId;
  bool get canManageFocused => canManage && state.focusedAnimal != null;
  AnimalStatus get focusedStatus =>
      state.focusedAnimal?.animal.status ?? AnimalStatus.available;
  bool get focusedPublished => state.focusedAnimal?.animal.isPublished ?? false;
  bool get canPublishFocused =>
      canManageFocused && canChangePublication(state.focusedAnimal!.animal);
  Future<void> setFocusedStatus(AnimalStatus value) async {
    if (canManageFocused) await setStatus(_focusedId!, value);
  }

  Future<void> setFocusedPublication(bool value) async {
    if (canPublishFocused) await setPublication(_focusedId!, value);
  }

  Future<void> loadFocused(String? id) async {
    _focusedId = id;
    final revision = ++_revision;
    if (id == null) {
      _publish(const DashboardState());
      return;
    }
    _publish(state.copyWith(loading: true, focusedAnimal: null, message: null));
    try {
      if (!await _authorize()) return;
      final epoch = accessEpoch?.call();
      final result = await repository.getManagement(id);
      if (!_current(revision, epoch)) return;
      if (result case Success<ManagedAnimal>(:final value)) {
        _publish(state.copyWith(focusedAnimal: value));
      } else {
        await _failure((result as Failure<ManagedAnimal>).failure);
      }
    } finally {
      if (revision == _revision) _publish(state.copyWith(loading: false));
    }
  }

  ({String id, AnimalStatus? status, bool? published, String key})? _pending;
  static const labels = {
    AnimalStatus.available: 'Disponíveis',
    AnimalStatus.treatment: 'Em tratamento',
    AnimalStatus.quarantine: 'Quarentena',
    AnimalStatus.adopted: 'Adotados',
  };
  int get total => state.counts.values.fold(0, (a, b) => a + b);
  bool get canManage =>
      !_disposed &&
      isAuthorized() &&
      !state.loading &&
      !state.busy &&
      !state.uncertain;
  bool canPublish(PublicAnimal animal) =>
      canManage && animal.status != AnimalStatus.adopted;
  String get heading => 'Olá, equipe';
  String publicationLabel(PublicAnimal animal) =>
      animal.isPublished ? 'Ocultar do catálogo' : 'Publicar no catálogo';
  bool canChangePublication(PublicAnimal animal) =>
      canManage &&
      (animal.isPublished || animal.status != AnimalStatus.adopted);
  String visibilityLabel(PublicAnimal animal) =>
      animal.isPublished ? 'Publicado' : 'Privado';
  String cardSubtitle(PublicAnimal animal) =>
      '${animal.approximateAge} · ${animal.sex == AnimalSex.female ? 'F' : 'M'}';
  String cardClinicalSummary(ManagedAnimal animal) {
    final notes = animal.clinicalNotes.trim();
    if (notes.isNotEmpty) return notes;
    return switch (animal.animal.status) {
      AnimalStatus.available => 'Sem observações clínicas',
      AnimalStatus.treatment => 'Em tratamento',
      AnimalStatus.quarantine => 'Quarentena',
      AnimalStatus.adopted => 'Adotado',
    };
  }

  String get subtitle => 'Manejo · $total animais';
  void _publish(DashboardState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  bool _current(int revision, int? epoch) =>
      !_disposed &&
      isAuthorized() &&
      revision == _revision &&
      epoch == accessEpoch?.call();
  Future<bool> _authorize() async {
    if (_disposed || !isAuthorized()) {
      _clear();
      return false;
    }
    if (authorize != null && !await authorize!()) {
      _clear();
      return false;
    }
    if (_disposed || !isAuthorized()) {
      _clear();
      return false;
    }
    return true;
  }

  void _clear() {
    _revision++;
    _pending = null;
    _publish(
      const DashboardState(
        message: 'Seu acesso não permite esta ação. Entre novamente.',
      ),
    );
  }

  Future<void> _failure(AppFailure failure) async {
    if (failure.code == FailureCode.forbidden ||
        failure.code == FailureCode.unauthenticated) {
      _clear();
      await authorize?.call();
    } else {
      _publish(state.copyWith(message: failureMessage(failure)));
    }
  }

  void setListMode(bool value) =>
      setMode(value ? DashboardMode.list : DashboardMode.kanban);
  void setMode(DashboardMode mode) {
    _publish(state.copyWith(mode: mode, message: null));
    if (mode == DashboardMode.calendar && onCalendarSelected != null) {
      unawaited(onCalendarSelected!());
    }
  }

  Future<void> load() async {
    if (_disposed || state.loading || state.busy) return;
    final revision = ++_revision;
    _publish(state.copyWith(loading: true, message: null));
    try {
      if (!await _authorize()) return;
      final epoch = accessEpoch?.call();
      final counts = await repository.getStatusCounts();
      if (!_current(revision, epoch)) return;
      if (counts case Failure<Map<AnimalStatus, int>>(:final failure)) {
        await _failure(failure);
        return;
      }
      final pages = <AnimalStatus, ManagedAnimalPage>{};
      for (final status in AnimalStatus.values) {
        final page = await repository.listManagement(status: status);
        if (!_current(revision, epoch)) return;
        if (page case Failure<ManagedAnimalPage>(:final failure)) {
          await _failure(failure);
          return;
        }
        pages[status] = (page as Success<ManagedAnimalPage>).value;
      }
      _publish(
        state.copyWith(
          pages: pages,
          counts: (counts as Success<Map<AnimalStatus, int>>).value,
        ),
      );
    } finally {
      if (!_disposed) _publish(state.copyWith(loading: false));
    }
  }

  Future<void> loadMore(AnimalStatus status) async {
    if (!canManage) return;
    final page = state.pages[status];
    if (page?.cursor == null) return;
    _publish(state.copyWith(busy: true, message: null));
    try {
      if (!await _authorize()) return;
      final revision = _revision, epoch = accessEpoch?.call();
      final result = await repository.listManagement(
        status: status,
        cursor: page!.cursor,
      );
      if (!_current(revision, epoch)) return;
      if (result case Failure<ManagedAnimalPage>(:final failure)) {
        await _failure(failure);
        return;
      }
      final next = (result as Success<ManagedAnimalPage>).value;
      _publish(
        state.copyWith(
          pages: {
            ...state.pages,
            status: next.copyWith(
              items: {
                for (final item in [...page.items, ...next.items])
                  item.animal.id: item,
              }.values.toList(),
            ),
          },
        ),
      );
    } finally {
      _publish(state.copyWith(busy: false));
    }
  }

  Future<void> setStatus(String id, AnimalStatus status) =>
      _begin(id, status: status);
  Future<void> setPublication(String id, bool published) =>
      _begin(id, published: published);
  Future<void> togglePublication(PublicAnimal animal) =>
      setPublication(animal.id, !animal.isPublished);
  Future<void> _begin(
    String id, {
    AnimalStatus? status,
    bool? published,
  }) async {
    if (!canManage) return;
    _pending = (
      id: id,
      status: status,
      published: published,
      key: OperationId().value,
    );
    await _send();
  }

  Future<void> _send() async {
    final pending = _pending;
    if (pending == null) return;
    _publish(
      state.copyWith(
        busy: true,
        uncertain: true,
        message: null,
        canRetry: false,
      ),
    );
    var confirmed = false;
    try {
      if (!await _authorize()) return;
      final revision = _revision, epoch = accessEpoch?.call();
      final result = pending.status != null
          ? await repository.setStatus(pending.id, pending.status!, pending.key)
          : await repository.setPublication(
              pending.id,
              pending.published!,
              pending.key,
            );
      if (!_current(revision, epoch)) return;
      if (result is Success<PublicAnimal>) {
        _pending = null;
        confirmed = true;
        _publish(state.copyWith(uncertain: false));
      } else {
        final failure = (result as Failure<PublicAnimal>).failure;
        if (failure.code == FailureCode.timeout ||
            failure.code == FailureCode.network) {
          _publish(
            state.copyWith(
              uncertain: true,
              message:
                  'Não foi possível confirmar. Consulte o resultado antes de tentar novamente.',
            ),
          );
        } else {
          _pending = null;
          _publish(state.copyWith(uncertain: false));
          await _failure(failure);
        }
      }
    } finally {
      _publish(state.copyWith(busy: false));
    }
    if (confirmed) {
      if (_focusedId != null) {
        await loadFocused(_focusedId);
      } else {
        await load();
      }
      if (!_disposed && isAuthorized()) {
        _publish(state.copyWith(message: 'Alteração confirmada.'));
      }
    }
  }

  Future<void> reconcile() async {
    final pending = _pending;
    if (_disposed || pending == null || state.busy) return;
    _publish(state.copyWith(busy: true, canRetry: false));
    var confirmed = false;
    try {
      if (!await _authorize()) return;
      final revision = _revision, epoch = accessEpoch?.call();
      var missing = false;
      for (final seconds in [1, 2, 4]) {
        await delay(Duration(seconds: seconds));
        if (!_current(revision, epoch)) return;
        final result = await repository.getOperation(pending.key);
        if (!_current(revision, epoch)) return;
        if (result case Success<ManagedAnimal?>(:final value)) {
          if (value != null) {
            confirmed = true;
            _pending = null;
            _publish(state.copyWith(uncertain: false));
            break;
          }
          missing = true;
        } else {
          missing = false;
          await _failure((result as Failure<ManagedAnimal?>).failure);
          if (!_current(revision, epoch)) return;
        }
      }
      if (!confirmed) _publish(state.copyWith(canRetry: missing));
    } finally {
      _publish(state.copyWith(busy: false));
    }
    if (confirmed) {
      if (_focusedId != null) {
        await loadFocused(_focusedId);
      } else {
        await load();
      }
    }
  }

  Future<void> retry() async {
    if (state.canRetry && !state.busy && state.uncertain) await _send();
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    _pending = null;
    _state = const DashboardState();
    super.dispose();
  }
}
