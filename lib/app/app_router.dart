import 'dart:async';
import '../domain/repositories/medications_repository.dart';
import '../domain/models/medication_treatment.dart';
import '../ui/features/medications/view_models/medication_editor_view_model.dart';
import '../ui/features/medications/views/medication_editor_panel.dart';
import '../ui/features/photos/view_models/photo_upload_view_model.dart';
import '../ui/features/photos/view_models/photo_recovery_view_model.dart';
import '../ui/features/animals/view_models/animal_editor_view_model.dart';
import '../ui/features/animals/view_models/dashboard_view_model.dart';
import '../ui/features/animals/views/animal_editor_screen.dart';
import '../ui/features/animals/views/dashboard_screen.dart';
import '../domain/repositories/auth_repository.dart';
import '../ui/features/auth/view_models/session_view_model.dart';
import '../ui/features/auth/view_models/login_view_model.dart';
import '../ui/features/auth/views/protected_scope.dart';
import '../ui/features/auth/views/login_screen.dart';
import '../ui/features/auth/views/volunteer_access_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/repositories/animals_repository.dart';
import '../domain/repositories/favorites_repository.dart';
import '../domain/repositories/photo_repository.dart';
import '../domain/repositories/adoption_message_repository.dart';
import '../ui/features/home/view_models/home_view_model.dart';
import '../ui/features/home/view_models/about_view_model.dart';
import '../ui/features/animals/view_models/catalog_view_model.dart';
import '../ui/features/animals/view_models/animal_detail_view_model.dart';
import '../ui/features/favorites/view_models/favorites_view_model.dart';
import '../ui/features/home/views/home_screen.dart';
import '../ui/features/home/views/about_screen.dart';
import '../ui/features/animals/views/catalog_screen.dart';
import '../ui/features/animals/views/animal_detail_screen.dart';
import '../ui/features/favorites/views/favorites_screen.dart';

