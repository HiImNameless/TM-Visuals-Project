String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
DateTime businessToday() {
  final now = DateTime.now().toUtc().add(const Duration(hours: 2));
  return DateTime(now.year, now.month, now.day);
}

bool reservationActive(String selection, String booking) =>
    ![selection, booking].any(
      (s) => const [
        'cancelled',
        'canceled',
        'rejected',
        'declined',
        'released',
      ].contains(s.trim().toLowerCase()),
    );

class CalendarBooking {
  const CalendarBooking({
    required this.id,
    required this.client,
    required this.event,
    required this.location,
    required this.status,
    required this.selectionStatus,
  });
  final String id, client, event, location, status, selectionStatus;
  bool get active => reservationActive(selectionStatus, status);
}

class CalendarSlot {
  const CalendarSlot({
    required this.id,
    required this.date,
    required this.start,
    required this.end,
    this.bookings = const [],
  });
  final String id, start, end;
  final DateTime date;
  final List<CalendarBooking> bookings;
  bool get reserved => bookings.any((b) => b.active);
  factory CalendarSlot.fromMap(Map<String, dynamic> row) => CalendarSlot(
    id: row['time_slot_id'] as String,
    date: DateTime.parse(row['slot_date'] as String),
    start: row['start_time'] as String,
    end: row['end_time'] as String,
    bookings: (row['booking_slot'] as List? ?? []).map((link) {
      final b = link['booking'] as Map<String, dynamic>;
      return CalendarBooking(
        id: b['booking_id'] as String,
        client:
            ((b['client'] as Map?)?['users'] as Map?)?['full_name']
                as String? ??
            'Client',
        event: b['event_type'] as String? ?? 'Booking',
        location: b['location'] as String? ?? '',
        status: b['booking_status'] as String? ?? 'unknown',
        selectionStatus: link['selection_status'] as String? ?? 'unknown',
      );
    }).toList(),
  );
}
