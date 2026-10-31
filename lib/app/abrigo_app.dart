import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../ui/core/theme/app_theme.dart';

class AbrigoApp extends StatelessWidget {
  const AbrigoApp({super.key, this.home, this.onGenerateRoute});
  final Widget? home;
  final RouteFactory? onGenerateRoute;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Abrigo dos Anjos',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: home,
    onGenerateRoute: onGenerateRoute,
  );
}
