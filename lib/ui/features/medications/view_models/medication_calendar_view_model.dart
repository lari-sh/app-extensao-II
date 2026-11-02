import '../../../../domain/models/managed_animal_search_filter.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../domain/models/medication_agenda.dart';
import '../../../../domain/models/medication_application.dart';
import '../../../../domain/models/medication_schedule.dart';
import '../../../../domain/repositories/medications_repository.dart';
import '../../../../utils/app_failure.dart';
import '../../../../utils/result.dart';
import '../../../core/view_models/public_list_view_model.dart'
    show failureMessage;
part 'medication_calendar_view_model.freezed.dart';

@freezed
abstract class MedicationCalendarState with _$MedicationCalendarState {
  const factory MedicationCalendarState({
    @Default('') String month,
    @Default('') String selectedDay,
    MedicationMonth? monthData,
    DateTime? serverNow,
    int? agendaVersion,
    @Default([]) List<MedicationApplication> items,
    String? cursor,
    @Default(false) bool loadingMonth,
    @Default(false) bool loadingDay,
    String? monthError,
    String? dayError,
  }) = _MedicationCalendarState;
}

class MedicationCalendarViewModel extends ChangeNotifier {
  MedicationCalendarViewModel(
    this.repository, {
    bool Function()? isAuthorized,
    int Function()? accessEpoch,
    int Function()? privateGeneration,
    Future<bool> Function()? authorize,
    VoidCallback? onDispose,
    DateTime Function()? now,
  }) : _isAuthorized = isAuthorized ?? _allowed,
       _accessEpoch = accessEpoch ?? _zero,
       _privateGeneration = privateGeneration ?? _zero,
       _authorize = authorize,
       _onDispose = onDispose,
       _now = now ?? DateTime.now {
    _generation = _privateGeneration();
  }
  final MedicationsRepository repository;
  final bool Function() _isAuthorized;
  final int Function() _accessEpoch, _privateGeneration;
  final Future<bool> Function()? _authorize;
  final VoidCallback? _onDispose;
  final DateTime Function() _now;
  static bool _allowed() => true;
  static int _zero() => 0;
  ManagedAnimalSearchFilter? _filter;
  Future<void> setAnimalFilter(ManagedAnimalSearchFilter? value) async {
    final normalized = value?.normalized;
    final next = normalized?.hasCriteria == true ? normalized : null;
    if (_filter == next || _disposed) return;
    _filter = next;
    _dayRequest++;
    if (state.selectedDay.isNotEmpty) await selectDay(state.selectedDay);
  }

