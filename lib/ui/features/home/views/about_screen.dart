import 'package:flutter/material.dart';
import '../view_models/about_view_model.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, required this.viewModel});
  final AboutViewModel viewModel;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(viewModel.title)),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Image.asset('assets/images/logo.png', height: 140),
        const SizedBox(height: 24),
        Text(viewModel.body, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => Navigator.popUntil(
            context,
            ModalRoute.withName(viewModel.close()),
          ),
          child: const Text('Voltar ao início'),
        ),
      ],
    ),
  );
}
