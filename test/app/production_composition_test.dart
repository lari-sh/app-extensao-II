import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:abrigo_dos_anjos/app/public_dependencies.dart';
import 'package:abrigo_dos_anjos/app/bootstrap.dart';
import 'package:abrigo_dos_anjos/config/app_config.dart';
import 'package:abrigo_dos_anjos/domain/repositories/animals_repository.dart';
import 'package:abrigo_dos_anjos/domain/repositories/photo_repository.dart';
import 'package:abrigo_dos_anjos/domain/repositories/medications_repository.dart';
import 'package:abrigo_dos_anjos/domain/repositories/auth_repository.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });
  testWidgets(
    'production composition registers repositories and starts as visitor without remote writes',
    (tester) async {
      final requests = <http.Request>[];
      final client = (await tester.runAsync(
        () async => SupabaseClient(
          'https://example.test',
          'public',
          authOptions: const AuthClientOptions(autoRefreshToken: false),
          httpClient: MockClient((r) async {
            requests.add(r);
            return http.Response(
              '[]',
              200,
              request: r,
              headers: {
                'content-type': 'application/json',
                'content-range': '*/0',
              },
            );
          }),
        ),
      ))!;
      await tester.pumpWidget(createPublicApplication(client));
      await tester.pumpAndSettle();
      final context = tester.element(find.text('Quero Adotar (Visitante)'));
      expect(context.read<AnimalsRepository>(), isNotNull);
      expect(context.read<PhotoRepository>(), isNotNull);
      expect(context.read<MedicationsRepository>(), isNotNull);
      expect(context.read<AuthRepository>(), isNotNull);
      expect(context.read<SessionViewModel>().state.canAccessPrivate, isFalse);
      expect(requests, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      await tester.runAsync(client.dispose);
    },
  );
  testWidgets(
    'missing environment configuration renders startup warning without exposing raw error',
    (tester) async {
      await tester.pumpWidget(await bootstrapApplication());
      await tester.pumpAndSettle();
      expect(find.textContaining('configur'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'SDK initialization returns a client with local preference adapters',
    (tester) async {
      final result = await tester.runAsync(
        () => initializeBackend(
          AppConfig(
            url: Uri.parse('https://example.test'),
            publishableKey: 'public-test-key',
          ),
        ),
      );
      expect(result, isA<Success<SupabaseClient>>());
      await tester.runAsync(() => Supabase.instance.dispose());
    },
  );
}
