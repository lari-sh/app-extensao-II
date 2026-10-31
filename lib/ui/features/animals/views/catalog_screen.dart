import 'package:flutter/material.dart';
import '../view_models/catalog_view_model.dart';
import '../../../core/widgets/public_animal_list.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.viewModel});
  final CatalogViewModel viewModel;
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final _search = TextEditingController(
    text: widget.viewModel.state.query.name,
  );
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Widget _filter(
    String key,
    String value,
    Map<String, String> options,
    ValueChanged<String> change,
  ) => DropdownButton<String>(
    key: ValueKey(key),
    value: value,
    isExpanded: true,
    items: options.entries
        .map(
          (item) => DropdownMenuItem(value: item.key, child: Text(item.value)),
        )
        .toList(),
    onChanged: (value) {
      if (value != null) change(value);
    },
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Encontre seu novo amigo'),
      actions: [
        IconButton(
          tooltip: 'Favoritos',
          onPressed: () => Navigator.pushNamed(context, '/favorites').then((_) {
            widget.viewModel.load();
          }),
          icon: const Icon(Icons.favorite_outline),
        ),
      ],
    ),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              key: const ValueKey('catalogSearch'),
              controller: _search,
              decoration: const InputDecoration(
                labelText: 'Buscar por nome',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => widget.viewModel.setFilters(name: value),
            ),
            const SizedBox(height: 12),
            _filter(
              'speciesFilter',
              widget.viewModel.speciesValue,
              widget.viewModel.speciesOptions,
              (value) => widget.viewModel.setFilters(species: value),
            ),
            Row(
              children: [
                Expanded(
                  child: _filter(
                    'sexFilter',
                    widget.viewModel.sexValue,
                    widget.viewModel.sexOptions,
                    (value) => widget.viewModel.setFilters(sex: value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _filter(
                    'sizeFilter',
                    widget.viewModel.sizeValue,
                    widget.viewModel.sizeOptions,
                    (value) => widget.viewModel.setFilters(size: value),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  _search.clear();
                  widget.viewModel.clearFilters();
                },
                child: const Text('Limpar filtros'),
              ),
            ),
            Text(
              '${widget.viewModel.state.total} animais encontrados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            PublicAnimalList(
              viewModel: widget.viewModel,
              emptyMessage: 'Nenhum animal encontrado. Tente outros filtros.',
            ),
          ],
        ),
      ),
    ),
  );
}