  bool get isAnimalFiltered => _filter != null;
  bool _disposed = false;
  int _generation = 0, _monthRequest = 0, _dayRequest = 0;
  MedicationCalendarState _state = const MedicationCalendarState();
  MedicationCalendarState get state => _state;
  static const monthNames = [
    'Janeiro',
    'Fevereiro',
    'Março',
    'Abril',
    'Maio',
    'Junho',
    'Julho',
    'Agosto',
    'Setembro',
    'Outubro',
    'Novembro',
    'Dezembro',
  ];
  static const weekdays = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];
  static const shortMonths = [
    'jan.',
    'fev.',
    'mar.',
    'abr.',
    'mai.',
    'jun.',
    'jul.',
    'ago.',
    'set.',
    'out.',
    'nov.',
    'dez.',
  ];
  bool get canNavigate => !_disposed && _isAuthorized();
  bool get canLoadMore =>
      canNavigate && !state.loadingDay && state.cursor != null;
  String get monthLabel {
    final date = DateTime.tryParse('${state.month}-01');
    return date == null
        ? 'Calendário'
        : '${monthNames[date.month - 1]} ${date.year}';
  }

  String get dayLabel {
    final date = DateTime.tryParse(state.selectedDay);
    return date == null
        ? 'Agenda do dia'
        : '${weekdays[date.weekday - 1]}, ${date.day} ${shortMonths[date.month - 1]}';
  }

  List<String?> get cells {
    final first = DateTime.tryParse('${state.month}-01');
    if (first == null) return const [];
    final count = DateTime.utc(first.year, first.month + 1, 0).day;
    return List.unmodifiable([
      for (var i = 0; i < first.weekday % 7; i++) null,
      for (var i = 1; i <= count; i++)
        '${state.month}-${i.toString().padLeft(2, '0')}',
    ]);
  }

  bool hasApplications(String day) =>
      state.monthData?.days.any(
        (d) => d.day == day && (d.pending + d.completed) > 0,
      ) ??
      false;
  String get summary {
    final day = state.monthData?.days
        .where((d) => d.day == state.selectedDay)
        .firstOrNull;
    final count = day == null
        ? state.items.length
        : day.pending + day.completed + day.cancelled;
    return '$count aplicações · ${day?.pending ?? 0} pendentes · ${day?.completed ?? 0} realizadas';
  }

  String statusLabel(MedicationApplication item) => switch (item.state) {
    MedicationApplicationState.completed => 'Realizada',
    MedicationApplicationState.cancelled => 'Cancelada',
    MedicationApplicationState.pending =>
      state.serverNow != null && item.isOverdue(state.serverNow!)
          ? 'Atrasada'
          : 'Pendente',
  };
  String appliedLabel(MedicationApplication item) =>
      '${item.actorLabel ?? 'Funcionário'} · aplicada às ${item.performedLocalTime ?? ''}';
  void _publish(MedicationCalendarState value) {
    if (!_disposed) {
      _state = value;
      notifyListeners();
    }
  }

  void refreshAccess() {
    if (_disposed) return;
    if (_generation != _privateGeneration()) {
      _generation = _privateGeneration();
      _filter = null;
      _monthRequest++;
      _dayRequest++;
      _state = const MedicationCalendarState();
    }
    notifyListeners();
  }

  bool _current(int request, bool month, int epoch) =>
      !_disposed &&
      _isAuthorized() &&
      _generation == _privateGeneration() &&
      epoch == _accessEpoch() &&
      request == (month ? _monthRequest : _dayRequest);
  Future<bool> _check() async =>
      !_disposed &&
      (_authorize == null ? _isAuthorized() : await _authorize()) &&
      !_disposed &&
      _isAuthorized();
  Future<void> _failure(AppFailure failure, bool month) async {
    if (failure.code == FailureCode.forbidden ||
        failure.code == FailureCode.unauthenticated) {
      _monthRequest++;
      _dayRequest++;
      _publish(
        const MedicationCalendarState(
          monthError: 'Entre novamente para acessar a agenda.',
        ),
      );
      await _authorize?.call();
      return;
    }
    _publish(
      month
          ? state.copyWith(monthError: failureMessage(failure))
          : state.copyWith(dayError: failureMessage(failure)),
    );
  }

  Future<void> initialize() async {
    if (state.month.isNotEmpty) {
      await refresh();
      return;
    }
    final date = _now().toUtc();
    await _loadMonth(
      '${date.year}-${date.month.toString().padLeft(2, '0')}',
      alignToday: true,
    );
  }

  Future<void> applicationReturned() => refresh();

  Future<void> refresh() async {
    if (state.month.isEmpty) {
      await initialize();
    } else {
      await _loadMonth(state.month);
    }
  }

  Future<void> today() async {
    final today = state.monthData?.shelterToday;
    if (today == null) {
      await initialize();
      return;
    }
    await _loadMonth(
      today.substring(0, 7),
      selectedDay: today,
      alignToday: true,
    );
  }

  Future<void> moveMonth(int delta) async {
    if (!canNavigate || state.month.isEmpty) return;
    final date = DateTime.parse('${state.month}-01');
    final next = DateTime.utc(date.year, date.month + delta);
    if (next.year < 2000 || next.year > 2100) return;
    await _loadMonth(
      '${next.year}-${next.month.toString().padLeft(2, '0')}',
      selectedDay: '${next.year}-${next.month.toString().padLeft(2, '0')}-01',
    );
  }

  Future<void> _loadMonth(
    String month, {
    String? selectedDay,
    bool alignToday = false,
  }) async {
    if (_disposed) return;
    final request = ++_monthRequest;
    _dayRequest++;
    final selected =
        selectedDay ??
        (state.selectedDay.startsWith('$month-')
            ? state.selectedDay
            : '$month-01');
    _publish(
      state.copyWith(
        month: month,
        selectedDay: selected,
        monthData: null,
        items: [],
        cursor: null,
        agendaVersion: null,
        loadingMonth: true,
        loadingDay: false,
        monthError: null,
        dayError: null,
      ),
    );
    try {
      if (!await _check()) return;
      final epoch = _accessEpoch();
      final result = await repository.loadMonth(month);
      if (!_current(request, true, epoch)) return;
      if (result case Success<MedicationMonth>(:final value)) {
        final day = alignToday ? value.shelterToday : selected;
        if (alignToday && !day.startsWith('$month-')) {
          await _loadMonth(day.substring(0, 7), selectedDay: day);
          return;
        }
        _publish(
          state.copyWith(
            monthData: value,
            serverNow: value.serverNow,
            selectedDay: day,
          ),
        );
        await selectDay(day);
      } else {
        await _failure((result as Failure<MedicationMonth>).failure, true);
      }
    } catch (_) {
      if (!_disposed && request == _monthRequest) {
        await _failure(AppFailure(FailureCode.unknown), true);
      }
    } finally {
      if (!_disposed && request == _monthRequest) {
        _publish(state.copyWith(loadingMonth: false));
      }
    }
  }

  Future<void> selectDay(String day) async {
    if (_disposed ||
        !MedicationSchedule.validDate(day) ||
        !day.startsWith('${state.month}-')) {
      return;
    }
    final request = ++_dayRequest;
    _publish(
      state.copyWith(
        selectedDay: day,
        items: [],
        cursor: null,
        agendaVersion: null,
        loadingDay: true,
        dayError: null,
      ),
    );
    await _loadDay(request, day, null);
  }

  Future<void> loadMore() async {
    if (!canLoadMore) return;
    final request = ++_dayRequest;
    final cursor = state.cursor;
    _publish(state.copyWith(loadingDay: true, dayError: null));
    await _loadDay(request, state.selectedDay, cursor);
  }

  Future<void> _loadDay(int request, String day, String? cursor) async {
    try {
      if (!await _check()) return;
      final epoch = _accessEpoch();
      final result = await repository.loadDay(
        day,
        cursor: cursor,
        filter: _filter,
      );
      if (!_current(request, false, epoch)) return;
      if (result case Success<MedicationDayPage>(:final value)) {
        if (cursor != null && state.agendaVersion != value.agendaVersion) {
          await refresh();
          return;
        }
        final existing = cursor == null
            ? <MedicationApplication>[]
            : state.items;
        if (value.cursor != null && value.cursor == cursor ||
            value.items.any(
              (item) => existing.any((old) => old.id == item.id),
            )) {
          await _failure(AppFailure(FailureCode.unknown), false);
          return;
        }
        final items = [...existing, ...value.items]
          ..sort((a, b) {
            final order = a.scheduledAt.compareTo(b.scheduledAt);
            return order == 0 ? a.id.compareTo(b.id) : order;
          });
        _publish(
          state.copyWith(
            items: items,
            cursor: value.cursor,
            agendaVersion: value.agendaVersion,
            serverNow: value.serverNow,
          ),
        );
      } else {
        final failure = (result as Failure<MedicationDayPage>).failure;
        if (cursor != null && failure.code == FailureCode.conflict) {
          await refresh();
          return;
        }
        await _failure(failure, false);
      }
    } catch (_) {
      if (!_disposed && request == _dayRequest) {
        await _failure(AppFailure(FailureCode.unknown), false);
      }
    } finally {
      if (!_disposed && request == _dayRequest) {
        _publish(state.copyWith(loadingDay: false));
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _monthRequest++;
    _dayRequest++;
    _onDispose?.call();
    super.dispose();
  }
}
