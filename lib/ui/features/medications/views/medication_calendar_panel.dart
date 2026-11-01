import 'package:flutter/material.dart';
import '../../../../domain/models/medication_application.dart';
import '../../../core/theme/app_theme.dart';
import '../view_models/medication_calendar_view_model.dart';

const _border = Color(0xFFEADDD7),
    _soft = Color(0xFFF6EAE5),
    _muted = Color(0xFF795C52);

class MedicationCalendarPanel extends StatelessWidget {
  const MedicationCalendarPanel({super.key, required this.viewModel});
  final MedicationCalendarViewModel viewModel;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: viewModel,
    builder: (context, _) {
      final state = viewModel.state;
      return RefreshIndicator(
        onRefresh: viewModel.refresh,
        child: ListView(
          key: const ValueKey('medicationCalendarScroll'),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (state.loadingMonth) const LinearProgressIndicator(),
            if (state.monthError != null) ...[
              Text(state.monthError!),
              TextButton(
                onPressed: viewModel.refresh,
                child: const Text('Tentar carregar calendário'),
              ),
            ],
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _border),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          viewModel.monthLabel,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            color: brandBrown,
                          ),
                        ),
                      ),
                      _monthButton(
                        'Mês anterior',
                        Icons.chevron_left,
                        () => viewModel.moveMonth(-1),
                      ),
                      const SizedBox(width: 7),
                      _monthButton(
                        'Próximo mês',
                        Icons.chevron_right,
                        () => viewModel.moveMonth(1),
                      ),
                      const SizedBox(width: 7),
                      OutlinedButton(
                        onPressed: viewModel.canNavigate
                            ? viewModel.today
                            : null,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          side: const BorderSide(color: _border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Hoje',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final label in [
                        'Dom',
                        'Seg',
                        'Ter',
                        'Qua',
                        'Qui',
                        'Sex',
                        'Sáb',
                      ])
                        Expanded(
                          child: Text(
                            label,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10, color: _muted),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Table(
                    children: [
                      for (
                        var start = 0;
                        start < viewModel.cells.length;
                        start += 7
                      )
                        TableRow(
                          children: [
                            for (var column = 0; column < 7; column++)
                              if (start + column >= viewModel.cells.length ||
                                  viewModel.cells[start + column] == null)
                                const SizedBox(height: 38)
                              else
                                _day(viewModel.cells[start + column]!),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  const Row(
                    children: [
                      Icon(Icons.circle, size: 4, color: brandRed),
                      SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Dia com aplicações programadas',
                          style: TextStyle(fontSize: 10, color: _muted),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 19),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Text(
                  viewModel.dayLabel,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    color: brandBrown,
                  ),
                ),
                const Text(
                  'AGENDA DO DIA',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: .7,
                    color: _muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              viewModel.summary,
              style: const TextStyle(fontSize: 11, color: _muted),
            ),
            const SizedBox(height: 13),
            if (state.loadingDay) const LinearProgressIndicator(),
            if (state.dayError != null) ...[
              Text(state.dayError!),
              TextButton(
                onPressed: () => viewModel.selectDay(state.selectedDay),
                child: const Text('Tentar carregar agenda'),
              ),
            ],
            if (!state.loadingMonth &&
                !state.loadingDay &&
                state.monthError == null &&
                state.dayError == null &&
                state.items.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Dia livre de aplicações',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: brandBrown,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Não há medicações programadas para este dia.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
            for (final item in state.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _application(item),
              ),
            if (state.cursor != null)
              TextButton(
                onPressed: viewModel.canLoadMore ? viewModel.loadMore : null,
                child: const Text('Carregar mais aplicações'),
              ),
            const SizedBox(height: 12),
            const Text(
              'Horários do abrigo · Uberaba, MG\nAplicações vinculadas à ficha de cada animal.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: _muted),
            ),
          ],
        ),
      );
    },
  );
  Widget _monthButton(String label, IconData icon, VoidCallback action) =>
      SizedBox(
        width: 32,
        height: 32,
        child: IconButton(
          tooltip: label,
          onPressed: viewModel.canNavigate ? action : null,
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: _soft,
            foregroundColor: brandBrown,
          ),
          icon: Icon(icon, size: 19),
        ),
      );
  Widget _day(String day) {
    final selected = day == viewModel.state.selectedDay;
    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: Semantics(
        selected: selected,
        label:
            'Dia ${int.parse(day.substring(8))}${viewModel.hasApplications(day) ? ', com aplicações' : ''}',
        child: Material(
          color: selected ? brandRed : Colors.white,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(
            key: ValueKey('medicationDay-$day'),
            onTap: viewModel.canNavigate
                ? () => viewModel.selectDay(day)
                : null,
            borderRadius: BorderRadius.circular(9),
            child: SizedBox(
              height: 32,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${int.parse(day.substring(8))}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected ? Colors.white : brandBrown,
                    ),
                  ),
                  if (viewModel.hasApplications(day))
                    Positioned(
                      bottom: 3,
                      child: Icon(
                        Icons.circle,
                        size: 4,
                        color: selected ? Colors.white : brandRed,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _application(MedicationApplication item) {
    final label = viewModel.statusLabel(item);
    final color = switch (label) {
      'Realizada' => brandBrown,
      'Atrasada' => brandRed,
      _ => _muted,
    };
    return Container(
      key: ValueKey('medicationApplication-${item.id}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 39,
            child: Text(
              item.scheduledLocalTime,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: brandBrown,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.animalName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: brandBrown,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.medicationName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: item.state == MedicationApplicationState.completed
                        ? const Color(0xFFEEE2DC)
                        : _soft,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(color: color, fontSize: 10),
                  ),
                ),
                if (item.state == MedicationApplicationState.completed)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      viewModel.appliedLabel(item),
                      style: const TextStyle(fontSize: 10, color: _muted),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          SizedBox(
            width: 30,
            height: 30,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _soft,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                item.state == MedicationApplicationState.completed
                    ? Icons.check
                    : Icons.chevron_right,
                size: 18,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