class AppRouter {
  const AppRouter({
    required this.animals,
    required this.favorites,
    required this.photos,
    required this.adoption,
    this.auth,
    this.session,
    this.recovery,
    this.medications,
  });
  final MedicationsRepository? medications;
  final PhotoRecoveryViewModel? recovery;
  final AuthRepository? auth;
  final SessionViewModel? session;
  final AnimalsRepository animals;
  final FavoritesRepository favorites;
  final PhotoRepository photos;
  final AdoptionMessageRepository adoption;
  Route<dynamic> _page<T extends ChangeNotifier>(
    RouteSettings settings,
    T vm,
    Widget screen,
  ) => MaterialPageRoute(
    settings: settings,
    builder: (_) => ChangeNotifierProvider<T>(
      create: (_) => vm,
      lazy: false,
      child: screen,
    ),
  );
  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        final vm = HomeViewModel();
        return _page(settings, vm, HomeScreen(viewModel: vm, session: session));
      case '/login':
      case '/volunteer':
      case '/animal-editor':
      case '/animal-management':
      case '/medication-editor':
        final access = session;
        final repository = auth;
        if (access == null || repository == null) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const Scaffold(
              body: Center(child: Text('Serviço de acesso indisponível.')),
            ),
          );
        }
        final vm = LoginViewModel(
          repository,
          beginAttempt: access.beginSignIn,
          isAttemptCurrent: access.isAttemptCurrent,
          onAccess: access.completeSignIn,
          onFailure: access.failSignIn,
          onCancel: access.cancelSignIn,
        );
        if (settings.name == '/login') {
          return _page(settings, vm, LoginScreen(viewModel: vm));
        }
        access.revalidate();
        return _page(
          settings,
          vm,
          ProtectedScope(
            session: access,
            login: vm,
            privateBuilder: () {
              Future<bool>? accessCheck;
              Future<bool> authorize() {
                return accessCheck ??= (() async {
                  await access.revalidate();
                  return access.state.canAccessPrivate;
                })().whenComplete(() => accessCheck = null);
              }

              MedicationEditorViewModel createMedicationEditor() {
                late final MedicationEditorViewModel editor;
                editor = MedicationEditorViewModel(
                  medications!,
                  animals: animals,
                  isAuthorized: () => access.state.canAccessPrivate,
                  accessEpoch: () => access.state.accessEpoch,
                  privateGeneration: () => access.state.privateGeneration,
                  authorize: authorize,
                  onDispose: () => access.removeListener(editor.refreshAccess),
                );
                access.addListener(editor.refreshAccess);
                return editor;
              }

              if (settings.name == '/medication-editor') {
                final args = settings.arguments;
                if (medications == null ||
                    args is! Map ||
                    args['animalId'] is! String ||
                    !isMedicationIdentifier(args['animalId'] as String) ||
                    (args['treatmentId'] != null &&
                        (args['treatmentId'] is! String ||
                            !isMedicationIdentifier(
                              args['treatmentId'] as String,
                            )))) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Programação indisponível para este animal.'),
                    ),
                  );
                }
                final medication = createMedicationEditor();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  unawaited(
                    medication
                        .bindAnimal(args['animalId'] as String, '')
                        .then(
                          (_) => medication.openTreatment(
                            args['treatmentId'] as String?,
                          ),
                        ),
                  );
                });
                return ChangeNotifierProvider<MedicationEditorViewModel>(
                  create: (_) => medication,
                  lazy: false,
                  child: MedicationProgrammingScreen(viewModel: medication),
                );
              }

              if (settings.name == '/animal-editor') {
                final medication = medications == null
                    ? null
                    : createMedicationEditor();
                final editor = AnimalEditorViewModel(
                  animals,
                  isAuthorized: () => access.state.canAccessPrivate,
                  accessEpoch: () => access.state.accessEpoch,
                  authorize: authorize,
                );
                access.addListener(editor.refreshAccess);
                final management = DashboardViewModel(
                  animals,
                  isAuthorized: () => access.state.canAccessPrivate,
                  accessEpoch: () => access.state.accessEpoch,
                  authorize: authorize,
                );
                late final PhotoUploadViewModel photo;
                var formVersion = -1;
                String? boundId;
                void synchronize() {
                  if (medication != null) {
                    unawaited(
                      medication.bindAnimal(
                        editor.state.draft.id,
                        editor.state.draft.name,
                      ),
                    );
                  }
                  if (formVersion != editor.state.formVersion ||
                      boundId != editor.state.draft.id) {
                    formVersion = editor.state.formVersion;
                    boundId = editor.state.draft.id;
                    photo.bindAnimal(boundId, editor.state.primaryPhotoId);
                    management.loadFocused(boundId);
                  }
                }

                photo = PhotoUploadViewModel(
                  photos,
                  isAuthorized: () => access.state.canAccessPrivate,
                  accessEpoch: () => access.state.accessEpoch,
                  privateGeneration: () => access.state.privateGeneration,
                  authorize: authorize,
                  recoverCandidate: recovery?.confirmForAnimal,
                  recoveryAvailable: () => recovery?.canOffer ?? false,
                  onDispose: () {
                    access.removeListener(editor.refreshAccess);
                    editor.removeListener(synchronize);
                    recovery?.removeListener(photo.refreshRecovery);
                  },
                );
                editor.addListener(synchronize);
                recovery?.addListener(photo.refreshRecovery);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (settings.arguments is String) {
                    editor.load(settings.arguments as String);
                  } else {
                    synchronize();
                  }
                });
                return MultiProvider(
                  providers: [
                    if (medication != null)
                      ChangeNotifierProvider<MedicationEditorViewModel>(
                        create: (_) => medication,
                        lazy: false,
                      ),
                    ChangeNotifierProvider<DashboardViewModel>(
                      create: (_) => management,
                      lazy: false,
                    ),
                    ChangeNotifierProvider<AnimalEditorViewModel>(
                      create: (_) => editor,
                      lazy: false,
                    ),
                    ChangeNotifierProvider<PhotoUploadViewModel>(
                      create: (_) => photo,
                      lazy: false,
                    ),
                  ],
                  child: AnimalEditorScreen(
                    viewModel: editor,
                    photoViewModel: photo,
                    managementViewModel: management,
                    medicationViewModel: medication,
                  ),
                );
              }
              if (settings.name == '/animal-management') {
                final listing = DashboardViewModel(
                  animals,
                  isAuthorized: () => access.state.canAccessPrivate,
                  accessEpoch: () => access.state.accessEpoch,
                  authorize: authorize,
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  listing.load();
                });
                return ChangeNotifierProvider<DashboardViewModel>(
                  create: (_) => listing,
                  lazy: false,
                  child: DashboardScreen(
                    viewModel: listing,
                    onSignOut: access.signOut,
                  ),
                );
              }
              return VolunteerAccessScreen(viewModel: access);
            },
          ),
        );
      case '/about':
        final vm = AboutViewModel();
        return _page(settings, vm, AboutScreen(viewModel: vm));
      case '/catalog':
        final vm = CatalogViewModel(animals, favorites, photos);
        vm.load();
        return _page(settings, vm, CatalogScreen(viewModel: vm));
      case '/favorites':
        final vm = FavoritesViewModel(animals, favorites, photos);
        vm.load();
        return _page(settings, vm, FavoritesScreen(viewModel: vm));
      case '/detail':
        final vm = AnimalDetailViewModel(animals, favorites, photos, adoption);
        vm.load(
          settings.arguments is String ? settings.arguments as String : '',
        );
        return PageRouteBuilder<void>(
          settings: settings,
          opaque: false,
          barrierDismissible: true,
          barrierLabel: 'Fechar detalhes',
          pageBuilder: (_, _, _) =>
              ChangeNotifierProvider<AnimalDetailViewModel>(
                create: (_) => vm,
                lazy: false,
                child: AnimalDetailScreen(viewModel: vm),
              ),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Página não encontrada.')),
          ),
        );
    }
  }
}
