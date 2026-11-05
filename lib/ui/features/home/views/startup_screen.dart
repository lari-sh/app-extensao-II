import 'package:flutter/material.dart';
import '../view_models/startup_view_model.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key, required this.viewModel});
  final StartupViewModel viewModel;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Abrigo dos Anjos')),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', height: 140),
            const SizedBox(height: 24),
            Text(viewModel.state.message, textAlign: TextAlign.center),
          ],
        ),
      ),
    ),
  );
}
