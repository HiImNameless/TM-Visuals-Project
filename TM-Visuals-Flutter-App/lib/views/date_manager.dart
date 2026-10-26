import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/calendar_service.dart';
import '../viewmodels/date_availability_viewmodel.dart';
import '../widgets/admin_widgets.dart';

class DateManagerScreen extends StatelessWidget {
  const DateManagerScreen({
    super.key,
    required this.service,
    required this.date,
  });
  final CalendarDataSource service;
  final DateTime date;
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => DateAvailabilityViewModel(service, date)..load(),
    child: const _DateManagerBody(),
  );
}

class _DateManagerBody extends StatelessWidget {
  const _DateManagerBody();
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DateAvailabilityViewModel>();
    return PopScope(
      canPop: !vm.saving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Manage availability')),
        body: AdminContent(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                dateLabel(vm.date),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Text(
                'Booked sessions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (vm.loading)
                const Center(child: CircularProgressIndicator())
              else if (vm.loadError != null)
                AdminErrorNotice(error: vm.loadError!, retry: vm.load)
              else
                DayBookingsPreview(slots: vm.slots),
              const SizedBox(height: 24),
              const Text(
                'Availability applies to this entire day. Existing bookings stay scheduled when the day is made unavailable.',
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date availability'),
                subtitle: Text(vm.available ? 'Available' : 'Unavailable'),
                value: vm.available,
                onChanged: vm.canSave ? vm.setAvailable : null,
              ),
              if (vm.saveError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    adminError(vm.saveError!),
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),
              FilledButton(
                onPressed: vm.canSave
                    ? () async {
                        if (await vm.save() && context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      }
                    : null,
                child: Text(vm.saving ? 'Saving…' : 'Save availability'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: vm.saving
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
