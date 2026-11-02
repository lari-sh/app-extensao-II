import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../view_models/managed_animal_search_view_model.dart';

class ManagedAnimalSearchPanel extends StatelessWidget {
  const ManagedAnimalSearchPanel({
    super.key,
    required this.viewModel,
    required this.onOpen,
    required this.modeLabel,
  });
  final ManagedAnimalSearchViewModel viewModel;
  final ValueChanged<String> onOpen;
  final String modeLabel;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => ListView(
      key: ValueKey(viewModel.state.filter),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
      children: [
        const Text(
          'Resultados da busca',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'serif',
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Todos os animais do abrigo. $modeLabel preservado ao limpar.',
          style: const TextStyle(fontSize: 11),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                viewModel.countLabel,
                style: const TextStyle(fontSize: 11),
              ),
            ),
            TextButton(
              onPressed: viewModel.clearAll,
              child: const Text('Limpar busca'),
            ),
          ],
        ),
        if (viewModel.state.loading || viewModel.state.loadingMore)
          const LinearProgressIndicator(),
        if (viewModel.state.message != null) ...[
          Text(viewModel.state.message!),
          TextButton(
            onPressed: () => viewModel.search(),
            child: const Text('Tentar novamente'),
          ),
        ],
        if (!viewModel.state.loading &&
            viewModel.state.message == null &&
            viewModel.state.items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                Text(
                  'Nenhum animal encontrado',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tente outro nome ou código, ou remova filtros para ampliar a busca.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        for (final item in viewModel.state.items)
          Card(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFEADDD7)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: SizedBox(
                          width: 68,
                          height: 84,
                          child: viewModel.state.photos[item.animal.id] == null
                              ? const ColoredBox(
                                  color: Color(0xFFF6EAE5),
                                  child: Icon(Icons.pets),
                                )
                              : Image.memory(
                                  Uint8List.fromList(
                                    viewModel.state.photos[item.animal.id]!,
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.pets),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 8,
                                children: [
                                  Text(
                                    item.animal.name,
                                    style: const TextStyle(
                                      fontSize: 21,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF6EAE5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '#${item.animal.animalCode}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              viewModel.subtitle(item.animal),
                              style: const TextStyle(fontSize: 10),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6EAE5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                viewModel.statusLabel(item.animal),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFC51D2A),
                                ),
                              ),
                            ),
                            Text(
                              viewModel.publicationLabel(item.animal),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.animal.approximateAge,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                      Flexible(
                        child: TextButton(
                          onPressed: viewModel.canSearch
                              ? () => onOpen(item.animal.id)
                              : null,
                          child: const Text('Abrir ficha ›'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (viewModel.canLoadMore)
          TextButton(
            onPressed: () => viewModel.search(next: true),
            child: const Text('Carregar mais animais'),
          ),
      ],
    ),
  );
}
