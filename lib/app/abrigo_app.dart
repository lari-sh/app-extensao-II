import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../ui/core/theme/app_theme.dart';

class AbrigoApp extends StatelessWidget {
  const AbrigoApp({
    super.key,
    this.home,
    this.onGenerateRoute,
    this.navigatorKey,
    this.navigatorObservers = const [],
  });
  final Widget? home;
  final GlobalKey<NavigatorState>? navigatorKey;
  final List<NavigatorObserver> navigatorObservers;
  final RouteFactory? onGenerateRoute;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Abrigo dos Anjos',
    navigatorKey: navigatorKey,
    navigatorObservers: navigatorObservers,
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: home,
    onGenerateRoute: onGenerateRoute,
  );
}
