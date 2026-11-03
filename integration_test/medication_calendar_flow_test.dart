import 'package:abrigo_dos_anjos/ui/features/animals/views/animal_editor_screen.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android saves treatments and browses calendar month and daily agenda', (
    tester,
  ) async {
    const url = String.fromEnvironment('SUPABASE_URL');
    expect(Uri.parse(url).host, anyOf('10.0.2.2', '127.0.0.1'));
    final fixtureHost = Uri.parse(url).host;
    final password =
        (jsonDecode(
                  (await http.get(
                    Uri.parse('http://$fixtureHost:58763/fixture-password'),
                  )).body,
                )
                as Map)['password']
            as String;
    final second = SupabaseClient(
      url,
      const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    await second.auth.signInWithPassword(
      email: 'fixture-staff@example.test',
      password: password,
    );
    final utcGuess = DateTime.now().toUtc();
    final initialClock =
        await second.rpc(
              'get_medication_calendar_month',
              params: {
                'p_month':
                    '${utcGuess.year}-${utcGuess.month.toString().padLeft(2, '0')}',
              },
            )
            as Map;
    final shelterDate = DateTime.parse(initialClock['shelter_today'] as String);
    final windowFirst = DateTime.utc(shelterDate.year, shelterDate.month + 1);
    final windowSecond = windowFirst.add(const Duration(days: 1));
    String civil(DateTime date) =>
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    String display(DateTime date) =>
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    const months = [
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
    const shortMonths = [
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
    const weekdays = [
      'Segunda',
      'Terça',
      'Quarta',
      'Quinta',
      'Sexta',
      'Sábado',
      'Domingo',
    ];
    final windowMonth = civil(windowFirst).substring(0, 7);
    Future<void> waitFor(Finder finder) async {
      for (
        var attempt = 0;
        attempt < 100 && finder.evaluate().isEmpty;
        attempt++
      ) {
        await tester.pumpAndSettle();
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect(finder, findsWidgets);
    }

    final name =
        '000 Fixture calendario medicacao ${DateTime.now().microsecondsSinceEpoch}';
    String key(String prefix) =>
        '$prefix${DateTime.now().microsecondsSinceEpoch}'
            .padRight(32, prefix)
            .substring(0, 32);
    final animal =
        await second.rpc(
              'save_animal',
              params: {
                'p_operation_key': key('a'),
                'p_payload': {
                  'name': name,
                  'species': 'dog',
                  'sex': 'female',
                  'size': 'small',
                  'approximate_age': '2 anos',
                  'clinical_notes': 'Nota privada da jornada de medicação',
                },
              },
            )
            as Map;
    final animalId = (animal['animal'] as Map)['id'] as String;
    Future<void> waitEditor() async {
      var stable = 0;
      for (var attempt = 0; attempt < 100; attempt++) {
        await tester.pumpAndSettle();
        final editor = find.byType(AnimalEditorScreen);
        if (editor.evaluate().length == 1) {
          final screen = tester.widget<AnimalEditorScreen>(editor);
          final medication = screen.medicationViewModel;
          if (screen.viewModel.state.draft.id == animalId &&
              screen.viewModel.canEdit &&
              medication != null &&
              !medication.state.loading &&
              !medication.state.saving &&
              !medication.state.uncertain &&
              !(screen.managementViewModel?.state.loading ?? false)) {
            stable++;
            if (stable >= 2) return;
          } else {
            stable = 0;
          }
        } else {
          stable = 0;
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      fail('Animal editor did not finish loading and access verification');
    }

    try {
      await tester.pumpWidget(await bootstrapApplication());
      await tester.pumpAndSettle();
      await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Acesso Voluntário / Funcionário'));
      await tester.pumpAndSettle();
      await waitFor(find.byKey(const ValueKey('loginEmail')));
      await tester.enterText(
        find.byKey(const ValueKey('loginEmail')),
        'fixture-staff@example.test',
      );
      await tester.enterText(
        find.byKey(const ValueKey('loginPassword')),
        password,
      );
      // Exercise the screen's keyboard submit action exactly once, then wait
      // for confirmed navigation instead of tapping a route that may be leaving.
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await waitFor(find.text('Animais do abrigo'));
      // Navigate through the real dashboard/editor; the fixture may be on a later page.
      await tester.tap(find.text('Animais do abrigo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();
      final menu = find.byTooltip('Ações de $name');
      for (var i = 0; i < 35 && menu.evaluate().isEmpty; i++) {
        final more = find.text('Carregar mais disponíveis');
        if (more.evaluate().isNotEmpty) {
          await tester.ensureVisible(more);
          await tester.tap(more);
        } else {
          await tester.drag(
            find.byType(Scrollable).last,
            const Offset(0, -500),
          );
        }
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(menu);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar cadastro'));
      await tester.pumpAndSettle();
      Future<void> openMedication() async {
        await waitEditor();
        final add = find.text('Adicionar medicação');
        await tester.scrollUntilVisible(
          add,
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(add);
        await tester.pumpAndSettle();
        expect(find.text('Programar medicação'), findsOneWidget);
      }

      Future<void> enter(String key, String value) async {
        final field = find.byKey(ValueKey(key));
        final scroll = find
            .descendant(
              of: find.byKey(const ValueKey('medicationFormScroll')),
              matching: find.byType(Scrollable),
            )
            .first;
        await tester.scrollUntilVisible(field, 180, scrollable: scroll);
        await tester.pumpAndSettle();
        await tester.enterText(field, value);
        await tester.pumpAndSettle();
      }

      Future<void> save() async {
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.tap(find.text('Salvar programação'));
        await tester.pumpAndSettle();
        expect(find.text('Programar medicação'), findsNothing);
      }

      await openMedication();
      await enter('medicationName', 'Medicação Android fixos');
      await enter('medicationStartsOn', display(windowFirst));
      await enter('medicationEndsOn', display(windowSecond));
      await save();
      var page =
          await second.rpc(
                'list_animal_medication_treatments',
                params: {'p_animal_id': animalId, 'p_cursor': null},
              )
              as Map;
      final fixed = (page['items'] as List).single as Map;
      expect(fixed['fixed_times'], ['08:00', '20:00']);
      expect(
        (await second
                .from('medication_applications')
                .select('id')
                .eq('treatment_id', fixed['id'] as String))
            .length,
        4,
      );
      await openMedication();
      await enter('medicationName', 'Medicação Android intervalo');
      await enter('medicationStartsOn', display(windowFirst));
      await enter('medicationEndsOn', display(windowSecond));
      await enter('medicationStartsTime', '20:00');
      final interval = find.text('Por intervalo');
      await tester.ensureVisible(interval);
      await tester.pumpAndSettle();
      await tester.tap(interval);
      await tester.pumpAndSettle();
      await save();
      page =
          await second.rpc(
                'list_animal_medication_treatments',
                params: {'p_animal_id': animalId, 'p_cursor': null},
              )
              as Map;
      expect(page['items'], hasLength(2));
      final elapsed = (page['items'] as List).cast<Map>().singleWhere(
        (item) => item['schedule_mode'] == 'interval',
      );
      expect(elapsed['interval_minutes'], 480);
      final applications = await second
          .from('medication_applications')
          .select('scheduled_at')
          .eq('treatment_id', elapsed['id'] as String);
      expect(applications, hasLength(4));
      final instants =
          applications
              .map(
                (item) =>
                    DateTime.parse(item['scheduled_at'] as String).toUtc(),
              )
              .toList()
            ..sort();
      for (var i = 1; i < instants.length; i++) {
        expect(
          instants[i].difference(instants[i - 1]),
          const Duration(hours: 8),
        );
      }
      final confirmed =
          await second.rpc(
                'get_managed_animal',
                params: {'p_animal_id': animalId},
              )
              as Map;
      expect(
        confirmed['clinical_notes'],
        'Nota privada da jornada de medicação',
      );
      expect(confirmed['animal']['is_published'], false);
      // US4 edit through the real medication route, preserving treatment identity.
      final fixedCard = find.text('Medicação Android fixos');
      await tester.scrollUntilVisible(
        fixedCard,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(fixedCard);
      await tester.pumpAndSettle();
      await enter('medicationInstructions', 'Instrução revisada no Android');
      await save();
      final revisedList =
          await second.rpc(
                'list_animal_medication_treatments',
                params: {'p_animal_id': animalId, 'p_cursor': null},
              )
              as Map;
      final revisedFixed = (revisedList['items'] as List)
          .cast<Map>()
          .singleWhere((item) => item['id'] == fixed['id']);
      expect(revisedFixed['revision'], 2);
      expect(revisedFixed['version'], 2);
      expect(revisedFixed['instructions'], 'Instrução revisada no Android');

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calendário'));
      await tester.pumpAndSettle();
      // The server civil date chooses the month; navigate by visible controls.
      final monthResponse =
          await second.rpc(
                'get_medication_calendar_month',
                params: {'p_month': windowMonth},
              )
              as Map;
      final today = monthResponse['shelter_today'] as String;
      final target = windowFirst;
      final current = DateTime.parse('$today 00:00:00');
      final delta =
          (target.year - current.year) * 12 + target.month - current.month;
      for (var step = 0; step < delta.abs(); step++) {
        await tester.tap(
          find.byTooltip(delta > 0 ? 'Próximo mês' : 'Mês anterior'),
        );
        await tester.pumpAndSettle();
      }
      expect(
        find.text('${months[windowFirst.month - 1]} ${windowFirst.year}'),
        findsOneWidget,
      );
      final dayOne = find.byKey(
        ValueKey('medicationDay-${civil(windowFirst)}'),
      );
      await tester.ensureVisible(dayOne);
      await tester.tap(dayOne);
      await tester.pumpAndSettle();
      final ownCard = find.text(name);
      await tester.scrollUntilVisible(
        ownCard.first,
        160,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('medicationCalendarScroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(ownCard, findsWidgets);
      expect(find.text('Medicação Android fixos'), findsWidgets);
      // Change month then return and select the second day.
      await tester.drag(
        find.byKey(const ValueKey('medicationCalendarScroll')),
        const Offset(0, 700),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Próximo mês'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          '${months[DateTime.utc(windowFirst.year, windowFirst.month + 1).month - 1]} ${DateTime.utc(windowFirst.year, windowFirst.month + 1).year}',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Mês anterior'));
      await tester.pumpAndSettle();
      final dayTwo = find.byKey(
        ValueKey('medicationDay-${civil(windowSecond)}'),
      );
      await tester.ensureVisible(dayTwo);
      await tester.tap(dayTwo);
      await tester.pumpAndSettle();
      final dayPage =
          await second.rpc(
                'list_medication_day',
                params: {'p_day': civil(windowSecond), 'p_cursor': null},
              )
              as Map;
      final ownApplications = (dayPage['items'] as List)
          .cast<Map>()
          .where(
            (item) =>
                item['animal_id'] == animalId && item['state'] != 'cancelled',
          )
          .toList();
      expect(ownApplications, hasLength(5));
      expect(
        ownApplications.map((item) => item['scheduled_local_time']),
        contains('04:00'),
      );
      expect(
        find.text(
          '${weekdays[windowSecond.weekday - 1]}, ${windowSecond.day} ${shortMonths[windowSecond.month - 1]}',
        ),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text(name).first,
        160,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('medicationCalendarScroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(find.text('Medicação Android intervalo'), findsWidgets);
      await tester.drag(
        find.byKey(const ValueKey('medicationCalendarScroll')),
        const Offset(0, 700),
      );
      await tester.pumpAndSettle();

      // US3: a due application anchored to the shelter's current civil midnight.
      final currentMonth = today.substring(0, 7);
      final dueSaved =
          await second.rpc(
                'save_medication_treatment',
                params: {
                  'p_operation_key': key('d'),
                  'p_payload': {
                    'animal_id': animalId,
                    'medication_name': 'Concluir medicação Android',
                    'instructions': 'Aplicação descartável da validação',
                    'schedule_mode': 'fixed_times',
                    'starts_on': today,
                    'starts_time': '00:00',
                    'ends_on': today,
                    'ends_time': '00:01',
                    'fixed_times': ['00:00'],
                  },
                },
              )
              as Map;
      final dueTreatment = (dueSaved['result'] as Map)['treatment'] as Map;
      final dueRows = await second
          .from('medication_applications')
          .select('id')
          .eq('treatment_id', dueTreatment['id'] as String);
      final dueId = dueRows.single['id'] as String;
      await tester.tap(find.text('Hoje'));
      await tester.pumpAndSettle();
      final dueAction = find.byTooltip('Ver aplicação de $name às 00:00');
      await tester.scrollUntilVisible(
        dueAction,
        180,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('medicationCalendarScroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(dueAction);
      await tester.pumpAndSettle();
      expect(find.text('Detalhes da aplicação'), findsOneWidget);
      await tester.tap(find.text('Marcar como aplicada'));
      await tester.pumpAndSettle();
      final history =
          await second.rpc(
                'get_medication_application_history',
                params: {'p_application_id': dueId, 'p_cursor': null},
              )
              as Map;
      var applied = history['application'] as Map;
      expect(applied['state'], 'completed');
      expect(applied['version'], 2);
      expect(
        applied['performed_by'],
        Supabase.instance.client.auth.currentUser!.id,
      );
      expect(history['items'], hasLength(1));
      expect(
        (history['items'] as List).single['occurred_at'],
        applied['performed_at'],
      );
      final afterCompletion =
          await second.rpc(
                'get_medication_calendar_month',
                params: {'p_month': currentMonth},
              )
              as Map;
      expect(
        DateTime.parse(
          applied['performed_at'] as String,
        ).isAfter(DateTime.parse(afterCompletion['server_now'] as String)),
        false,
      );
      final actor = applied['actor_label'] as String;
      await tester.scrollUntilVisible(
        find.text(actor),
        180,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('medicationApplicationScroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Aplicado por'), findsOneWidget);
      expect(find.text(actor), findsOneWidget);
      expect(find.text('Horário real'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Marcar como aplicada'),
            )
            .onPressed,
        isNull,
      );

      final correct = find.text('Corrigir registro de aplicação');
      await tester.scrollUntilVisible(
        correct,
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('medicationApplicationScroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(correct);
      await tester.pumpAndSettle();
      final reason = find.byKey(const ValueKey('medicationCorrectionReason'));
      await tester.ensureVisible(reason);
      await tester.pumpAndSettle();
      await tester.enterText(reason, 'Registro de teste feito por engano');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      final correctionConfirm = find.text('Confirmar correção');
      // Keyboard dismissal can move this lazy ListView child outside its cache.
      // Scroll until it is mounted before asking the tester to tap it.
      await tester.scrollUntilVisible(
        correctionConfirm,
        140,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('medicationApplicationScroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(correctionConfirm);
      await tester.pumpAndSettle();
      final corrected =
          await second.rpc(
                'get_medication_application_history',
                params: {'p_application_id': dueId, 'p_cursor': null},
              )
              as Map;
      expect(corrected['application']['state'], 'pending');
      expect(corrected['application']['version'], 3);
      expect(corrected['items'], hasLength(2));
      expect(
        (corrected['items'] as List).first,
        (history['items'] as List).first,
      );
      expect(
        (corrected['items'] as List).last['reason'],
        'Registro de teste feito por engano',
      );
      expect(
        (corrected['items'] as List).last['actor_id'],
        Supabase.instance.client.auth.currentUser!.id,
      );
      await tester.tap(find.text('Marcar como aplicada'));
      await tester.pumpAndSettle();
      final repeated =
          await second.rpc(
                'get_medication_application_history',
                params: {'p_application_id': dueId, 'p_cursor': null},
              )
              as Map;
      expect(repeated['application']['version'], 4);
      expect(repeated['items'], hasLength(3));
      expect(
        (repeated['items'] as List).first,
        (history['items'] as List).first,
      );
      applied = repeated['application'] as Map;
      await tester.tap(find.text('Voltar à agenda'));
      await tester.pumpAndSettle();
      final note = find.text(
        '$actor · aplicada às ${applied['performed_local_time']}',
      );
      await tester.scrollUntilVisible(
        note,
        180,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey('medicationCalendarScroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(note, findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(ValueKey('medicationApplication-$dueId')),
          matching: find.text('Realizada'),
        ),
        findsOneWidget,
      );
      await tester.drag(
        find.byKey(const ValueKey('medicationCalendarScroll')),
        const Offset(0, 700),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lista'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(menu);
      await tester.pumpAndSettle();
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar cadastro'));
      await tester.pumpAndSettle();
      await waitEditor();
      final stop = find.byTooltip('Interromper Medicação Android intervalo');
      try {
        await tester.scrollUntilVisible(
          stop,
          200,
          scrollable: find.byType(Scrollable).first,
        );
      } catch (_) {
        final screen = tester.widget<AnimalEditorScreen>(
          find.byType(AnimalEditorScreen, skipOffstage: false).first,
        );
        final m = screen.medicationViewModel!;
        debugPrint(
          'Medication panel diagnostic: bound=${m.state.animalId == animalId}, items=${m.state.treatments.length}, failed=${m.state.loadFailed}, loading=${m.state.loading}, message=${m.state.message}',
        );
        rethrow;
      }
      await tester.pumpAndSettle();
      await tester.tap(stop);
      await tester.pumpAndSettle();
      final stoppedPage =
          await second.rpc(
                'list_animal_medication_treatments',
                params: {'p_animal_id': animalId, 'p_cursor': null},
              )
              as Map;
      final stopped = (stoppedPage['items'] as List).cast<Map>().singleWhere(
        (item) => item['id'] == elapsed['id'],
      );
      expect(stopped['status'], 'stopped');
      expect(stopped['revision'], 1);
      expect(stopped['version'], 2);
      final stoppedApps = await second
          .from('medication_applications')
          .select('id,state')
          .eq('treatment_id', elapsed['id'] as String);
      expect(stoppedApps, hasLength(4));
      expect(stoppedApps.any((item) => item['state'] == 'cancelled'), true);
      await waitEditor();
      final saveAnimal = find.text('Salvar animal');
      await tester.scrollUntilVisible(
        saveAnimal,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(saveAnimal);
      await tester.pumpAndSettle();
      final preserved =
          await second.rpc(
                'list_animal_medication_treatments',
                params: {'p_animal_id': animalId, 'p_cursor': null},
              )
              as Map;
      expect(preserved, stoppedPage);
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kanban'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      expect(find.text('Área do voluntário'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      // Clean this journey's own animal even when a UI assertion fails locally.
      // The loopback controller validates the reserved fixture prefix and UUID.
      try {
        final cleanup = await http.post(
          Uri.parse('http://$fixtureHost:58763/cleanup-medication-fixture'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'animal_id': animalId}),
        );
        expect(
          cleanup.statusCode,
          204,
          reason: 'Disposable medication fixture cleanup',
        );
      } finally {
        await second.auth.signOut(scope: SignOutScope.local);
        await second.dispose();
        await Supabase.instance.client.auth.signOut(scope: SignOutScope.local);
        await tester.pumpAndSettle();
      }
    }
  });
}
