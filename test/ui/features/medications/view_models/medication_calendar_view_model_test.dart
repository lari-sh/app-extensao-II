import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_agenda.dart';
import 'package:abrigo_dos_anjos/domain/models/medication_application.dart';
import 'package:abrigo_dos_anjos/ui/features/medications/view_models/medication_calendar_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_medications_repository.dart';

MedicationApplication application(
  String id, {
  String day = '2026-11-01',
  String time = '08:00',
}) => MedicationApplication(
  id: id,
  treatmentId: 't',
  animalId: 'a',
  animalName: 'Atena',
  medicationName: 'Exemplo',
  revision: 1,
  version: 1,
  scheduledAt: DateTime.utc(2026, 11, 1, 11),
  scheduledLocalDate: day,
  scheduledLocalTime: time,
);
MedicationMonth month(String value, {String today = '2026-11-01'}) =>
    MedicationMonth(
      month: value,
      serverNow: DateTime.utc(2026, 11, 1, 12),
      shelterToday: today,
      days: [MedicationDaySummary(day: '$value-01', pending: 2)],
    );
MedicationDayPage page(
  String day, {
  String? cursor,
  int version = 1,
  List<MedicationApplication> items = const [],
}) => MedicationDayPage(
  day: day,
  serverNow: DateTime.utc(2026, 11, 1, 12),
  agendaVersion: version,
  items: items,
  cursor: cursor,
);
FakeMedicationsRepository repository() =>
    FakeMedicationsRepository()
      ..handler = (method, args) async => method == 'loadMonth'
          ? Success(month(args.first as String))
          : Success(page(args.first as String));
