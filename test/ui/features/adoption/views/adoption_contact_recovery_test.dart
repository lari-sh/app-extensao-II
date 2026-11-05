import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/adoption/views/adoption_contact_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/adoption/view_models/adoption_contact_view_model.dart';
import 'package:abrigo_dos_anjos/domain/repositories/adoption_contact_repository.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/presentation_fixtures.dart';

class ContactRecoveryRepository implements AdoptionContactRepository {
  int calls = 0;
  Future<Result<Unit>> Function() handler = () async =>
      const Success(Unit.value);
  @override
  Future<Result<Unit>> open(AdoptionChannel channel, PublicAnimal animal) {
    calls++;
    return handler();
  }
}

void main() {
  testWidgets(
    'contact retries loading and handles in-flight opening, platform failure and revalidation denial',
    (tester) async {
      final animal = presentationAnimal('bento');
      var failRead = true;
      final repo = FakeAnimalsRepository()
        ..handler = (_, _) async => failRead
            ? Failure<PublicAnimal>(AppFailure(FailureCode.network))
            : Success(animal);
      final contacts = ContactRecoveryRepository();
      final vm = AdoptionContactViewModel(repo, contacts);
      addTearDown(vm.dispose);
      await vm.load(animal.id);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => AdoptionContactScreen(viewModel: vm),
                  ),
                ),
                child: const Text('Abrir contato'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir contato'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Tentar novamente'), 180);
      await tester.pumpAndSettle();
      expect(find.textContaining('Não foi possível carregar'), findsOneWidget);
      failRead = false;
      await tester.ensureVisible(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(vm.state.canContact, isTrue);
      final pending = Completer<Result<Unit>>();
      contacts.handler = () => pending.future;
      await tester.scrollUntilVisible(find.text('WhatsApp'), -180);
      await tester.pumpAndSettle();
      await tester.tap(find.text('WhatsApp'));
      await tester.pump();
      await tester.pump();
      expect(vm.state.opening, isTrue);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      pending.complete(Failure(AppFailure(FailureCode.network)));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Tentar novamente'), 180);
      await tester.pumpAndSettle();
      expect(find.textContaining('Não foi possível abrir'), findsOneWidget);
      contacts.handler = () async => throw StateError('private stack');
      await vm.openInstagram();
      await tester.pumpAndSettle();
      expect(vm.state.message, isNot(contains('private')));
      failRead = true;
      final before = contacts.calls;
      await vm.openFacebook();
      await tester.pumpAndSettle();
      expect(contacts.calls, before);
      expect(find.textContaining('Não foi possível confirmar'), findsOneWidget);
      await tester.tap(find.byTooltip('Voltar à ficha do animal'));
      await tester.pumpAndSettle();
      expect(find.text('Abrir contato'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
