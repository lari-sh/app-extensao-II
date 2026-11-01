import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/ui/features/adoption/views/adoption_contact_screen.dart';
import 'package:abrigo_dos_anjos/ui/features/adoption/view_models/adoption_contact_view_model.dart';
import 'package:abrigo_dos_anjos/domain/repositories/adoption_contact_repository.dart';
import 'package:abrigo_dos_anjos/domain/models/animal.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import '../../../../support/fakes/fake_animals_repository.dart';
import '../../../../support/public_fixtures.dart';

class ContactFake implements AdoptionContactRepository {
  final channels = <AdoptionChannel>[];
  @override
  Future<Result<Unit>> open(
    AdoptionChannel channel,
    PublicAnimal animal,
  ) async {
    channels.add(channel);
    return const Success(Unit.value);
  }
}

void main() {
  for (final width in [320.0, 390.0]) {
    testWidgets(
      'approved contact composition at $width without message preview',
      (tester) async {
        tester.view.physicalSize = Size(width, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final animals = FakeAnimalsRepository()
          ..handler = (_, args) async => Success(fixtureAnimal(1));
        final contacts = ContactFake();
        final vm = AdoptionContactViewModel(animals, contacts);
        addTearDown(vm.dispose);
        await vm.load(fixtureId(1));
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(1.4)),
              child: AdoptionContactScreen(viewModel: vm),
            ),
          ),
        );
        expect(find.text('Fale com o abrigo'), findsOneWidget);
        expect(find.text('Luna 1'), findsOneWidget);
        expect(find.textContaining('Prévia da mensagem'), findsNothing);
        for (final label in ['WhatsApp', 'Instagram', 'Facebook']) {
          await tester.scrollUntilVisible(find.text(label), 150);
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
        }
        expect(contacts.channels, AdoptionChannel.values);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
