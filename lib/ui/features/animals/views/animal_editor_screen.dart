import '../view_models/dashboard_view_model.dart';
import 'animal_management_controls.dart';
import '../../photos/view_models/photo_upload_view_model.dart';
import '../../photos/views/photo_upload_panel.dart';
import 'package:flutter/material.dart';
import '../../../../domain/models/animal.dart';
import '../../../../domain/models/clinical_record.dart';
import '../view_models/animal_editor_view_model.dart';

class AnimalEditorScreen extends StatelessWidget {
  const AnimalEditorScreen({
    super.key,
    required this.viewModel,
    this.photoViewModel,
    this.managementViewModel,
  });
  final PhotoUploadViewModel? photoViewModel;
  final DashboardViewModel? managementViewModel;
  final AnimalEditorViewModel viewModel;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final state = viewModel.state;
      final draft = state.draft;
      Widget field(
        String key,
        String label,
        String value,
        ValueChanged<String> onChanged, {
        String? error,
        int lines = 1,
      }) => KeyedSubtree(
        key: ValueKey(key),
        child: TextFormField(
          key: ValueKey(state.formVersion),
          initialValue: value,
          onChanged: onChanged,
          enabled: viewModel.canEdit,
          maxLines: lines,
          decoration: InputDecoration(
            labelText: label,
            errorText: state.errors[error],
          ),
        ),
      );
      Widget options<T>(
        String key,
        String label,
        T? value,
        Map<T, String> values,
        ValueChanged<T?> onChanged, {
        String? error,
      }) => KeyedSubtree(
        key: ValueKey(key),
        child: DropdownButtonFormField<T>(
          key: ValueKey(state.formVersion),
          initialValue: value,
          decoration: InputDecoration(
            labelText: label,
            errorText: state.errors[error],
          ),
          items: values.entries
              .map(
                (entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: viewModel.canEdit ? onChanged : null,
        ),
      );
      return Scaffold(
        appBar: AppBar(
          title: Text(draft.id == null ? 'Cadastrar animal' : 'Editar animal'),
        ),
        body: SafeArea(
          child: state.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(viewModel.publicationMessage),
                    if (managementViewModel != null)
                      AnimalManagementControls(viewModel: managementViewModel!),
                    const SizedBox(height: 16),
                    field(
                      'animalName',
                      'Nome',
                      draft.name,
                      viewModel.setName,
                      error: 'name',
                    ),
                    const SizedBox(height: 16),
                    field(
                      'animalAge',
                      'Idade aproximada',
                      draft.approximateAge,
                      viewModel.setAge,
                      error: 'approximateAge',
                    ),
                    const SizedBox(height: 16),
                    options(
                      'animalSpecies',
                      'Espécie',
                      draft.species,
                      {
                        AnimalSpecies.dog: 'Cachorro',
                        AnimalSpecies.cat: 'Gato',
                      },
                      viewModel.setSpecies,
                      error: 'species',
                    ),
                    const SizedBox(height: 16),
                    options(
                      'animalSex',
                      'Sexo',
                      draft.sex,
                      {AnimalSex.female: 'Fêmea', AnimalSex.male: 'Macho'},
                      viewModel.setSex,
                      error: 'sex',
                    ),
                    const SizedBox(height: 16),
                    options(
                      'animalSize',
                      'Porte',
                      draft.size,
                      {
                        AnimalSize.small: 'Pequeno',
                        AnimalSize.medium: 'Médio',
                        AnimalSize.large: 'Grande',
                      },
                      viewModel.setSize,
                      error: 'size',
                    ),
                    const SizedBox(height: 16),
                    field(
                      'animalDescription',
                      'Descrição pública',
                      draft.publicDescription,
                      viewModel.setDescription,
                      error: 'publicDescription',
                      lines: 3,
                    ),
                    const SizedBox(height: 16),
                    field(
                      'animalNotes',
                      'Notas internas',
                      draft.clinicalNotes,
                      viewModel.setNotes,
                      error: 'clinicalNotes',
                      lines: 3,
                    ),
                    const Text(
                      'Informações públicas',
                      style: TextStyle(fontSize: 20),
                    ),
                    const Text(
                      'Peso, cor, castração e temperamento aparecem na ficha pública. Vermifugação mostra somente a data; vacinação mostra data e tipo. Notas internas permanecem privadas.',
                    ),
                    const SizedBox(height: 16),
                    field(
                      'animalWeight',
                      'Peso (kg)',
                      viewModel.weightText,
                      viewModel.setWeight,
                      error: 'weightKg',
                    ),
                    const SizedBox(height: 16),
                    field(
                      'animalColor',
                      'Cor',
                      draft.color ?? '',
                      viewModel.setColor,
                      error: 'color',
                    ),
                    const SizedBox(height: 16),
                    field(
                      'animalTemperament',
                      'Temperamento (público)',
                      draft.temperament ?? '',
                      viewModel.setTemperament,
                      error: 'temperament',
                    ),
                    const SizedBox(height: 16),
                    field(
                      'animalLastDewormedOn',
                      'Última vermifugação aplicada (DD/MM/AAAA)',
                      viewModel.dewormingDateText,
                      viewModel.setLastDewormedOn,
                      error: 'lastDewormedOn',
                    ),
                    const SizedBox(height: 16),
                    for (
                      var index = 0;
                      index < draft.vaccinations.length;
                      index++
                    )
                      Column(
                        children: [
                          field(
                            'vaccinationDate$index',
                            'Data da vacina (DD/MM/AAAA)',
                            viewModel.vaccinationDateText(index),
                            (text) => viewModel.setVaccinationDate(index, text),
                            error: 'vaccinations.$index.appliedOn',
                          ),
                          const SizedBox(height: 16),
                          field(
                            'vaccineType$index',
                            'Tipo de vacina',
                            draft.vaccinations[index].vaccineType,
                            (text) => viewModel.setVaccineType(index, text),
                            error: 'vaccinations.$index.vaccineType',
                          ),
                          TextButton(
                            onPressed: viewModel.canEdit
                                ? () => viewModel.removeVaccination(index)
                                : null,
                            child: const Text('Remover vacina'),
                          ),
                        ],
                      ),
                    TextButton.icon(
                      onPressed: viewModel.canEdit
                          ? viewModel.addVaccination
                          : null,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar vacina'),
                    ),
                    SwitchListTile(
                      title: const Text('Vacinado'),
                      value: draft.isVaccinated,
                      onChanged: viewModel.canEdit
                          ? viewModel.setVaccinated
                          : null,
                    ),
                    SwitchListTile(
                      title: const Text('Castrado'),
                      value: draft.isNeutered,
                      onChanged: viewModel.canEdit
                          ? viewModel.setNeutered
                          : null,
                    ),
                    const Text(
                      'Cuidados registrados',
                      style: TextStyle(fontSize: 20),
                    ),
                    const Text('Registros descritivos da equipe do abrigo.'),
                    for (
                      var index = 0;
                      index < draft.careRecords.length;
                      index++
                    )
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        key: ValueKey(draft.careRecords[index].id),
                        child: Column(
                          children: [
                            options(
                              'careKind$index',
                              'Tipo de cuidado',
                              draft.careRecords[index].kind,
                              {
                                ClinicalRecordKind.vaccination: 'Vacinação',
                                ClinicalRecordKind.deworming: 'Vermifugação',
                                ClinicalRecordKind.medication: 'Medicação',
                              },
                              (value) => viewModel.setCareKind(index, value),
                            ),
                            field(
                              'careDescription$index',
                              'Descrição do cuidado',
                              draft.careRecords[index].description,
                              (value) =>
                                  viewModel.setCareDescription(index, value),
                              error: 'careRecords.$index.description',
                              lines: 2,
                            ),
                            TextButton(
                              onPressed: viewModel.canEdit
                                  ? () => viewModel.removeCare(index)
                                  : null,
                              child: const Text('Remover cuidado'),
                            ),
                          ],
                        ),
                      ),
                    TextButton.icon(
                      onPressed: viewModel.canEdit
                          ? () => viewModel.addCare(
                              ClinicalRecordKind.vaccination,
                            )
                          : null,
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar cuidado'),
                    ),
                    if (photoViewModel != null)
                      PhotoUploadPanel(viewModel: photoViewModel!),
                    if (state.saving) const LinearProgressIndicator(),
                    if (state.message != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(state.message!),
                      ),
                    if (state.loadFailed)
                      OutlinedButton(
                        onPressed: viewModel.retryLoad,
                        child: const Text('Tentar carregar novamente'),
                      ),
                    if (state.canRetryPending)
                      OutlinedButton(
                        onPressed: state.saving ? null : viewModel.retryPending,
                        child: const Text('Tentar salvar novamente'),
                      ),
                    if (state.uncertain)
                      FilledButton(
                        onPressed: state.saving ? null : viewModel.reconcile,
                        child: const Text('Verificar resultado'),
                      )
                    else
                      FilledButton(
                        onPressed: viewModel.canEdit ? viewModel.save : null,
                        child: const Text('Salvar animal'),
                      ),
                  ],
                ),
        ),
      );
    },
  );
}
