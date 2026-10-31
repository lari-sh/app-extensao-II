import 'package:flutter/material.dart';
import '../view_models/public_list_view_model.dart';
import 'animal_portrait.dart';
import 'status_badge.dart';

class PublicAnimalList extends StatelessWidget {
  const PublicAnimalList({
    super.key,
    required this.viewModel,
    required this.emptyMessage,
  });
  final PublicListViewModel viewModel;
  final String emptyMessage;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (viewModel.state.message != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            viewModel.state.message!,
            semanticsLabel: viewModel.state.message,
          ),
        ),
      if (viewModel.state.busy) const LinearProgressIndicator(),
      if (!viewModel.state.busy && viewModel.state.items.isEmpty)
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(emptyMessage, textAlign: TextAlign.center),
        ),
      ...viewModel.state.items.map(
        (item) => Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: InkWell(
            onTap: () =>
                Navigator.pushNamed(
                  context,
                  viewModel.detailRoute(item.id),
                  arguments: item.id,
                ).then((_) {
                  viewModel.load();
                }),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimalPortrait(bytes: item.photo, label: item.name, size: 86),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(item.description),
                        StatusBadge(label: item.statusLabel),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed:
                        viewModel.state.favoritesReady &&
                            !viewModel.state.updatingFavorites.contains(item.id)
                        ? () => viewModel.toggleFavorite(item.id)
                        : null,
                    tooltip: item.isFavorite
                        ? 'Remover ${item.name} dos favoritos'
                        : 'Favoritar ${item.name}',
                    icon: Icon(
                      item.isFavorite ? Icons.favorite : Icons.favorite_outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      if (viewModel.state.cursor != null)
        OutlinedButton(
          onPressed: viewModel.state.busy
              ? null
              : () => viewModel.load(next: true),
          child: const Text('Carregar mais'),
        ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: () => viewModel.load(),
        icon: const Icon(Icons.refresh),
        label: const Text('Atualizar'),
      ),
    ],
  );
}
