import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/medication_application_view_model.dart';

const _border = Color(0xFFEADDD7),
    _muted = Color(0xFF795C52),
    _soft = Color(0xFFF6EAE5);

class MedicationApplicationDetailsSheet extends StatefulWidget {
  const MedicationApplicationDetailsSheet({super.key, required this.viewModel});
  final MedicationApplicationViewModel viewModel;
  @override
  State<MedicationApplicationDetailsSheet> createState() =>
      _MedicationApplicationDetailsSheetState();
}

class _MedicationApplicationDetailsSheetState
    extends State<MedicationApplicationDetailsSheet>
    with WidgetsBindingObserver {
  MedicationApplicationViewModel get viewModel => widget.viewModel;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && viewModel.canLeave) {
      viewModel.load();
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final state = viewModel.state;
      return PopScope(
        canPop: viewModel.canLeave,
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Agenda · ${viewModel.scheduledDate}',
                              style: const TextStyle(
                                fontSize: 10,
                                letterSpacing: .7,
                                color: brandRed,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Detalhes da aplicação',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: brandBrown,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Fechar aplicação',
                        onPressed: viewModel.canLeave
                            ? () => Navigator.of(context).maybePop()
                            : null,
                        style: IconButton.styleFrom(
                          backgroundColor: _soft,
                          foregroundColor: brandBrown,
                        ),
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    ],
                  ),
                ),
                if (state.loading || state.busy)
                  const LinearProgressIndicator(),
                Expanded(
                  child: ListView(
                    key: const ValueKey('medicationApplicationScroll'),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      if (state.application != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _soft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                foregroundColor: brandRed,
                                child: Text(
                                  viewModel.initial,
                                  style: const TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      viewModel.animalName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: brandBrown,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Revisão ${state.application!.revision} do tratamento',
                                      style: const TextStyle(
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
                        const SizedBox(height: 20),
                        const Text(
                          'MEDICAMENTO',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: .7,
                            color: _muted,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          viewModel.medicationName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: brandBrown,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          viewModel.instructions,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _muted,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: viewModel.isCompleted
                                  ? const Color(0xFFEEE2DC)
                                  : _soft,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              viewModel.stateLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: viewModel.stateLabel == 'Atrasada'
                                    ? brandRed
                                    : brandBrown,
                              ),
                            ),
                          ),
                        ),
                        _section([
                          _row('Data prevista', viewModel.scheduledDate),
                          _row('Horário previsto', viewModel.scheduledTime),
                          _row('Programação', state.scheduleLabel),
                        ]),
                        if (viewModel.isCompleted)
                          _section([
                            _row('Aplicado por', viewModel.actorLabel),
                            _row('Horário real', viewModel.actualTime),
                          ]),
                        _section([
                          const Text(
                            'Histórico da aplicação',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: brandBrown,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _event(
                            'Aplicação programada',
                            '${viewModel.scheduledDate} · ${viewModel.scheduledTime}\nVinculada ao tratamento de ${viewModel.animalName}.',
                          ),
                          for (final event in state.events)
                            _event(
                              viewModel.eventTitle(event),
                              viewModel.eventDescription(event),
                            ),
                          if (state.cursor != null)
                            TextButton(
                              onPressed: viewModel.canLoadMore
                                  ? () => viewModel.load(more: true)
                                  : null,
                              child: const Text('Carregar mais registros'),
                            ),
                        ]),
                        const Text(
                          'Ao confirmar, seu nome e o horário da aplicação serão registrados.',
                          style: TextStyle(
                            fontSize: 11,
                            color: _muted,
                            height: 1.6,
                          ),
                        ),
                      ],
                      if (state.message != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            state.message!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: brandBrown,
                            ),
                          ),
                        ),
                      if (state.loadFailed)
                        TextButton(
                          onPressed: state.loading
                              ? null
                              : () => viewModel.load(),
                          child: const Text('Tentar carregar aplicação'),
                        ),
                      if (state.uncertain && state.canRetry)
                        TextButton(
                          onPressed: viewModel.canReconcile
                              ? () => viewModel.retryPending()
                              : null,
                          child: const Text('Repetir a mesma operação'),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: _border)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: viewModel.canLeave
                              ? () => Navigator.of(context).maybePop()
                              : null,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            side: const BorderSide(color: _border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Voltar à agenda',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: state.uncertain
                              ? (viewModel.canReconcile
                                    ? () => viewModel.reconcile()
                                    : null)
                              : (viewModel.canComplete
                                    ? () => viewModel.complete()
                                    : null),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 52),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            state.uncertain
                                ? 'Verificar resultado'
                                : 'Marcar como aplicada',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13),
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
  Widget _section(List<Widget> children) => Container(
    margin: const EdgeInsets.only(top: 18, bottom: 18),
    padding: const EdgeInsets.only(top: 16),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: _border)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: brandBrown,
            ),
          ),
        ),
      ],
    ),
  );
  Widget _event(String title, String description) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.only(left: 12),
    decoration: const BoxDecoration(
      border: Border(left: BorderSide(color: _border, width: 2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: brandBrown,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(fontSize: 11, color: _muted, height: 1.6),
        ),
      ],
    ),
  );
}
