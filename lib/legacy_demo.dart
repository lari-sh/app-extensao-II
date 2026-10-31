import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/animal_store.dart';
import 'screens/home.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AbrigoApp(store: AnimalStore(SharedPreferencesAsync())));
}

class AbrigoApp extends StatelessWidget {
  const AbrigoApp({super.key, required this.store});
  final AnimalStore store;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Abrigo dos Anjos',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: Startup(store: store),
  );
}

class Startup extends StatefulWidget {
  const Startup({super.key, required this.store});
  final AnimalStore store;
  @override
  State<Startup> createState() => _StartupState();
}

class _StartupState extends State<Startup> {
  late Future<void> loading = widget.store.load();
  @override
  Widget build(BuildContext context) => FutureBuilder<void>(
    future: loading,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Não foi possível carregar os dados locais.'),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => setState(() {
                      loading = widget.store.load();
                    }),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return HomeScreen(store: widget.store);
    },
  );
}
