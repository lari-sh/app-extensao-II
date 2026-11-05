import '../../../core/view_models/public_list_view_model.dart';

class CatalogViewModel extends PublicListViewModel {
  CatalogViewModel(super.animals, super.favorites, super.photos);
  String _searchInput = '';
  String get searchInput => _searchInput;
  bool _closed = false;
  void setSearchInput(String value) {
    if (!_closed) _searchInput = value;
  }

  static const _species = {
    'gato': 'cat',
    'gata': 'cat',
    'gatos': 'cat',
    'gatas': 'cat',
    'cachorro': 'dog',
    'cachorra': 'dog',
    'cachorros': 'dog',
    'cachorras': 'dog',
    'cao': 'dog',
    'caes': 'dog',
    'cadela': 'dog',
    'cadelas': 'dog',
  };
  static const _sex = {
    'macho': 'male',
    'machos': 'male',
    'femea': 'female',
    'femeas': 'female',
  };
  String _fold(String text) {
    var result = text.toLowerCase();
    const accents = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'é': 'e',
      'ê': 'e',
      'í': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ç': 'c',
    };
    for (final entry in accents.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  Future<void> submitSearch(
    String input, {
    String? species,
    String? sex,
    String? size,
  }) async {
    if (_closed) return;
    _searchInput = input;
    if (input.length > 80) {
      rejectSearch('Use no máximo 80 caracteres na busca.');
      return;
    }
    final speciesFound = <String>{}, sexFound = <String>{};
    final name = <String>[];
    for (final token in input.trim().split(RegExp(r'\s+'))) {
      final normalized = _fold(token);
      if (_species.containsKey(normalized)) {
        speciesFound.add(_species[normalized]!);
      } else if (_sex.containsKey(normalized)) {
        sexFound.add(_sex[normalized]!);
      } else if (token.isNotEmpty) {
        name.add(token);
      }
    }
    if (speciesFound.length > 1 || sexFound.length > 1) {
      rejectSearch('Informe apenas uma espécie e um sexo por busca.');
      return;
    }
    _searchInput = name.join(' ');
    await super.setFilters(
      name: _searchInput,
      species: species ?? speciesFound.firstOrNull,
      sex: sex ?? sexFound.firstOrNull,
      size: size,
    );
  }

  @override
  Future<void> clearFilters() {
    _searchInput = '';
    return super.clearFilters();
  }

  @override
  void dispose() {
    _closed = true;
    super.dispose();
  }
}
