import 'package:flutter/material.dart';
import '../data/animal_store.dart';
import '../models/animal.dart';
import '../theme.dart';
import '../widgets/animal_tile.dart';
import 'editor.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.store});
  final AnimalStore store;
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool listView = false;
  Future<void> move(Animal animal, AnimalStatus status) async {
    try {
      await widget.store.save(animal.withStatus(status));
    } catch (_) {
      if (mounted) showStorageError(context);
    }
  }

  void edit([Animal? animal]) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => AnimalEditor(store: widget.store, animal: animal),
    ),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.store,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: const Text('Painel de manejo')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => edit(),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar animal'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: softBackground,
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Demonstração local · sem autenticação · use somente dados fictícios',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cada cuidado conta.',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${widget.store.animals.length} animais cadastrados',
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: listView ? 'Mostrar Kanban' : 'Mostrar lista',
                  onPressed: () => setState(() => listView = !listView),
                  icon: Icon(
                    listView
                        ? Icons.view_kanban_outlined
                        : Icons.view_list_outlined,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: listView
                ? ListView(
                    padding: const EdgeInsets.only(bottom: 100),
                    children: widget.store.animals.map(card).toList(),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) => ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      children: AnimalStatus.values.map((status) {
                        final animals = widget.store.animals
                            .where((a) => a.status == status)
                            .toList();
                        return SizedBox(
                          width: constraints.maxWidth < 600
                              ? constraints.maxWidth * .82
                              : 300,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: DragTarget<Animal>(
                              onWillAcceptWithDetails: (details) =>
                                  details.data.status != status,
                              onAcceptWithDetails: (details) =>
                                  move(details.data, status),
                              builder: (context, candidates, rejected) => Container(
                                decoration: BoxDecoration(
                                  color: candidates.isEmpty
                                      ? softBackground
                                      : brandRed.withValues(alpha: .15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              status.label,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: Colors.white,
                                            child: Text(
                                              '${animals.length}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: animals.isEmpty
                                          ? const Center(
                                              child: Text('Nenhum animal aqui'),
                                            )
                                          : ListView(
                                              children: animals
                                                  .map(
                                                    (
                                                      animal,
                                                    ) => LongPressDraggable<Animal>(
                                                      data: animal,
                                                      feedback: Material(
                                                        elevation: 6,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        child: SizedBox(
                                                          width: 240,
                                                          child: ListTile(
                                                            leading: const Icon(
                                                              Icons.pets,
                                                            ),
                                                            title: Text(
                                                              animal.name,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      childWhenDragging:
                                                          Opacity(
                                                            opacity: .4,
                                                            child: card(animal),
                                                          ),
                                                      child: card(animal),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    ),
  );

  Widget card(Animal animal) => Card(
    margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
    child: ListTile(
      onTap: () => edit(animal),
      leading: const Icon(Icons.pets, color: brandBrown),
      title: Text(animal.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('#${animal.id} · ${animal.age}'),
          const SizedBox(height: 6),
          StatusBadge(status: animal.status),
        ],
      ),
      isThreeLine: true,
      trailing: PopupMenuButton<AnimalStatus>(
        tooltip: 'Alterar status de ${animal.name}',
        onSelected: (status) => move(animal, status),
        itemBuilder: (_) => AnimalStatus.values
            .map((s) => PopupMenuItem(value: s, child: Text(s.label)))
            .toList(),
      ),
    ),
  );
}
