import '../ui/features/auth/view_models/auth_callback_view_model.dart';
import 'package:flutter/material.dart';
import '../ui/features/auth/view_models/session_view_model.dart';
import 'abrigo_app.dart';
import 'app_router.dart';

class PrivateRouteObserver extends NavigatorObserver {
  final routes = <Route<dynamic>>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routes.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    routes.remove(oldRoute);
    if (newRoute != null) routes.add(newRoute);
  }
}

class AuthApplication extends StatefulWidget {
  const AuthApplication({
    super.key,
    required this.session,
    required this.router,
    this.callbacks,
  });
  final AuthCallbackViewModel? callbacks;
  final SessionViewModel session;
  final AppRouter router;
  @override
  State<AuthApplication> createState() => _AuthApplicationState();
}

class _AuthApplicationState extends State<AuthApplication>
    with WidgetsBindingObserver {
  final _navigator = GlobalKey<NavigatorState>();
  final _observer = PrivateRouteObserver();
  late int _generation;
  @override
  void initState() {
    super.initState();
    _generation = widget.session.state.privateGeneration;
    widget.session.addListener(_changed);
    widget.callbacks?.addListener(_callback);
    WidgetsBinding.instance.addPostFrameCallback((_) => _callback());
    WidgetsBinding.instance.addObserver(this);
  }

  void _callback() {
    final route = widget.callbacks?.takeRoute();
    if (route == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _navigator.currentState?.pushNamedAndRemoveUntil(
          route,
          (r) => r.isFirst,
        );
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _changed() {
    final state = widget.session.state;
    if (state.privateGeneration == _generation) return;
    _generation = state.privateGeneration;
    if (state.canAccessPrivate || state.retainPrivate) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          widget.session.state.canAccessPrivate ||
          widget.session.state.retainPrivate) {
        return;
      }
      for (final route
          in _observer.routes
              .where(
                (route) => const {
                  '/team',
                  '/team-invite',
                  '/volunteer',
                  '/animal-editor',
                  '/animal-management',
                  '/medication-editor',
                  '/medication-application',
                }.contains(route.settings.name),
              )
              .toList()
              .reversed) {
        _navigator.currentState?.removeRoute(route);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.session.revalidate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.session.removeListener(_changed);
    widget.callbacks?.removeListener(_callback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AbrigoApp(
    navigatorKey: _navigator,
    navigatorObservers: [_observer],
    onGenerateRoute: widget.router.onGenerateRoute,
  );
}
