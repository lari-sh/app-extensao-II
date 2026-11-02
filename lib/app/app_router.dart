import '../ui/features/auth/views/recovery_screen.dart';
import '../ui/features/auth/views/reset_password_screen.dart';
import '../ui/features/auth/view_models/recovery_view_model.dart';
import '../domain/repositories/team_repository.dart';
import '../ui/features/team/view_models/team_view_model.dart';
import '../ui/features/team/view_models/accept_invitation_view_model.dart';
import '../ui/features/team/views/team_screen.dart';
import '../ui/features/team/views/invite_member_screen.dart';
import '../ui/features/team/views/accept_invitation_screen.dart';
import '../domain/repositories/adoption_contact_repository.dart';
import '../ui/features/adoption/view_models/adoption_contact_view_model.dart';
import '../ui/features/adoption/views/adoption_contact_screen.dart';
import '../ui/features/medications/view_models/medication_application_view_model.dart';
import '../ui/features/medications/views/medication_application_details_sheet.dart';
import '../ui/features/medications/view_models/medication_calendar_view_model.dart';
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
    this.contacts,
    this.team,
  });
  final TeamRepository? team;
  final AdoptionContactRepository? contacts;
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
      case '/recovery':
      case '/reset-password':
        if (auth == null) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const Scaffold(
              body: Center(child: Text('Serviço de acesso indisponível.')),
            ),
          );
        }
        if (settings.name == '/recovery') {
          final vm = RecoveryViewModel(auth!);
          return _page(settings, vm, RecoveryScreen(viewModel: vm));
        }
        final reset = ResetPasswordViewModel(auth!);
        reset.load();
        return _page(settings, reset, ResetPasswordScreen(viewModel: reset));
      case '/accept-invitation':
        if (team == null || auth == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Convite indisponível.')),
            ),
          );
        }
        final accepting = AcceptInvitationViewModel(team!, auth!);
        accepting.load();
        return _page(
          settings,
          accepting,
          AcceptInvitationScreen(viewModel: accepting),
        );
      case '/team':
      case '/team-invite':
      case '/login':
      case '/volunteer':
      case '/animal-editor':
      case '/animal-management':
      case '/medication-application':
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
            requireTeamAdministrator:
                settings.name == '/team' || settings.name == '/team-invite',
            privateBuilder: () {
              Future<bool>? accessCheck;
              Future<bool> authorize() {
                return accessCheck ??= (() async {
                  await access.revalidate();
                  return access.state.canAccessPrivate;
                })().whenComplete(() => accessCheck = null);
              }

              if (settings.name == '/team' || settings.name == '/team-invite') {
                if (team == null) {
                  return const Scaffold(
                    body: Center(child: Text('Equipe indisponível.')),
                  );
                }
                String contextKey() =>
                    '${access.state.userId}:${access.state.privateGeneration}';
                Future<bool> authorizeTeam() async {
                  await access.revalidate();
                  return access.state.canManageTeam;
                }

                if (settings.name == '/team-invite') {
                  final invite = InviteMemberViewModel(
                    team!,
                    canManage: () => access.state.canManageTeam,
                    authorize: authorizeTeam,
                    contextKey: contextKey,
                  );
                  return ChangeNotifierProvider(
                    create: (_) => invite,
                    lazy: false,
                    child: InviteMemberScreen(viewModel: invite),
                  );
                }
                final listing = TeamViewModel(
                  team!,
                  canManage: () => access.state.canManageTeam,
                  authorize: authorizeTeam,
                  contextKey: contextKey,
                  currentUserId: () => access.state.userId,
                );
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => listing.load(),
                );
                return ChangeNotifierProvider(
                  create: (_) => listing,
                  lazy: false,
                  child: TeamScreen(viewModel: listing),
                );
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

              if (settings.name == '/medication-application') {
                final id = settings.arguments;
                if (medications == null ||
                    id is! String ||
                    !isMedicationIdentifier(id)) {
                  return const Scaffold(
                    body: Center(child: Text('Aplicação indisponível.')),
                  );
                }
                late final MedicationApplicationViewModel application;
                application = MedicationApplicationViewModel(
                  medications!,
                  isAuthorized: () => access.state.canAccessPrivate,
                  accessEpoch: () => access.state.accessEpoch,
                  privateGeneration: () => access.state.privateGeneration,
                  authorize: authorize,
                  onDispose: () =>
                      access.removeListener(application.refreshAccess),
                );
                access.addListener(application.refreshAccess);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  unawaited(application.open(id));
                });
                return ChangeNotifierProvider<MedicationApplicationViewModel>(
                  create: (_) => application,
                  lazy: false,
                  child: MedicationApplicationDetailsSheet(
                    viewModel: application,
                  ),
                );
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
                MedicationCalendarViewModel? calendar;
                if (medications != null) {
                  late final MedicationCalendarViewModel calendarModel;
                  calendarModel = MedicationCalendarViewModel(
                    medications!,
                    isAuthorized: () => access.state.canAccessPrivate,
                    accessEpoch: () => access.state.accessEpoch,
                    privateGeneration: () => access.state.privateGeneration,
                    authorize: authorize,
                    onDispose: () =>
                        access.removeListener(calendarModel.refreshAccess),
                  );
                  access.addListener(calendarModel.refreshAccess);
                  calendar = calendarModel;
                }
                final listing = DashboardViewModel(
                  animals,
                  isAuthorized: () => access.state.canAccessPrivate,
                  accessEpoch: () => access.state.accessEpoch,
                  authorize: authorize,
                  onCalendarSelected: calendar?.initialize,
                  canManageTeam: () => access.state.canManageTeam,
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  listing.load();
                });
                return MultiProvider(
                  providers: [
                    ChangeNotifierProvider<DashboardViewModel>(
                      create: (_) => listing,
                      lazy: false,
                    ),
                    if (calendar != null)
                      ChangeNotifierProvider<MedicationCalendarViewModel>(
                        create: (_) => calendar!,
                        lazy: false,
                      ),
                  ],
                  child: DashboardScreen(
                    viewModel: listing,
                    calendarViewModel: calendar,
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
      case '/adoption-contact':
        final repository = contacts;
        if (repository == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Serviço de contato não configurado.')),
            ),
          );
        }
        final vm = AdoptionContactViewModel(animals, repository);
        vm.load(
          settings.arguments is String ? settings.arguments as String : '',
        );
        return _page(settings, vm, AdoptionContactScreen(viewModel: vm));
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
