import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:abrigo_dos_anjos/data/animal_store.dart';
import 'package:abrigo_dos_anjos/legacy_demo.dart';
import 'package:abrigo_dos_anjos/models/animal.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  test('Cadastro, status e favoritos sobrevivem ao recarregamento', () async {
    final store = AnimalStore(SharedPreferencesAsync());
    await store.load();
    await store.save(
      const Animal(
        id: 'test',
        name: 'Atena',
        species: 'Cachorro',
        sex: 'Fêmea',
        size: 'Médio',
        age: '2 anos',
        vaccines: ['V10 exemplo'],
      ),
    );
    await store.toggleFavorite('test');
    await store.save(store.animals.last.withStatus(AnimalStatus.treatment));
    final restored = AnimalStore(SharedPreferencesAsync());
    await restored.load();
    expect(restored.animals.last.name, 'Atena');
    expect(restored.animals.last.vaccines, ['V10 exemplo']);
    expect(restored.animals.last.status, AnimalStatus.treatment);
    expect(restored.favorites, contains('test'));
  });
  testWidgets('Catálogo busca animais e mantém favoritos entre abas', (
    tester,
  ) async {
    await tester.pumpWidget(
      AbrigoApp(store: AnimalStore(SharedPreferencesAsync())),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Quero adotar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mia');
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(Card), matching: find.text('Mia')),
      findsOneWidget,
    );
    expect(find.text('Luna'), findsNothing);
    await tester.tap(find.byTooltip('Favoritar Mia'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(Card), matching: find.text('Mia')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('Formulário exige campos e salva um novo animal', (tester) async {
    final store = AnimalStore(SharedPreferencesAsync());
    await tester.pumpWidget(AbrigoApp(store: store));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Área do voluntário'));
    await tester.tap(find.text('Área do voluntário'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Explorar demonstração'));
    await tester.tap(find.text('Explorar demonstração'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar animal'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Atena');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Idade aproximada'),
      '2 anos',
    );
    await tester.scrollUntilVisible(
      find.text('Salvar cadastro'),
      400,
      scrollable: find
          .descendant(of: find.byType(Form), matching: find.byType(Scrollable))
          .first,
    );
    await tester.tap(find.text('Salvar cadastro'));
    await tester.pumpAndSettle();
    expect(store.animals.any((a) => a.name == 'Atena'), isTrue);
    expect(tester.takeException(), isNull);
  });
}
