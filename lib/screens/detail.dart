import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/animal_store.dart';
import '../models/animal.dart';
import '../widgets/animal_tile.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.store, required this.animalId});
  final AnimalStore store;
  final String animalId;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) {
      final animal = store.animals.firstWhere((a) => a.id == animalId);
      return Scaffold(
        appBar: AppBar(
          title: Text(animal.name),
          actions: [
            IconButton(
              tooltip: 'Favoritar ${animal.name}',
              icon: Icon(
                store.favorites.contains(animal.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              onPressed: () async {
                try {
                  await store.toggleFavorite(animal.id);
                } catch (_) {
                  if (context.mounted) showStorageError(context);
                }
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AnimalPortrait(animal: animal, height: 250),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    animal.name,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                StatusBadge(status: animal.status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                animal.species,
                animal.sex,
                animal.size,
                animal.age,
              ].map((text) => Chip(label: Text(text))).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              animal.history.isEmpty
                  ? 'História ainda não cadastrada.'
                  : animal.history,
              style: const TextStyle(height: 1.6, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Text('Cuidados', style: Theme.of(context).textTheme.titleLarge),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.vaccines_outlined),
              title: const Text('Vacinação'),
              subtitle: Text(
                animal.vaccinated ? 'Informada no cadastro' : 'A confirmar',
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.health_and_safety_outlined),
              title: const Text('Castração'),
              subtitle: Text(
                animal.neutered ? 'Informada no cadastro' : 'A confirmar',
              ),
            ),
            const SizedBox(height: 16),
            if (animal.status == AnimalStatus.available)
              FilledButton.icon(
                icon: const Icon(Icons.volunteer_activism_outlined),
                label: const Text('Tenho interesse em adotar'),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text('Um lar para ${animal.name}'),
                    content: const Text(
                      'O canal oficial do abrigo ainda será configurado. '
                      'Você pode copiar uma mensagem de interesse; nenhum pedido será enviado nesta versão.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Voltar'),
                      ),
                      FilledButton(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(
                              text:
                                  'Olá! Tenho interesse em conhecer ${animal.name} (#${animal.id}) para adoção.',
                            ),
                          );
                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mensagem copiada. Nenhum pedido foi enviado.',
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Copiar mensagem'),
                      ),
                    ],
                  ),
                ),
              ),
            if (animal.status != AnimalStatus.available)
              const Text(
                'Este animal ainda não está disponível para adoção. '
                'A equipe está cuidando dele com carinho.',
              ),
          ],
        ),
      );
    },
  );
}
