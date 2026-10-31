import 'package:flutter/material.dart';
import '../view_models/animal_detail_view_model.dart';
import '../../../core/widgets/animal_portrait.dart';
import '../../../core/widgets/status_badge.dart';

class AnimalDetailScreen extends StatelessWidget {
  const AnimalDetailScreen({super.key, required this.viewModel});
  final AnimalDetailViewModel viewModel;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: Text(viewModel.state.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (viewModel.state.busy) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Center(
              child: AnimalPortrait(
                bytes: viewModel.state.photo,
                label: viewModel.state.title,
                size: 220,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              viewModel.state.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(viewModel.state.characteristics),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(label: viewModel.state.statusLabel),
            ),
            const SizedBox(height: 16),
            Text(viewModel.state.description),
            const SizedBox(height: 24),
            if (viewModel.state.canAdopt)
              FilledButton.icon(
                onPressed: viewModel.state.copying
                    ? null
                    : viewModel.copyInterest,
                icon: const Icon(Icons.content_copy),
                label: const Text('Tenho interesse'),
              ),
            if (viewModel.state.message != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(viewModel.state.message!),
              ),
          ],
        ),
      ),
    ),
  );
}
