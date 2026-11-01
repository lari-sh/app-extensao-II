import '../data/repositories/adoption_contact_repository_impl.dart';
import '../data/services/url_launcher_link_service.dart';
import '../domain/repositories/medications_repository.dart';
import '../data/services/medications_service.dart';
import '../data/services/supabase_medications_service.dart';
import '../data/repositories/medications_repository_impl.dart';
import '../data/services/gallery_service.dart';
import '../data/services/image_picker_gallery_service.dart';
import '../ui/features/photos/view_models/photo_recovery_view_model.dart';
import 'dart:async';
import '../data/services/auth_service.dart';
import '../data/services/supabase_auth_service.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../ui/features/auth/view_models/session_view_model.dart';
import 'auth_application.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/animals_service.dart';
import '../data/services/supabase_animals_service.dart';
import '../data/services/photo_api_service.dart';
import '../data/services/supabase_photo_api_service.dart';
import '../data/services/favorites_storage_service.dart';
import '../data/services/shared_preferences_favorites_service.dart';
import '../data/services/clipboard_service.dart';
import '../data/services/flutter_clipboard_service.dart';
import '../data/repositories/animals_repository_impl.dart';
import '../data/repositories/favorites_repository_impl.dart';
import '../data/repositories/photo_repository_impl.dart';
import '../data/repositories/adoption_message_repository_impl.dart';
import '../domain/repositories/animals_repository.dart';
import '../domain/repositories/favorites_repository.dart';
import '../domain/repositories/photo_repository.dart';
import '../domain/repositories/adoption_message_repository.dart';
import 'app_router.dart';
import 'app_dependencies.dart';

Widget createPublicApplication(SupabaseClient client) {
  final authService = SupabaseAuthService(client);
  final auth = AuthRepositoryImpl(authService);
  final session = SessionViewModel(auth);
  final sessionReady = session.start();
  final animalsService = SupabaseAnimalsService(client);
  final photosService = SupabasePhotoApiService(client);
  final favoritesService = SharedPreferencesFavoritesService(
    SharedPreferencesAsync(),
  );
  final clipboardService = FlutterClipboardService();
  final animals = AnimalsRepositoryImpl(animalsService);
  final medicationService = SupabaseMedicationsService(client);
  final medications = MedicationsRepositoryImpl(medicationService);
  final favorites = FavoritesRepositoryImpl(favoritesService);
  final gallery = ImagePickerGalleryService();
  final photos = PhotoRepositoryImpl(photosService, gallery: gallery);
  late final PhotoRecoveryViewModel recovery;
  recovery = PhotoRecoveryViewModel(
    photos,
    isAuthorized: () => session.state.canAccessPrivate,
    userId: () => session.state.userId,
    retainPrivate: () => session.state.retainPrivate,
    authorize: () async {
      await session.revalidate();
      return session.state.canAccessPrivate;
    },
    onDispose: () => session.removeListener(recovery.accessChanged),
  );
  session.addListener(recovery.accessChanged);
  unawaited(sessionReady.then((_) => recovery.recover()));
  final adoption = AdoptionMessageRepositoryImpl(clipboardService);
  final router = AppRouter(
    recovery: recovery,
    auth: auth,
    session: session,
    animals: animals,
    favorites: favorites,
    photos: photos,
    adoption: adoption,
    medications: medications,
    contacts: AdoptionContactRepositoryImpl(UrlLauncherLinkService()),
  );
  return const AppDependencies().provide(
    registrations: [
      Provider<AuthService>.value(value: authService),
      Provider<AuthRepository>.value(value: auth),
      ChangeNotifierProvider<SessionViewModel>(
        create: (_) => session,
        lazy: false,
      ),
      Provider<GalleryService>.value(value: gallery),
      ChangeNotifierProvider<PhotoRecoveryViewModel>(
        create: (_) => recovery,
        lazy: false,
      ),
      Provider<AnimalsService>.value(value: animalsService),
      Provider<MedicationsService>.value(value: medicationService),
      Provider<MedicationsRepository>.value(value: medications),
      Provider<PhotoApiService>.value(value: photosService),
      Provider<FavoritesStorageService>.value(value: favoritesService),
      Provider<ClipboardService>.value(value: clipboardService),
      Provider<AnimalsRepository>.value(value: animals),
      Provider<FavoritesRepository>.value(value: favorites),
      Provider<PhotoRepository>.value(value: photos),
      Provider<AdoptionMessageRepository>.value(value: adoption),
    ],
    child: AuthApplication(session: session, router: router),
  );
}