void main() {
  test(
    'civil grid supports 28,29,30,31 days, Sunday offset and year rollover',
    () async {
      final vm = MedicationCalendarViewModel(
        repository(),
        now: () => DateTime.utc(2026, 11, 1),
      );
      addTearDown(vm.dispose);
      await vm.initialize();
      expect(vm.cells.first, '2026-11-01');
      expect(vm.cells.whereType<String>(), hasLength(30));
      await vm.moveMonth(1);
      expect(vm.cells.whereType<String>(), hasLength(31));
      await vm.moveMonth(1);
      expect(vm.monthLabel, 'Janeiro 2027');
      await vm.moveMonth(1);
      expect(vm.cells.whereType<String>(), hasLength(28));
      await vm.moveMonth(12);
      expect(vm.cells.whereType<String>(), hasLength(29));
      expect(vm.cells.first, isNull);
    },
  );
  test(
    'initial day and today use server civil date across UTC month boundary',
    () async {
      final repo = repository()
        ..handler = (method, args) async => method == 'loadMonth'
            ? Success(month(args.first as String, today: '2026-10-31'))
            : Success(page(args.first as String));
      final vm = MedicationCalendarViewModel(
        repo,
        now: () => DateTime.utc(2026, 11, 1, 1),
      );
      addTearDown(vm.dispose);
      await vm.initialize();
      expect(vm.state.month, '2026-10');
      expect(vm.state.selectedDay, '2026-10-31');
      await vm.moveMonth(1);
      await vm.today();
      expect(vm.state.selectedDay, '2026-10-31');
    },
  );
  test(
    'pagination keeps all simultaneous items and overdue uses server time',
    () async {
      final repo = repository()
        ..handler = (method, args) async => method == 'loadMonth'
            ? Success(month(args.first as String))
            : Success(
                page(
                  args.first as String,
                  cursor: args[1] == null ? 'next' : null,
                  items: args[1] == null
                      ? [application('b')]
                      : [application('a')],
                ),
              );
      final vm = MedicationCalendarViewModel(repo);
      addTearDown(vm.dispose);
      await vm.initialize();
      await vm.loadMore();
      expect(vm.state.items.map((a) => a.id), ['a', 'b']);
      expect(vm.canLoadMore, false);
      expect(vm.statusLabel(vm.state.items.first), 'Atrasada');
      expect(vm.dayLabel, 'Domingo, 1 nov.');
      expect(vm.hasApplications('2026-11-01'), true);
    },
  );
  test(
    'snapshot conflict reloads month/day without mixing old items',
    () async {
      var first = 0;
      final repo = repository()
        ..handler = (method, args) async {
          if (method == 'loadMonth') {
            return Success(month(args.first as String));
          }
          if (args[1] != null) {
            return Failure<MedicationDayPage>(AppFailure(FailureCode.conflict));
          }
          first++;
          return Success(
            page(
              args.first as String,
              version: first,
              items: [application('item$first')],
              cursor: first == 1 ? 'next' : null,
            ),
          );
        };
      final vm = MedicationCalendarViewModel(repo);
      addTearDown(vm.dispose);
      await vm.initialize();
      await vm.loadMore();
      expect(vm.state.items.single.id, 'item2');
      expect(vm.state.agendaVersion, 2);
    },
  );
  test('changed snapshot in success also restarts pagination', () async {
    var calls = 0;
    final repo = repository()
      ..handler = (method, args) async => method == 'loadMonth'
          ? Success(month(args.first as String))
          : Success(
              page(
                args.first as String,
                version: ++calls,
                items: [application('$calls')],
                cursor: calls == 1 ? 'next' : null,
              ),
            );
    final vm = MedicationCalendarViewModel(repo);
    addTearDown(vm.dispose);
    await vm.initialize();
    await vm.loadMore();
    expect(vm.state.items.single.id, '3');
  });
  test(
    'empty day, recoverable failures and exceptions provide Portuguese state',
    () async {
      final repo = repository();
      final vm = MedicationCalendarViewModel(repo);
      addTearDown(vm.dispose);
      await vm.initialize();
      expect(vm.state.items, isEmpty);
      repo.handler = (method, args) async => method == 'loadMonth'
          ? Success(month(args.first as String))
          : Failure<MedicationDayPage>(AppFailure(FailureCode.network));
      await vm.selectDay('2026-11-02');
      expect(vm.state.dayError, isNotNull);
      expect(vm.state.loadingDay, false);
      repo.handler = (_, _) async => throw StateError('private');
      await vm.refresh();
      expect(vm.state.monthError, isNot(contains('private')));
      expect(vm.state.loadingMonth, false);
    },
  );
  test(
    'older month/day responses cannot overwrite current selection',
    () async {
      final delayed = Completer<Result<MedicationMonth>>();
      final repo = repository();
      final vm = MedicationCalendarViewModel(repo);
      addTearDown(vm.dispose);
      await vm.initialize();
      repo.handler = (method, args) async => method == 'loadMonth'
          ? (args.first == '2026-12'
                ? delayed.future
                : Success(month(args.first as String)))
          : Success(page(args.first as String));
      final old = vm.moveMonth(1);
      await Future<void>.delayed(Duration.zero);
      await vm.moveMonth(1);
      delayed.complete(Success(month('2026-12')));
      await old;
      expect(vm.state.month, '2027-01');
      final day = Completer<Result<MedicationDayPage>>();
      repo.handler = (_, args) => args.first == '2027-01-02'
          ? day.future
          : Future.value(Success(page(args.first as String)));
      final oldDay = vm.selectDay('2027-01-02');
      await Future<void>.delayed(Duration.zero);
      await vm.selectDay('2027-01-03');
      day.complete(Success(page('2027-01-02', items: [application('old')])));
      await oldDay;
      expect(vm.state.selectedDay, '2027-01-03');
      expect(vm.state.items, isEmpty);
    },
  );
  test(
    'private generation and epoch discard stale responses and clear logout data',
    () async {
      var epoch = 0, generation = 0;
      var allowed = true;
      final delayed = Completer<Result<MedicationDayPage>>();
      final repo = repository();
      final vm = MedicationCalendarViewModel(
        repo,
        isAuthorized: () => allowed,
        accessEpoch: () => epoch,
        privateGeneration: () => generation,
      );
      addTearDown(vm.dispose);
      await vm.initialize();
      repo.handler = (_, _) => delayed.future;
      final old = vm.selectDay('2026-11-02');
      await Future<void>.delayed(Duration.zero);
      epoch++;
      generation++;
      allowed = false;
      vm.refreshAccess();
      delayed.complete(
        Success(page('2026-11-02', items: [application('secret')])),
      );
      await old;
      expect(vm.state.month, isEmpty);
      expect(vm.state.items, isEmpty);
      expect(vm.canNavigate, false);
    },
  );
  test(
    'repeated page cursor fails without silently duplicating items',
    () async {
      final repo = repository()
        ..handler = (method, args) async => method == 'loadMonth'
            ? Success(month(args.first as String))
            : Success(
                page(
                  args.first as String,
                  cursor: 'same',
                  items: [application('same')],
                ),
              );
      final vm = MedicationCalendarViewModel(repo);
      addTearDown(vm.dispose);
      await vm.initialize();
      await vm.loadMore();
      expect(vm.state.items, hasLength(1));
      expect(vm.state.dayError, isNotNull);
    },
  );
  test(
    'forbidden clears private data and invokes authorization again',
    () async {
      var checks = 0;
      final repo = repository();
      final vm = MedicationCalendarViewModel(
        repo,
        authorize: () async {
          checks++;
          return true;
        },
      );
      addTearDown(vm.dispose);
      await vm.initialize();
      repo.handler = (_, _) async =>
          Failure<MedicationDayPage>(AppFailure(FailureCode.forbidden));
      await vm.selectDay('2026-11-02');
      expect(vm.state.items, isEmpty);
      expect(vm.state.month, isEmpty);
      expect(checks, greaterThan(2));
    },
  );
  test(
    'return from application reloads confirmed state without optimistic mutation',
    () async {
      final repo = repository();
      final vm = MedicationCalendarViewModel(repo);
      addTearDown(vm.dispose);
      await vm.initialize();
      final completed = application('done').copyWith(
        state: MedicationApplicationState.completed,
        performedBy: 'staff',
        actorLabel: 'Equipe',
        performedAt: DateTime.utc(2026, 11, 1, 12),
        performedLocalDate: '2026-11-01',
        performedLocalTime: '09:00',
      );
      repo.handler = (method, args) async => method == 'loadMonth'
          ? Success(month(args.first as String))
          : Success(page(args.first as String, items: [completed], version: 2));
      expect(vm.state.items, isEmpty);
      await vm.applicationReturned();
      expect(vm.state.items.single.actorLabel, 'Equipe');
      expect(vm.state.agendaVersion, 2);
    },
  );
}
