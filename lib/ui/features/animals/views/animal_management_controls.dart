import 'package:flutter/material.dart';
import '../../../../domain/models/animal.dart';
import '../view_models/dashboard_view_model.dart';

class AnimalManagementControls extends StatelessWidget {
  const AnimalManagementControls({super.key, required this.viewModel});
  final DashboardViewModel viewModel;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Status de manejo clínico',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AnimalStatus>(
          key: ValueKey(viewModel.focusedStatus),
          initialValue: viewModel.focusedStatus,
          decoration: const InputDecoration(labelText: 'Situação'),
          items: DashboardViewModel.labels.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: viewModel.canManageFocused
              ? (value) {
                  if (value != null) {
                    viewModel.setFocusedStatus(value);
                  }
                }
              : null,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Publicado no catálogo'),
          value: viewModel.focusedPublished,
          onChanged: viewModel.canPublishFocused
              ? viewModel.setFocusedPublication
              : null,
        ),
        if (viewModel.state.focusedAnimal == null && !viewModel.state.loading)
          const Text('Salve o animal para gerenciar situação e publicação.'),
        if (viewModel.state.loading || viewModel.state.busy)
          const LinearProgressIndicator(),
        if (viewModel.state.message != null) Text(viewModel.state.message!),
        if (viewModel.state.uncertain)
          TextButton(
            onPressed: viewModel.state.busy ? null : viewModel.reconcile,
            child: const Text('Consultar resultado'),
          ),
        if (viewModel.state.canRetry)
          TextButton(
            onPressed: viewModel.retry,
            child: const Text('Tentar novamente'),
          ),
        const SizedBox(height: 16),
      ],
    ),
  );
}
