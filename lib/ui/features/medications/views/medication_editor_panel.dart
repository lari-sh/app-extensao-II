import 'package:flutter/material.dart';
import '../../../../domain/models/medication_schedule.dart';
import '../../../../domain/models/medication_treatment.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/medication_editor_view_model.dart';

const _border = Color(0xFFEADDD7);
const _muted = Color(0xFF795C52);
const _display = TextStyle(
  fontFamily: 'Georgia',
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: brandBrown,
);

class MedicationEditorPanel extends StatelessWidget {
  const MedicationEditorPanel({super.key, required this.viewModel});
  final MedicationEditorViewModel viewModel;
  Future<void> _open(BuildContext context, String? treatmentId) async {
    final feedback = await Navigator.of(context).pushNamed(
      '/medication-editor',
      arguments: {
        'animalId': viewModel.state.animalId,
        'treatmentId': treatmentId,
      },
    );
    if (!context.mounted) return;
    if (feedback is String) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(feedback)));
    }
    await viewModel.load();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, child) {
      final state = viewModel.state;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 18),
          const Text('Medicações em uso', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 10),
          if (state.loading) const LinearProgressIndicator(),
          for (final treatment in state.treatments)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 2,
                  ),
                  title: Text(
                    treatment.medicationName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: brandBrown,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '${viewModel.scheduleLabel(treatment)}${treatment.status == MedicationTreatmentStatus.stopped ? ' · Interrompido' : ''}',
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                  ),
                  onTap: viewModel.canModify(treatment)
                      ? () => _open(context, treatment.id)
                      : null,
                  trailing: IconButton(
                    tooltip: 'Interromper ${treatment.medicationName}',
                    onPressed: viewModel.canModify(treatment)
                        ? () => viewModel.stop(treatment)
                        : null,
                    icon: const Icon(Icons.close, size: 17),
                  ),
                ),
              ),
            ),
          if (state.animalId == null)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Salve o animal para programar medicações.',
                style: TextStyle(fontSize: 12, color: _muted),
              ),
            ),
          if (state.message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                state.message!,
                style: const TextStyle(fontSize: 12, color: brandBrown),
              ),
            ),
          if (state.loadFailed)
            TextButton(
              onPressed: viewModel.load,
              child: const Text('Tentar carregar medicações'),
            ),
          if (state.uncertain)
            TextButton(
              onPressed: viewModel.canReconcile ? viewModel.reconcile : null,
              child: const Text('Verificar resultado'),
            ),
          if (state.canRetryPending)
            TextButton(
              onPressed: viewModel.canReconcile ? viewModel.retryPending : null,
              child: const Text('Repetir a mesma operação'),
            ),
          if (viewModel.canLoadMore)
            TextButton(
              onPressed: () => viewModel.load(more: true),
              child: const Text('Carregar mais tratamentos'),
            ),
          OutlinedButton.icon(
            onPressed: viewModel.canEdit ? () => _open(context, null) : null,
            icon: const Icon(Icons.add, size: 16),
            label: const Text(
              'Adicionar medicação',
              style: TextStyle(fontSize: 12),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 42),
              side: const BorderSide(color: _border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              foregroundColor: _muted,
            ),
          ),
        ],
      );
    },
  );
}

class MedicationProgrammingScreen extends StatelessWidget {
  const MedicationProgrammingScreen({super.key, required this.viewModel});
  final MedicationEditorViewModel viewModel;
  Future<void> _submit(BuildContext context) async {
    final confirmed = viewModel.state.uncertain
        ? await viewModel.reconcile()
        : await viewModel.save();
    if (confirmed && context.mounted) {
      Navigator.of(context).pop(viewModel.state.message);
    }
  }

  Future<void> _retry(BuildContext context) async {
    if (await viewModel.retryPending() && context.mounted) {
      Navigator.of(context).pop(viewModel.state.message);
    }
  }

  void _close(BuildContext context) {
    viewModel.cancelDraft();
    Navigator.of(context).maybePop();
  }

