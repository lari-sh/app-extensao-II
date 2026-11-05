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
    text: widget.viewModel.searchInput,
  );
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_syncSearch);
  }

  void _syncSearch() {
    final text = widget.viewModel.searchInput;
    if (_search.text != text) {
      _search.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_syncSearch);
    _search.dispose();
    super.dispose();
  }

  Widget _filter(
    String key,
    String title,
    String value,
    Map<String, String> options,
    ValueChanged<String> change,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: value.isEmpty ? Colors.white : const Color(0xFFF6EAE5),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: const Color(0xFFEADDD7)),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        key: ValueKey(key),
        value: value,
        isDense: true,
        borderRadius: BorderRadius.circular(14),
        selectedItemBuilder: (context) => options.entries
            .map(
              (entry) => Text(
                entry.key.isEmpty ? title : entry.value,
                style: const TextStyle(fontSize: 12),
              ),
            )
            .toList(),
        items: options.entries
            .map(
              (entry) =>
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) change(value);
        },
      ),
    ),
  );
  Future<void> _open(String route) async {
    await Navigator.pushNamed(context, route);
    if (mounted) widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFEADDD7)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x163C2814), blurRadius: 16),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _nav(
              'Buscar',
              Icons.search,
              () => widget.viewModel.submitSearch(_search.text),
              selected: true,
            ),
            _nav(
              'Favoritos',
              Icons.favorite_outline,
              () => _open('/favorites'),
            ),
            _nav(
              'Início',
              Icons.home_outlined,
              () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
            _nav('Sobre', Icons.info_outline, () => _open('/about')),
          ],
        ),
      ),
    ),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          children: [
            Row(
              children: [
                IconButton.filledTonal(
                  tooltip: 'Voltar',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.chevron_left),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conheça nossos anjos',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              key: const ValueKey('catalogSearch'),
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'Nome, espécie ou sexo…',
                counterText: '',
                prefixIcon: Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.search,
              maxLength: 80,
              onChanged: widget.viewModel.setSearchInput,
              onSubmitted: (value) {
                FocusScope.of(context).unfocus();
                widget.viewModel.submitSearch(value);
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filter(
                      'speciesFilter',
                      'Espécie',
                      widget.viewModel.speciesValue,
                      widget.viewModel.speciesOptions,
                      (value) => widget.viewModel.submitSearch(
                        _search.text,
                        species: value,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _filter(
                      'sizeFilter',
                      'Porte',
                      widget.viewModel.sizeValue,
                      widget.viewModel.sizeOptions,
                      (value) => widget.viewModel.submitSearch(
                        _search.text,
                        size: value,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _filter(
                      'sexFilter',
                      'Sexo',
                      widget.viewModel.sexValue,
                      widget.viewModel.sexOptions,
                      (value) => widget.viewModel.submitSearch(
                        _search.text,
                        sex: value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '${widget.viewModel.state.total} animais encontrados',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _search.clear();
                    widget.viewModel.clearFilters();
                  },
                  child: const Text('Limpar filtros'),
                ),
              ],
            ),
            PublicAnimalList(
              viewModel: widget.viewModel,
              grid: true,
              emptyMessage: 'Nenhum animal encontrado. Tente outros filtros.',
            ),
          ],
        ),
      ),
    ),
  );
  Widget _nav(
    String label,
    IconData icon,
    VoidCallback action, {
    bool selected = false,
  }) => Expanded(
    child: TextButton(
      onPressed: action,
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? const Color(0xFFC51D2A)
            : const Color(0xFF795C52),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    ),
  );
}
