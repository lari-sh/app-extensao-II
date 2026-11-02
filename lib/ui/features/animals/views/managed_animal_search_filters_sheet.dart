import 'package:flutter/material.dart';
import '../view_models/managed_animal_search_view_model.dart';

Future<void> showManagedAnimalFilters(
  BuildContext context,
  ManagedAnimalSearchViewModel vm,
) async {
  vm.beginFilters();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => ListenableBuilder(
      listenable: vm,
      builder: (context, _) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Cancelar filtros',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                ),
                const Expanded(
                  child: Text(
                    'Filtrar animais',
                    style: TextStyle(fontSize: 22, fontFamily: 'serif'),
                  ),
                ),
              ],
            ),
            _options(
              'Espécie',
              vm.state.draft.species,
              ManagedAnimalSearchViewModel.speciesLabels,
              (value) =>
                  vm.updateDraft(vm.state.draft.copyWith(species: value)),
            ),
            _options(
              'Sexo',
              vm.state.draft.sex,
              ManagedAnimalSearchViewModel.sexLabels,
              (value) => vm.updateDraft(vm.state.draft.copyWith(sex: value)),
            ),
            TextFormField(
              initialValue: vm.state.draft.color,
              maxLength: 80,
              decoration: const InputDecoration(
                labelText: 'Cor',
                hintText: 'Ex.: preto',
              ),
              onChanged: (value) =>
                  vm.updateDraft(vm.state.draft.copyWith(color: value)),
            ),
            _options(
              'Porte',
              vm.state.draft.size,
              ManagedAnimalSearchViewModel.sizeLabels,
              (value) => vm.updateDraft(vm.state.draft.copyWith(size: value)),
            ),
            _options(
              'Situação',
              vm.state.draft.status,
              ManagedAnimalSearchViewModel.statusLabels,
              (value) => vm.updateDraft(vm.state.draft.copyWith(status: value)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                vm.applyFilters();
                Navigator.pop(context);
              },
              child: const Text('Aplicar filtros'),
            ),
            TextButton(
              onPressed: () {
                vm.clearFilters();
                Navigator.pop(context);
              },
              child: const Text('Limpar filtros'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    ),
  );
  vm.cancelFilters();
}

Widget _options<T>(
  String label,
  T? value,
  Map<T, String> options,
  ValueChanged<T?> onChanged,
) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: DropdownButtonFormField<T>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      DropdownMenuItem<T>(value: null, child: const Text('Todos')),
      for (final entry in options.entries)
        DropdownMenuItem(value: entry.key, child: Text(entry.value)),
    ],
    onChanged: onChanged,
  ),
);
