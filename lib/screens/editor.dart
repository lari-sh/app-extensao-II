import 'package:flutter/material.dart';
import '../data/animal_store.dart';
import '../models/animal.dart';
import '../widgets/animal_tile.dart';

class AnimalEditor extends StatefulWidget {
  const AnimalEditor({super.key, required this.store, this.animal});
  final AnimalStore store;
  final Animal? animal;
  @override
  State<AnimalEditor> createState() => _AnimalEditorState();
}

class _AnimalEditorState extends State<AnimalEditor> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.animal?.name);
  late final age = TextEditingController(text: widget.animal?.age);
  late final history = TextEditingController(text: widget.animal?.history);
  late String species = widget.animal?.species ?? 'Cachorro';
  late String sex = widget.animal?.sex ?? 'Fêmea';
  late String size = widget.animal?.size ?? 'Médio';
  late AnimalStatus status = widget.animal?.status ?? AnimalStatus.available;
  late bool vaccinated = widget.animal?.vaccinated ?? false;
  late bool neutered = widget.animal?.neutered ?? false;
  late final vaccines = List<String>.of(widget.animal?.vaccines ?? []);
  late final deworming = List<String>.of(widget.animal?.deworming ?? []);
  late final medications = List<String>.of(widget.animal?.medications ?? []);
  bool saving = false;
  @override
  void dispose() {
    name.dispose();
    age.dispose();
    history.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await widget.store.save(
        Animal(
          id: widget.animal?.id ?? 'A${DateTime.now().microsecondsSinceEpoch}',
          name: name.text.trim(),
          species: species,
          sex: sex,
          size: size,
          age: age.text.trim(),
          status: status,
          history: history.text.trim(),
          vaccinated: vaccinated,
          neutered: neutered,
          vaccines: List.of(vaccines),
          deworming: List.of(deworming),
          medications: List.of(medications),
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        showStorageError(context);
        setState(() => saving = false);
      }
    }
  }

  Future<void> addRecord(String label, List<String> list) async {
    String value = '';
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adicionar $label'),
        content: TextField(
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Descrição, dose e datas (exemplo)',
          ),
          onChanged: (text) => value = text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (value.trim().isNotEmpty) Navigator.pop(context, value.trim());
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    if (result != null && mounted) setState(() => list.add(result));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.animal == null
            ? 'Adicionar animal'
            : 'Editar ${widget.animal!.name}',
      ),
    ),
    body: AbsorbPointer(
      absorbing: saving,
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Cadastro de demonstração · somente neste dispositivo'),
            const SizedBox(height: 20),
            field(name, 'Nome'),
            const SizedBox(height: 16),
            dropdown('Espécie', species, [
              'Cachorro',
              'Gato',
            ], (v) => species = v),
            dropdown('Sexo', sex, ['Fêmea', 'Macho'], (v) => sex = v),
            dropdown('Porte', size, [
              'Pequeno',
              'Médio',
              'Grande',
            ], (v) => size = v),
            field(age, 'Idade aproximada', hint: 'Ex.: 2 anos'),
            const SizedBox(height: 16),
            DropdownButtonFormField<AnimalStatus>(
              initialValue: status,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Status de manejo'),
              items: AnimalStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (v) => setState(() => status = v!),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Vacinado'),
              value: vaccinated,
              onChanged: (v) => setState(() => vaccinated = v),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Castrado'),
              value: neutered,
              onChanged: (v) => setState(() => neutered = v),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: history,
              minLines: 3,
              maxLines: 6,
              maxLength: 3000,
              decoration: const InputDecoration(
                labelText: 'História e observações',
              ),
            ),
            records('vacina', 'Vacinação', vaccines),
            records('vermifugação', 'Vermifugação', deworming),
            records('medicação', 'Medicações', medications),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: saving ? null : save,
              child: Text(saving ? 'Salvando…' : 'Salvar cadastro'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: saving ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    ),
  );

  Widget field(
    TextEditingController controller,
    String label, {
    String? hint,
  }) => TextFormField(
    controller: controller,
    maxLength: 80,
    decoration: InputDecoration(labelText: label, hintText: hint),
    validator: (v) => v == null || v.trim().isEmpty ? 'Preencha $label' : null,
  );
  Widget dropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> change,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: values
          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
          .toList(),
      onChanged: (v) => setState(() => change(v!)),
    ),
  );
  Widget records(String singular, String title, List<String> list) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      if (list.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text('Nenhum registro adicionado.'),
        ),
      ...list.asMap().entries.map(
        (entry) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(entry.value),
          trailing: IconButton(
            tooltip: 'Remover ${entry.value}',
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => list.removeAt(entry.key)),
          ),
        ),
      ),
      TextButton.icon(
        onPressed: () => addRecord(singular, list),
        icon: const Icon(Icons.add),
        label: Text('Adicionar $singular'),
      ),
    ],
  );
}
