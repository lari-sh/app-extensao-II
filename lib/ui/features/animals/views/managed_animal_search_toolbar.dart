import 'package:flutter/material.dart';
import '../view_models/managed_animal_search_view_model.dart';
import 'managed_animal_search_filters_sheet.dart';

class ManagedAnimalSearchToolbar extends StatefulWidget {
  const ManagedAnimalSearchToolbar({super.key, required this.viewModel});
  final ManagedAnimalSearchViewModel viewModel;
  @override
  State<ManagedAnimalSearchToolbar> createState() =>
      _ManagedAnimalSearchToolbarState();
}

class _ManagedAnimalSearchToolbarState
    extends State<ManagedAnimalSearchToolbar> {
  late final TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.viewModel.queryInput);
    widget.viewModel.addListener(_sync);
  }

  void _sync() {
    final text = widget.viewModel.queryInput;
    if (_controller.text != text) {
      _controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_sync);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.viewModel,
    builder: (context, _) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Buscar em todo o abrigo', style: TextStyle(fontSize: 11)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('management-search'),
                  controller: _controller,
                  enabled: widget.viewModel.canSearch,
                  textInputAction: TextInputAction.search,
                  maxLength: 80,
                  onChanged: widget.viewModel.setQuery,
                  onSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                    widget.viewModel.submitQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Nome ou código do animal',
                    hintMaxLines: 1,
                    counterText: '',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: widget.viewModel.queryInput.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpar texto',
                            onPressed: widget.viewModel.clearText,
                            icon: const Icon(Icons.close),
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: widget.viewModel.canSearch
                    ? () => showManagedAnimalFilters(context, widget.viewModel)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune, size: 20),
                    Text('Filtros', style: TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          if (widget.viewModel.chips.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final chip in widget.viewModel.chips.entries)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: InputChip(
                        label: Text(chip.value),
                        onDeleted: () =>
                            widget.viewModel.removeFilter(chip.key),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
