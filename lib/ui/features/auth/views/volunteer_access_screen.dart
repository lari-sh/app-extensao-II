import '../../../core/widgets/app_back_button.dart';
import 'package:flutter/material.dart';
import '../view_models/session_view_model.dart';

class VolunteerAccessScreen extends StatelessWidget {
  const VolunteerAccessScreen({super.key, required this.viewModel});
  final SessionViewModel viewModel;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: const AppBackButton(),
      title: const Text('Área do voluntário'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.verified_user, size: 64),
        const SizedBox(height: 20),
        const Text('Acesso autorizado', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 12),
        const Text('Sua sessão de voluntário está ativa.'),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: () => Navigator.pushNamed(context, '/animal-management'),
          icon: const Icon(Icons.pets),
          label: const Text('Animais do abrigo'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: viewModel.signOut,
          child: const Text('Sair da conta'),
        ),
      ],
    ),
  );
}
