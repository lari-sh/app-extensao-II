import 'package:flutter_test/flutter_test.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';
import 'package:abrigo_dos_anjos/ui/features/home/view_models/startup_view_model.dart';
import 'package:abrigo_dos_anjos/utils/app_failure.dart';

void main() {
  test('startup maps failures to Portuguese without SDK details', () {
    expect(
      StartupViewModel(FailureCode.configuration).state.message,
      contains('não está configurado'),
    );
    expect(
      StartupViewModel(FailureCode.network).state.message,
      contains('temporariamente indisponível'),
    );
  });
  testWidgets(
    'missing configuration never exposes demo management or fictitious animals',
    (tester) async {
      await tester.pumpWidget(await bootstrapApplication());
      await tester.pumpAndSettle();
      expect(find.text('Abrigo dos Anjos'), findsOneWidget);
      expect(find.textContaining('não está configurado'), findsOneWidget);
      expect(find.text('Explorar demonstração'), findsNothing);
      expect(find.text('Luna'), findsNothing);
    },
  );
}
