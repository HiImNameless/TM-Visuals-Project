import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/calendar_model.dart';
import '../services/calendar_service.dart';
import '../viewmodels/calendar_viewmodel.dart';
import '../widgets/admin_bottom_nav.dart';
import '../widgets/admin_widgets.dart';
import 'date_manager.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, this.service, this.initialDate});
  final CalendarDataSource? service;
  final DateTime? initialDate;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => CalendarViewModel(
      service ?? CalendarService(),
      initialDate: initialDate,
    )..load(),
    child: const _CalendarBody(),
  );
}

class _CalendarBody extends StatelessWidget {
  const _CalendarBody();
  Future<void> _edit(BuildContext context, CalendarViewModel vm) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            DateManagerScreen(service: vm.service, date: vm.selected),
      ),
    );
    if (context.mounted) await vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CalendarViewModel>();
    final first = DateTime(vm.selected.year, vm.selected.month);
    final offset = first.weekday - 1;
    final days = DateTime(first.year, first.month + 1, 0).day;
    final cells = ((offset + days + 6) ~/ 7) * 7;
    return Scaffold(
      appBar: AppBar(title: const Text('TM Visuals')),
      bottomNavigationBar: AdminBottomNav(currentIndex: 1, onReturn: vm.load),
      body: AdminContent(
        child: RefreshIndicator(
          onRefresh: vm.load,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Calendar',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  TextButton(onPressed: vm.today, child: const Text('Today')),
                  IconButton(
                    tooltip: 'Refresh calendar',
                    onPressed: vm.load,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Previous month',
                    onPressed: () => vm.moveMonth(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: Text(
                      monthLabel(first),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next month',
                    onPressed: () => vm.moveMonth(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                    Expanded(child: Center(child: Text(d))),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cells,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                  mainAxisExtent: 48,
                ),
                itemBuilder: (context, index) {
                  final n = index - offset + 1;
                  if (n < 1 || n > days) return const SizedBox.shrink();
                  final date = DateTime(first.year, first.month, n);
                  final status = vm.status(date);
                  final color = switch (status) {
                    'Unavailable' => unavailableDayColor,
                    'Reserved' => adminGold,
                    'Available' => const Color(0xFF236B43),
                    _ => const Color(0xFF343434),
                  };
                  return Semantics(
                    label: '${dateLabel(date)}, $status',
                    selected: n == vm.selected.day,
                    child: Tooltip(
                      message: status,
                      child: OutlinedButton(
                        key: ValueKey('date-${dateKey(date)}'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: color,
                          foregroundColor: status == 'Reserved'
                              ? Colors.black
                              : Colors.white,
                          side: BorderSide(
                            color: n == vm.selected.day
                                ? Colors.white
                                : Colors.transparent,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => vm.selectDate(date),
                        child: Text('$n'),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _Legend('Available', Color(0xFF236B43)),
                  _Legend('Reserved', adminGold),
                  _Legend('Unavailable day', unavailableDayColor),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    dateLabel(vm.selected),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  FilledButton.icon(
                    onPressed: vm.loading || vm.error != null
                        ? null
                        : () => _edit(context, vm),
                    icon: const Icon(Icons.edit_calendar),
                    label: const Text('Manage availability'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (vm.loading)
                const Center(child: CircularProgressIndicator())
              else if (vm.error != null)
                AdminErrorNotice(error: vm.error!, retry: vm.load)
              else
                DayBookingsPreview(
                  slots: vm.forDate(vm.selected),
                  onInvoice: (id) => Navigator.of(
                    context,
                  ).pushNamed('/add-invoice', arguments: id),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.label, this.color);
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 12, color: color),
      const SizedBox(width: 6),
      Text(label),
    ],
  );
}
