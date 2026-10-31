import '../../auth/view_models/session_view_model.dart';
import 'package:flutter/material.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel, this.session});
  final HomeViewModel viewModel;
  final SessionViewModel? session;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(viewModel.title)),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/images/logo.png', height: 135),
                const SizedBox(height: 28),
                Text(
                  viewModel.headline,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  viewModel.body,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, viewModel.openCatalog()),
                  icon: const Icon(Icons.pets),
                  label: const Text('Quero adotar'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, viewModel.openFavorites()),
                  icon: const Icon(Icons.favorite_outline),
                  label: const Text('Favoritos'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, viewModel.openVolunteer()),
                  icon: const Icon(Icons.volunteer_activism),
                  label: const Text('Área do voluntário'),
                ),
                if (session != null)
                  ListenableBuilder(
                    listenable: session!,
                    builder: (context, _) => session!.state.message == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(session!.state.message!),
                          ),
                  ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, viewModel.openAbout()),
                  child: const Text('Sobre o abrigo'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
