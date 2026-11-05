import '../../auth/view_models/session_view_model.dart';
import 'package:flutter/material.dart';
import '../view_models/home_view_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.viewModel, this.session});
  final HomeViewModel viewModel;
  final SessionViewModel? session;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 220,
                        height: 220,
                        semanticLabel: 'Abrigo dos Anjos — Humanizando Vidas',
                      ),
                      const SizedBox(height: 26),
                      Text(
                        viewModel.history,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        viewModel.rescues,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 26),
                      const Text(
                        'Escolha como entrar:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            viewModel.openCatalog(),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(child: Text('Quero Adotar (Visitante)')),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF45180D),
                            side: const BorderSide(color: Color(0xFFEADDD7)),
                          ),
                          onPressed: () => Navigator.pushNamed(
                            context,
                            viewModel.openVolunteer(),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text('Acesso Voluntário / Funcionário'),
                              ),
                              Icon(Icons.lock_outline, size: 18),
                            ],
                          ),
                        ),
                      ),
                      if (session != null)
                        ListenableBuilder(
                          listenable: session!,
                          builder: (context, _) =>
                              session!.state.message == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(session!.state.message!),
                                ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
