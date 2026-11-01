import '../../../core/widgets/app_back_button.dart';
import '../../medications/views/medication_calendar_panel.dart';
import '../../medications/view_models/medication_calendar_view_model.dart';
import 'package:flutter/material.dart';
import '../../../../domain/models/animal.dart';
import '../view_models/dashboard_view_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.viewModel,
    this.onSignOut,
    this.calendarViewModel,
  });
  final DashboardViewModel viewModel;
  final VoidCallback? onSignOut;
  final MedicationCalendarViewModel? calendarViewModel;
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  DashboardViewModel get viewModel => widget.viewModel;
  VoidCallback? get onSignOut => widget.onSignOut;
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
    if (state == AppLifecycleState.resumed) {
      if (viewModel.isCalendar) {
        widget.calendarViewModel?.refresh();
      } else {
        viewModel.load();
      }
    }
  }

  static const _border = Color(0xFFEADDD7),
      _soft = Color(0xFFF6EAE5),
      _brown = Color(0xFF45180D);
  static const _colors = {
    AnimalStatus.available: Color(0xFF328154),
    AnimalStatus.treatment: Color(0xFF7B3F2B),
    AnimalStatus.quarantine: Color(0xFFC51D2A),
    AnimalStatus.adopted: Color(0xFF795C52),
  };
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) => Scaffold(
      floatingActionButton: !viewModel.showRegistration
          ? null
          : FloatingActionButton(
              tooltip: 'Cadastrar animal',
              onPressed: viewModel.canManage ? () => _edit(context) : null,
              child: const Icon(Icons.add),
            ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          viewModel.subtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            letterSpacing: 1,
                            color: Color(0xFFC51D2A),
                          ),
                        ),
                        Text(
                          viewModel.heading,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Atualizar painel',
                    onPressed: viewModel.state.busy
                        ? null
                        : () {
                            viewModel.load();
                            if (viewModel.isCalendar) {
                              widget.calendarViewModel?.refresh();
                            }
                          },
                    icon: const Icon(Icons.refresh),
                  ),
                  if (onSignOut != null)
                    IconButton.filledTonal(
                      tooltip: 'Sair da conta',
                      onPressed: onSignOut,
                      icon: const Icon(Icons.logout),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              child: Row(
                children: [
                  for (final status in const [
                    AnimalStatus.available,
                    AnimalStatus.treatment,
                    AnimalStatus.quarantine,
                  ])
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${viewModel.state.counts[status] ?? 0}',
                              key: ValueKey('count-${status.name}'),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _colors[status],
                              ),
                            ),
                            Text(
                              DashboardViewModel.labels[status]!,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF795C52),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  _tab(
                    'Kanban',
                    viewModel.state.mode == DashboardMode.kanban,
                    () => viewModel.setListMode(false),
                  ),
                  const SizedBox(width: 4),
                  _tab(
                    'Lista',
                    viewModel.state.listMode,
                    () => viewModel.setListMode(true),
                  ),
                  const SizedBox(width: 4),
                  _tab(
                    'Calendário',
                    viewModel.isCalendar,
                    () => viewModel.setMode(DashboardMode.calendar),
                  ),
                ],
              ),
            ),
            if (viewModel.state.loading || viewModel.state.busy)
              const LinearProgressIndicator(),
            if (viewModel.state.message != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                child: Text(viewModel.state.message!),
              ),
            if (viewModel.state.uncertain)
              Wrap(
                children: [
                  TextButton(
                    onPressed: viewModel.state.busy
                        ? null
                        : viewModel.reconcile,
                    child: const Text('Consultar resultado'),
                  ),
                  if (viewModel.state.canRetry)
                    TextButton(
                      onPressed: viewModel.retry,
                      child: const Text('Tentar novamente'),
                    ),
                ],
              ),
            Expanded(
              child: viewModel.isCalendar
                  ? (widget.calendarViewModel == null
                        ? const Center(child: Text('Agenda indisponível.'))
                        : MedicationCalendarPanel(
                            viewModel: widget.calendarViewModel!,
                          ))
                  : viewModel.state.listMode
                  ? _list(context)
                  : _kanban(context),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _tab(String label, bool selected, VoidCallback action) => Expanded(
    child: OutlinedButton(
      onPressed: action,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        backgroundColor: selected ? _brown : Colors.white,
        foregroundColor: selected ? Colors.white : _brown,
        side: const BorderSide(color: _border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    ),
  );
  Future<void> _edit(BuildContext context, [String? id]) async {
    await Navigator.pushNamed(context, '/animal-editor', arguments: id);
    await viewModel.load();
    if (viewModel.isCalendar) await widget.calendarViewModel?.refresh();
  }

  Widget _list(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
    children: [
      for (final status in AnimalStatus.values) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${DashboardViewModel.labels[status]} · ${viewModel.state.counts[status] ?? 0}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        for (final item
            in viewModel.state.pages[status]?.items ?? <ManagedAnimal>[])
          _card(context, item),
        if (viewModel.state.pages[status]?.items.isEmpty ?? true)
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Nenhum animal nesta situação.',
              style: TextStyle(fontSize: 11),
            ),
          ),
        if (viewModel.state.pages[status]?.cursor != null)
          TextButton(
            onPressed: viewModel.canManage
                ? () => viewModel.loadMore(status)
                : null,
            child: Text('Carregar mais ${DashboardViewModel.labels[status]}'),
          ),
      ],
    ],
  );
  Widget _kanban(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 0, 14, 90),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final status in const [
          AnimalStatus.available,
          AnimalStatus.treatment,
          AnimalStatus.quarantine,
        ])
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
              decoration: BoxDecoration(
                color: _soft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '${DashboardViewModel.labels[status]} · ${viewModel.state.counts[status] ?? 0}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Divider(color: _border),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final item
                            in viewModel.state.pages[status]?.items ??
                                <ManagedAnimal>[])
                          _card(context, item, compact: true),
                        if (viewModel.state.pages[status]?.items.isEmpty ??
                            true)
                          const Text(
                            'Sem animais',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10),
                          ),
                        if (viewModel.state.pages[status]?.cursor != null)
                          TextButton(
                            onPressed: viewModel.canManage
                                ? () => viewModel.loadMore(status)
                                : null,
                            child: const Text(
                              'Mais',
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
  Widget _card(
    BuildContext context,
    ManagedAnimal item, {
    bool compact = false,
  }) {
    final animal = item.animal;
    final clinicalSummary = viewModel.cardClinicalSummary(item);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: _border),
      ),
      child: InkWell(
        onTap: viewModel.canManage ? () => _edit(context, animal.id) : null,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.all(compact ? 6 : 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!compact) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _soft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.pets_outlined,
                        size: 22,
                        color: Color(0xFFC51D2A),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      animal.name,
                      style: TextStyle(
                        fontSize: compact ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: compact ? 24 : 40,
                    child: PopupMenuButton<String>(
                      tooltip: 'Ações de ${animal.name}',
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      enabled: viewModel.canManage,
                      onSelected: (value) {
                        if (value == 'edit') {
                          _edit(context, animal.id);
                        } else if (value == 'publication') {
                          viewModel.togglePublication(animal);
                        } else {
                          viewModel.setStatus(
                            animal.id,
                            AnimalStatus.values.byName(value),
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Editar cadastro'),
                        ),
                        for (final status in AnimalStatus.values)
                          PopupMenuItem(
                            value: status.name,
                            child: Text(
                              'Mover para ${DashboardViewModel.labels[status]}',
                            ),
                          ),
                        PopupMenuItem(
                          value: 'publication',
                          enabled: viewModel.canChangePublication(animal),
                          child: Text(viewModel.publicationLabel(animal)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                viewModel.cardSubtitle(animal),
                style: const TextStyle(fontSize: 10, color: Color(0xFF795C52)),
              ),
              const SizedBox(height: 6),
              Tooltip(
                message: clinicalSummary,
                child: Container(
                  key: ValueKey('clinicalSummary-${animal.id}'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (_colors[animal.status] ?? const Color(0xFF795C52))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    clinicalSummary,
                    maxLines: compact ? 3 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.4,
                      color: _colors[animal.status],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                viewModel.visibilityLabel(animal),
                style: TextStyle(fontSize: 10, color: _colors[animal.status]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
