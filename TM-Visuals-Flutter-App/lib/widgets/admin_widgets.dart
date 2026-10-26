import 'package:flutter/material.dart';
import '../models/calendar_model.dart';

const adminGold = Color(0xFFFFB900);
const unavailableDayColor = Color(0xFF6B6B6B);
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
String monthLabel(DateTime d) => '${_months[d.month - 1]} ${d.year}';
String dateLabel(DateTime d) => '${d.day} ${monthLabel(d)}';
String adminError(Object e) => e is FormatException
    ? e.message
    : e.toString().replaceFirst('Exception: ', '');

class AdminContent extends StatelessWidget {
  const AdminContent({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: child,
    ),
  );
}

class AdminErrorNotice extends StatelessWidget {
  const AdminErrorNotice({super.key, required this.error, required this.retry});
  final Object error;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text(
          adminError(error),
          style: const TextStyle(color: Colors.redAccent),
        ),
        TextButton(onPressed: retry, child: const Text('Retry')),
      ],
    ),
  );
}

class DayBookingsPreview extends StatelessWidget {
  const DayBookingsPreview({super.key, required this.slots, this.onInvoice});
  final List<CalendarSlot> slots;
  final void Function(String)? onInvoice;
  @override
  Widget build(BuildContext context) {
    final booked = slots.where((s) => s.bookings.isNotEmpty).toList()
      ..sort((a, b) {
        final time = a.start.compareTo(b.start);
        return time == 0 ? a.id.compareTo(b.id) : time;
      });
    if (booked.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('No bookings for this date.'),
      );
    }
    return Column(
      children: [
        for (final slot in booked)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${slot.start.substring(0, 5)} – ${slot.end.substring(0, 5)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  for (final b in slot.bookings)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.client,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(b.event),
                          if (b.location.isNotEmpty) Text(b.location),
                          Text(
                            'Booking: ${b.status} · Selection: ${b.selectionStatus}',
                          ),
                          if (onInvoice != null)
                            TextButton.icon(
                              onPressed: () => onInvoice!(b.id),
                              icon: const Icon(Icons.upload_file),
                              label: const Text('Add invoice'),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
