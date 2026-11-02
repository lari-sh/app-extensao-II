import '../data/services/supabase_auth_callback_service.dart';
import 'public_dependencies.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../ui/features/home/view_models/startup_view_model.dart';
import '../ui/features/home/views/startup_screen.dart';
import 'app_dependencies.dart';
import 'abrigo_app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../utils/app_failure.dart';
import '../utils/result.dart';

/// Composition-only SDK initialization. No queries or private access here.
Future<Result<SupabaseClient>> initializeBackend(AppConfig config) async {
  try {
    await Supabase.initialize(
      url: config.url.toString(),
      publishableKey: config.publishableKey,
      authOptions: FlutterAuthClientOptions(
        detectSessionInUriPredicate:
            SupabaseAuthCallbackService.instance.capture,
      ),
    );
    SupabaseAuthCallbackService.instance.start(Supabase.instance.client);
    return Success(Supabase.instance.client);
  } catch (_) {
    return Failure(AppFailure(FailureCode.configuration));
  }
}

/// Public entry fails closed when the backend cannot be configured.
Future<Widget> bootstrapApplication() async {
  final config = AppConfig.fromEnvironment();
  var reason = FailureCode.configuration;
  if (config case Success<AppConfig>(:final value)) {
    final initialized = await initializeBackend(value);
    if (initialized case Success<SupabaseClient>(:final value)) {
      return createPublicApplication(value);
    }
    reason = FailureCode.configuration;
  }
  final startup = StartupViewModel(reason);
  return const AppDependencies().provide(
    registrations: [
      ChangeNotifierProvider<StartupViewModel>(
        create: (_) => startup,
        lazy: false,
      ),
    ],
    child: AbrigoApp(home: StartupScreen(viewModel: startup)),
  );
}
