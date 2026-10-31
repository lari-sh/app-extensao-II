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
import 'abrigo_app.dart';
import 'app_router.dart';
import 'app_dependencies.dart';

Widget createPublicApplication(SupabaseClient client) {
  final animalsService = SupabaseAnimalsService(client);
  final photosService = SupabasePhotoApiService(client);
  final favoritesService = SharedPreferencesFavoritesService(
    SharedPreferencesAsync(),
  );
  final clipboardService = FlutterClipboardService();
  final animals = AnimalsRepositoryImpl(animalsService);
  final favorites = FavoritesRepositoryImpl(favoritesService);
  final photos = PhotoRepositoryImpl(photosService);
  final adoption = AdoptionMessageRepositoryImpl(clipboardService);
  final router = AppRouter(
    animals: animals,
    favorites: favorites,
    photos: photos,
    adoption: adoption,
  );
  return const AppDependencies().provide(
    registrations: [
      Provider<AnimalsService>.value(value: animalsService),
      Provider<PhotoApiService>.value(value: photosService),
      Provider<FavoritesStorageService>.value(value: favoritesService),
      Provider<ClipboardService>.value(value: clipboardService),
      Provider<AnimalsRepository>.value(value: animals),
      Provider<FavoritesRepository>.value(value: favorites),
      Provider<PhotoRepository>.value(value: photos),
      Provider<AdoptionMessageRepository>.value(value: adoption),
    ],
    child: AbrigoApp(onGenerateRoute: router.onGenerateRoute),
  );
}
