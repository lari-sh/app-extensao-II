import 'package:flutter/material.dart';
import '../data/animal_store.dart';
import '../models/animal.dart';
import '../widgets/animal_tile.dart';
import 'detail.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.store});
  final AnimalStore store;
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String query = '', species = 'Todos', size = 'Todos', sex = 'Todos';
  int destination = 0;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) {
      final animals = widget.store.animals
          .where((a) => a.status != AnimalStatus.adopted)
          .where(
            (a) => a.name.toLowerCase().contains(query.toLowerCase().trim()),
          )
          .where((a) => species == 'Todos' || a.species == species)
          .where((a) => size == 'Todos' || a.size == size)
          .where((a) => sex == 'Todos' || a.sex == sex)
          .where(
            (a) => destination != 1 || widget.store.favorites.contains(a.id),
          )
          .toList();
      return Scaffold(
        appBar: AppBar(
          title: Text(
            destination == 1 ? 'Meus favoritos' : 'Conheça nossos anjos',
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: destination,
          onDestinationSelected: (value) => setState(() => destination = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: Icon(Icons.info_outline),
              label: 'Sobre',
            ),
          ],
        ),
        body: destination == 2
            ? const _About()
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar pelo nome',
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => setState(() => query = value),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        filter('Espécie', species, [
                          'Todos',
                          'Cachorro',
                          'Gato',
                        ], (v) => species = v),
                        filter('Porte', size, [
                          'Todos',
                          'Pequeno',
                          'Médio',
                          'Grande',
                        ], (v) => size = v),
                        filter('Sexo', sex, [
                          'Todos',
                          'Fêmea',
                          'Macho',
                        ], (v) => sex = v),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '${animals.length} animais · dados de demonstração',
                    ),
                  ),
                  Expanded(
                    child: animals.isEmpty
                        ? const Center(child: Text('Nenhum anjo encontrado.'))
                        : LayoutBuilder(
                            builder: (context, constraints) => GridView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: constraints.maxWidth > 650
                                        ? 3
                                        : 2,
                                    mainAxisExtent: 280,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                              itemCount: animals.length,
                              itemBuilder: (context, index) {
                                final animal = animals[index];
                                return Card(
                                  clipBehavior: Clip.antiAlias,
                                  margin: EdgeInsets.zero,
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => DetailScreen(
                                          store: widget.store,
                                          animalId: animal.id,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            AnimalPortrait(animal: animal),
                                            Positioned(
                                              right: 2,
                                              top: 2,
                                              child: IconButton.filledTonal(
                                                tooltip:
                                                    'Favoritar ${animal.name}',
                                                icon: Icon(
                                                  widget.store.favorites
                                                          .contains(animal.id)
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                ),
                                                onPressed: () async {
                                                  try {
                                                    await widget.store
                                                        .toggleFavorite(
                                                          animal.id,
                                                        );
                                                  } catch (_) {
                                                    if (context.mounted) {
                                                      showStorageError(context);
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                animal.name,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleLarge,
                                              ),
                                              Text(
                                                '${animal.species} · ${animal.age}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              StatusBadge(
                                                status: animal.status,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
      );
    },
  );

  Widget filter(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> change,
  ) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: PopupMenuButton<String>(
      initialValue: value,
      onSelected: (v) => setState(() => change(v)),
      itemBuilder: (_) =>
          options.map((v) => PopupMenuItem(value: v, child: Text(v))).toList(),
      child: Chip(
        label: Text('$label: $value'),
        avatar: const Icon(Icons.expand_more, size: 18),
      ),
    ),
  );
}

class _About extends StatelessWidget {
  const _About();
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      Image.asset('assets/images/logo.png', height: 220),
      const SizedBox(height: 24),
      Text(
        'Humanizando vidas.',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 16),
      const Text(
        'Um espaço para aproximar animais resgatados de novas famílias e apoiar '
        'o trabalho de quem cuida deles.\n\nUberaba · Minas Gerais\n\n'
        'Esta primeira versão usa animais fictícios e ilustrações provisórias. '
        'Os canais oficiais de adoção serão cadastrados pelo abrigo.',
      ),
    ],
  );
}
