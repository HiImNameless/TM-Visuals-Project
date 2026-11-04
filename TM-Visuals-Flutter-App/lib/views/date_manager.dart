import 'package:flutter/material.dart';
import '../widgets/admin_page_app_bar.dart';
import 'package:provider/provider.dart';
import '../services/calendar_service.dart';
import '../viewmodels/date_availability_viewmodel.dart';
import '../widgets/admin_widgets.dart';
import '../widgets/blocked_times_editor.dart';
import '../models/calendar_model.dart';

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
        appBar: const AdminPageAppBar(title: 'Manage availability'),
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
                'Close the whole day or block selected times below. Existing bookings stay scheduled.',
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available for new bookings'),
                subtitle: Text(vm.available ? 'Available' : 'Unavailable'),
                value: vm.available,
                onChanged: vm.canSave ? vm.setAvailable : null,
              ),
              const SizedBox(height: 16),
              BlockedTimesEditor(
                key: ValueKey(dateKey(vm.date)),
                ranges: vm.blockedTimes,
                enabled: vm.canSave && vm.available,
                onChanged: vm.setBlockedTimes,
              ),
              if (!vm.available)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Saved blocked periods will apply again when this day is reopened.',
                  ),
                ),
              if (vm.overlapsBookings)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'This closure overlaps an existing booking. The booking will remain scheduled.',
                  ),
                ),
              const SizedBox(height: 20),
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