  Future<void> _pickDate(BuildContext context, bool start) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.pickerDate(start),
      firstDate: viewModel.firstPickerDate,
      lastDate: viewModel.lastPickerDate,
    );
    if (picked != null) viewModel.setPickedDate(start, picked);
  }

  Future<void> _pickTime(BuildContext context, bool start, {int? index}) async {
    final schedule = viewModel.state.draft.schedule;
    final parts = viewModel.pickerTime(
      index != null
          ? schedule.fixedTimes[index]
          : start
          ? schedule.startsTime
          : schedule.endsTime,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: parts.hour, minute: parts.minute),
    );
    if (picked != null) {
      viewModel.setPickedTime(index, start, picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, child) {
      final state = viewModel.state,
          draft = state.draft,
          schedule = draft.schedule;
      Widget field(
        String key,
        String label,
        String value,
        ValueChanged<String> change, {
        String? error,
        TextInputType? keyboard,
        int lines = 1,
        bool smallLabel = false,
        Widget? suffix,
        String? hint,
      }) => KeyedSubtree(
        key: ValueKey(key),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (label.isNotEmpty) ...[
              Text(
                label,
                style: smallLabel
                    ? const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: _muted,
                        letterSpacing: .6,
                      )
                    : const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: brandBrown,
                      ),
              ),
              const SizedBox(height: 7),
            ],
            TextFormField(
              key: ValueKey(state.formVersion),
              initialValue: value,
              enabled: viewModel.canEdit,
              onChanged: change,
              keyboardType: keyboard,
              maxLines: lines,
              style: TextStyle(
                fontSize: smallLabel ? 12 : 13,
                color: brandBrown,
              ),
              decoration: InputDecoration(
                hintText: hint,
                suffixIcon: suffix,
                suffixIconConstraints: const BoxConstraints.tightFor(
                  width: 30,
                  height: 40,
                ),
                errorText: state.errors[error],
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: smallLabel ? 8 : 12,
                  vertical: 13,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _border),
                ),
              ),
            ),
          ],
        ),
      );
      Widget spaced(Widget child) =>
          Padding(padding: const EdgeInsets.only(bottom: 18), child: child);
      return PopScope(
        canPop: viewModel.canLeave,
        child: Scaffold(
          backgroundColor: warmSurface,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FICHA DO ANIMAL',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                color: brandRed,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text('Programar medicação', style: _display),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Fechar programação',
                        onPressed: viewModel.canLeave
                            ? () => _close(context)
                            : null,
                        style: IconButton.styleFrom(
                          backgroundColor: softBackground,
                        ),
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: brandBrown,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.loading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          key: const ValueKey('medicationFormScroll'),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: softBackground,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      foregroundColor: brandRed,
                                      radius: 19,
                                      child: Text(
                                        viewModel.animalInitial,
                                        style: const TextStyle(
                                          fontFamily: 'Georgia',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            viewModel.animalDisplayName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const Text(
                                            'Tratamento do animal',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: _muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (state.hasDraft) ...[
                                spaced(
                                  field(
                                    'medicationName',
                                    'Medicamento',
                                    draft.medicationName,
                                    viewModel.setName,
                                    error: 'medicationName',
                                  ),
                                ),
                                spaced(
                                  field(
                                    'medicationInstructions',
                                    'Instruções do tratamento',
                                    draft.instructions,
                                    viewModel.setInstructions,
                                    error: 'instructions',
                                    lines: 3,
                                  ),
                                ),
                                const Text(
                                  'Período do tratamento',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                spaced(
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            field(
                                              'medicationStartsOn',
                                              'INÍCIO',
                                              viewModel.startDateText,
                                              viewModel.setStartDate,
                                              error: 'startsOn',
                                              smallLabel: true,
                                              hint: 'DD/MM/AAAA',
                                              suffix: IconButton(
                                                tooltip:
                                                    'Escolher data de início',
                                                padding: EdgeInsets.zero,
                                                onPressed: viewModel.canEdit
                                                    ? () => _pickDate(
                                                        context,
                                                        true,
                                                      )
                                                    : null,
                                                icon: const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 15,
                                                ),
                                              ),
                                              keyboard: TextInputType.datetime,
                                            ),
                                            const SizedBox(height: 6),
                                            field(
                                              'medicationStartsTime',
                                              '',
                                              schedule.startsTime,
                                              viewModel.setStartTime,
                                              error: 'startsTime',
                                              suffix: IconButton(
                                                tooltip:
                                                    'Escolher horário de início',
                                                padding: EdgeInsets.zero,
                                                onPressed: viewModel.canEdit
                                                    ? () => _pickTime(
                                                        context,
                                                        true,
                                                      )
                                                    : null,
                                                icon: const Icon(
                                                  Icons.access_time,
                                                  size: 17,
                                                ),
                                              ),
                                              keyboard: TextInputType.datetime,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            field(
                                              'medicationEndsOn',
                                              'TÉRMINO',
                                              viewModel.endDateText,
                                              viewModel.setEndDate,
                                              error: 'endsOn',
                                              smallLabel: true,
                                              hint: 'DD/MM/AAAA',
                                              suffix: IconButton(
                                                tooltip:
                                                    'Escolher data de término',
                                                padding: EdgeInsets.zero,
                                                onPressed: viewModel.canEdit
                                                    ? () => _pickDate(
                                                        context,
                                                        false,
                                                      )
                                                    : null,
                                                icon: const Icon(
                                                  Icons.calendar_today_outlined,
                                                  size: 15,
                                                ),
                                              ),
                                              keyboard: TextInputType.datetime,
                                            ),
                                            const SizedBox(height: 6),
                                            field(
                                              'medicationEndsTime',
                                              '',
                                              schedule.endsTime,
                                              viewModel.setEndTime,
                                              error: 'endsTime',
                                              suffix: IconButton(
                                                tooltip:
                                                    'Escolher horário de término',
                                                padding: EdgeInsets.zero,
                                                onPressed: viewModel.canEdit
                                                    ? () => _pickTime(
                                                        context,
                                                        false,
                                                      )
                                                    : null,
                                                icon: const Icon(
                                                  Icons.access_time,
                                                  size: 17,
                                                ),
                                              ),
                                              keyboard: TextInputType.datetime,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (state.errors['period'] != null)
                                  Text(
                                    state.errors['period']!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: brandRed,
                                    ),
                                  ),
                                const Text(
                                  'Como programar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: softBackground,
                                    borderRadius: BorderRadius.circular(11),
                                  ),
                                  child: Row(
                                    children: [
                                      for (final mode
                                          in MedicationScheduleMode.values)
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: schedule.mode == mode
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: TextButton(
                                              onPressed: viewModel.canEdit
                                                  ? () =>
                                                        viewModel.setMode(mode)
                                                  : null,
                                              style: TextButton.styleFrom(
                                                foregroundColor:
                                                    schedule.mode == mode
                                                    ? brandRed
                                                    : brandBrown,
                                                minimumSize: const Size(0, 38),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 4,
                                                    ),
                                              ),
                                              child: Text(
                                                mode ==
                                                        MedicationScheduleMode
                                                            .fixedTimes
                                                    ? 'Horários fixos'
                                                    : 'Por intervalo',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                if (schedule.mode ==
                                    MedicationScheduleMode.fixedTimes) ...[
                                  const Text(
                                    'Horários de aplicação',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      for (
                                        var i = 0;
                                        i < schedule.fixedTimes.length;
                                        i++
                                      )
                                        SizedBox(
                                          width: i == 0 ? 92 : 122,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  key: ValueKey(
                                                    'medicationTime${state.formVersion}-$i',
                                                  ),
                                                  initialValue:
                                                      schedule.fixedTimes[i],
                                                  enabled: viewModel.canEdit,
                                                  keyboardType:
                                                      TextInputType.datetime,
                                                  onChanged: (value) =>
                                                      viewModel.setTime(
                                                        i,
                                                        value,
                                                      ),
                                                  style: const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 12,
                                                  ),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            9,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: _border,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              if (i > 0)
                                                SizedBox(
                                                  width: 28,
                                                  child: IconButton(
                                                    tooltip:
                                                        'Remover horário ${i + 1}',
                                                    padding: EdgeInsets.zero,
                                                    onPressed: viewModel.canEdit
                                                        ? () => viewModel
                                                              .removeTime(i)
                                                        : null,
                                                    icon: const Icon(
                                                      Icons.close,
                                                      size: 14,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      TextButton(
                                        onPressed: viewModel.canEdit
                                            ? viewModel.addTime
                                            : null,
                                        child: const Text(
                                          '+ Horário',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: brandRed,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (state.errors['fixedTimes'] != null)
                                    Text(
                                      state.errors['fixedTimes']!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: brandRed,
                                      ),
                                    ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Text(
                                      'Os mesmos horários em cada dia do período.',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _muted,
                                      ),
                                    ),
                                  ),
                                ] else
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: field(
                                          'medicationInterval',
                                          'A cada',
                                          state.intervalInput,
                                          (value) => viewModel.setInterval(
                                            value,
                                            hours: state.intervalInHours,
                                          ),
                                          error: 'intervalMinutes',
                                          keyboard: TextInputType.number,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            const Text(
                                              'Unidade',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 7),
                                            DropdownButtonFormField<bool>(
                                              isExpanded: true,
                                              initialValue:
                                                  state.intervalInHours,
                                              items: const [
                                                DropdownMenuItem(
                                                  value: true,
                                                  child: Text('Horas'),
                                                ),
                                                DropdownMenuItem(
                                                  value: false,
                                                  child: Text('Minutos'),
                                                ),
                                              ],
                                              onChanged: viewModel.canEdit
                                                  ? (value) {
                                                      if (value != null) {
                                                        viewModel
                                                            .setIntervalUnit(
                                                              value,
                                                            );
                                                      }
                                                    }
                                                  : null,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: brandBrown,
                                              ),
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                contentPadding: EdgeInsets.all(
                                                  12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: softBackground,
                                    border: Border.all(color: _border),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Próximas aplicações',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        viewModel.scheduleSummary,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: _muted,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Ao salvar, as aplicações entram na agenda do abrigo. Informações restritas à equipe.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _muted,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                              if (state.message != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Text(
                                    state.message!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: brandRed,
                                    ),
                                  ),
                                ),
                              if (state.loadFailed)
                                TextButton(
                                  onPressed: viewModel.load,
                                  child: const Text(
                                    'Tentar carregar novamente',
                                  ),
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: const BoxDecoration(
                    color: warmSurface,
                    border: Border(top: BorderSide(color: _border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.canRetryPending
                              ? (viewModel.canReconcile
                                    ? () => _retry(context)
                                    : null)
                              : (viewModel.canLeave
                                    ? () => _close(context)
                                    : null),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            side: const BorderSide(color: _border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child: Text(
                            state.canRetryPending
                                ? 'Repetir operação'
                                : 'Cancelar',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: state.uncertain
                              ? (viewModel.canReconcile
                                    ? () => _submit(context)
                                    : null)
                              : (viewModel.canEdit && state.hasDraft
                                    ? () => _submit(context)
                                    : null),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child: Text(
                            state.saving
                                ? 'Confirmando…'
                                : state.uncertain
                                ? 'Verificar resultado'
                                : 'Salvar programação',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
