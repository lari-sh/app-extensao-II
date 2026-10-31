import 'package:flutter/material.dart';
import '../data/animal_store.dart';
import '../theme.dart';
import 'catalog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.store});
  final AnimalStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              children: [
                const Text(
                  'UBERABA · MG',
                  style: TextStyle(letterSpacing: 3, color: brandBrown),
                ),
                const SizedBox(height: 24),
                Image.asset(
                  'assets/images/logo.png',
                  width: 250,
                  semanticLabel: 'Abrigo dos Anjos — Humanizando Vidas',
                ),
                const SizedBox(height: 24),
                Text(
                  'Todo anjo merece\num lar.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Transformando abandono em amor.\nConheça quem está à espera de uma família.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.6),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.pets),
                    label: const Text('Quero adotar'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => CatalogScreen(store: store),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.volunteer_activism_outlined),
                    label: const Text('Área do voluntário'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VolunteerScreen(store: store),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Versão inicial · animais de demonstração',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// Legacy entry retained only until T100; no administrative bypass remains.
class VolunteerScreen extends StatelessWidget {
  const VolunteerScreen({super.key, required this.store});
  final AnimalStore store;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Área do voluntário')),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Acesso de demonstração desativado. Use o login autorizado na versão atual do aplicativo.',
        ),
      ),
    ),
  );
}
