import '../view_models/managed_animal_search_view_model.dart';
import 'managed_animal_search_toolbar.dart';
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
    this.searchViewModel,
  });
  final DashboardViewModel viewModel;
  final ManagedAnimalSearchViewModel? searchViewModel;
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
    viewModel.bindSearch(widget.searchViewModel);
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
      widget.searchViewModel?.refresh();
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
    listenable: Listenable.merge([viewModel, widget.searchViewModel]),
    builder: (context, _) => Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
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
            if (widget.searchViewModel != null)
              ManagedAnimalSearchToolbar(viewModel: widget.searchViewModel!),
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
            if (widget.searchViewModel?.showGlobalResults ?? false)
              _searchFeedback(widget.searchViewModel!),
            Expanded(
              child: IndexedStack(
                index: viewModel.state.mode.index,
                children: [
                  _kanban(context),
                  _list(context),
                  widget.calendarViewModel == null
                      ? const Center(child: Text('Agenda indisponível.'))
                      : MedicationCalendarPanel(
                          viewModel: widget.calendarViewModel!,
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  void _refresh() {
    viewModel.load();
    widget.searchViewModel?.refresh();
    if (viewModel.isCalendar) widget.calendarViewModel?.refresh();
  }

  Widget _header(BuildContext context) => Padding(
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
        SizedBox.square(
          dimension: 48,
          child: PopupMenuButton<String>(
            tooltip: 'Administração',
            icon: const Icon(Icons.more_vert),
            onSelected: (action) {
              if (action == 'add') {
                _edit(context);
              } else if (action == 'team') {
                Navigator.pushNamed(context, '/team');
              } else if (action == 'refresh') {
                _refresh();
              } else if (action == 'signOut') {
                onSignOut?.call();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'add',
                key: const ValueKey('addAnimal'),
                enabled: viewModel.canManage,
                child: const Text(
                  'Adicionar animal',
                  style: TextStyle(
                    color: Color(0xFFC51D2A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (viewModel.showTeam)
                const PopupMenuItem(
                  value: 'team',
                  child: Text('Equipe e acessos'),
                ),
              PopupMenuItem(
                value: 'refresh',
                enabled: !viewModel.state.busy,
                child: const Text('Atualizar painel'),
              ),
              if (onSignOut != null)
                const PopupMenuItem(
                  value: 'signOut',
                  child: Text('Sair da conta'),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _searchFeedback(ManagedAnimalSearchViewModel search) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                viewModel.isCalendar
                    ? 'Medicações do dia para a busca'
                    : search.countLabel,
                style: const TextStyle(fontSize: 11),
              ),
            ),
            Flexible(
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: search.clearAll,
                  child: const Text('Limpar busca'),
                ),
              ),
            ),
          ],
        ),
        if (search.state.loading) const LinearProgressIndicator(),
        if (search.state.message != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  search.state.message!,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              TextButton(
                onPressed: () => search.search(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        if (search.canLoadMore && !viewModel.isCalendar)
          TextButton(
            onPressed: () => search.search(next: true),
            child: const Text('Carregar mais animais'),
          ),
      ],
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
    await widget.searchViewModel?.refresh();
    if (viewModel.isCalendar) await widget.calendarViewModel?.refresh();
  }

  Widget _list(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
    children: [
      for (final status in AnimalStatus.values) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            viewModel.columnHeading(status),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        for (final item in viewModel.itemsForStatus(status))
          _card(context, item),
        if (viewModel.emptyStatus(status))
          const Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              'Nenhum animal nesta situação.',
              style: TextStyle(fontSize: 11),
            ),
          ),
        if (viewModel.hasMoreForStatus(status))
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
    key: const ValueKey('animal-kanban'),
    padding: EdgeInsets.zero,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final status in viewModel.kanbanStatuses)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: _soft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height:
                        MediaQuery.textScalerOf(context).scale(11) * 1.4 * 2,
                    child: Center(
                      child: Text(
                        viewModel.columnHeading(status),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: _border, height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final item in viewModel.itemsForStatus(status))
                          _card(context, item, compact: true),
                        if (viewModel.emptyStatus(status))
                          const Text(
                            'Sem animais',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10),
                          ),
                        if (viewModel.hasMoreForStatus(status))
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
    final textScaler = MediaQuery.textScalerOf(context);
    final lineHeight = textScaler.scale(10) * 1.4;
    final nameHeight = textScaler.scale(12) * 1.4 * 2;
    Widget slot(double height, Widget child) =>
        SizedBox(height: compact ? height : null, child: child);
    return Card(
      margin: EdgeInsets.only(bottom: compact ? 4 : 6),
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
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 4, vertical: 6)
              : const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              slot(
                nameHeight > 48 ? nameHeight : 48,
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
                        maxLines: compact ? 2 : null,
                        overflow: compact ? TextOverflow.ellipsis : null,
                        style: TextStyle(
                          fontSize: compact ? 12 : 14,
                          height: compact ? 1.4 : null,
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
              ),
              if (viewModel.isSearching)
                Text(
                  '#${animal.animalCode}',
                  maxLines: compact ? 1 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: TextStyle(fontSize: 10, height: compact ? 1.4 : null),
                ),
              slot(
                lineHeight * 2,
                Text(
                  viewModel.cardSubtitle(animal),
                  maxLines: compact ? 2 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: TextStyle(
                    fontSize: 10,
                    height: compact ? 1.4 : null,
                    color: const Color(0xFF795C52),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Tooltip(
                message: compact
                    ? 'Toque no cartão para ler a observação completa.'
                    : clinicalSummary,
                child: Container(
                  key: ValueKey('clinicalSummary-${animal.id}'),
                  height: compact ? lineHeight * 3 + 8 : null,
                  width: compact ? double.infinity : null,
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
                    compact
                        ? viewModel.cardClinicalPreview(item)
                        : clinicalSummary,
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
              slot(
                lineHeight,
                Text(
                  viewModel.visibilityLabel(animal),
                  maxLines: compact ? 1 : null,
                  overflow: compact ? TextOverflow.ellipsis : null,
                  style: TextStyle(
                    fontSize: 10,
                    height: compact ? 1.4 : null,
                    color: _colors[animal.status],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
