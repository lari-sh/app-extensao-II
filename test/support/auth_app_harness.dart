import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:abrigo_dos_anjos/app/app_dependencies.dart';
import 'package:abrigo_dos_anjos/app/auth_application.dart';
import 'package:abrigo_dos_anjos/app/app_router.dart';
import 'package:abrigo_dos_anjos/ui/features/auth/view_models/session_view_model.dart';
import 'package:abrigo_dos_anjos/domain/repositories/auth_repository.dart';
import 'package:abrigo_dos_anjos/domain/models/session_access.dart';
import 'package:abrigo_dos_anjos/utils/result.dart';
import 'public_app_harness.dart';
import 'fakes/fake_auth_repository.dart';

class AuthAppHarness extends PublicAppHarness {
  final auth = FakeAuthRepository();
  SessionAccess access = const SessionAccess();
  late final session = SessionViewModel(auth);
  AuthAppHarness() {
    auth.handler = (method, args) async {
      if (method == 'signIn') {
        access = const SessionAccess(
          level: AccessLevel.authorized,
          userId: 'u',
        );
        return Success(access);
      }
      if (method == 'signOut') {
        access = const SessionAccess();
        return const Success(Unit.value);
      }
      return Success(access);
    };
  }
  @override
  Widget app() {
    unawaited(session.start());
    return const AppDependencies().provide(
      registrations: [
        Provider<AuthRepository>.value(value: auth),
        ChangeNotifierProvider<SessionViewModel>(
          create: (_) => session,
          lazy: false,
        ),
      ],
      child: AuthApplication(
        session: session,
        router: AppRouter(
          animals: animals,
          favorites: favorites,
          photos: photos,
          adoption: adoption,
          auth: auth,
          session: session,
        ),
      ),
    );
  }
}
