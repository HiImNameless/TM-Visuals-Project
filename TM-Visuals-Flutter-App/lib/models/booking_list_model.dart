import 'package:flutter/foundation.dart';

class BookingListModel {
  final String name;
  final String venue;
  final String phoneNumber;
  final String service;
  final String time;
  final String date;
  final String status;

  BookingListModel({
    required this.name,
    required this.venue,
    required this.phoneNumber,
    required this.service,
    required this.time,
    required this.date,
    required this.status,
  });

  factory BookingListModel.fromMap(Map<String, dynamic> map) {
    return BookingListModel(
      service: map['event_type'] ?? '',
      venue: map['location'] ?? '',
      status: map['booking_status'] ?? '',
      name: map['full_name'] ?? '',
      phoneNumber: map['phone'] ?? '',
      time: map['time'] ?? '',
      date: map['date'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'event_type': service,
      'location': venue,
      'booking_status': status,
      'full_name': name,
      'phone': phoneNumber,
      'time': time,
      'date': date,
    };
  }

  BookingListModel copyWith({
    String? name,
    String? venue,
    String? phoneNumber,
    String? service,
    String? time,
    String? date,
    String? status,
  }) {
    return BookingListModel(
      name: name ?? this.name,
      venue: venue ?? this.venue,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      service: service ?? this.service,
      time: time ?? this.time,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}

//Kamohelo P testing model for booking list screen

enum BookingStatus {
  pending('pending', 'Pending'),
  confirmed('confirmed', 'Confirmed'),
  declined('declined', 'Declined'),
  cancelled('cancelled', 'Cancelled'),
  completed('completed', 'Completed'),
  unknown('', 'Unknown');

  const BookingStatus(this.dbValue, this.label);
  final String dbValue;
  final String label;

  static BookingStatus parse(String? v) => BookingStatus.values.firstWhere(
    (s) => s.dbValue == v && s != BookingStatus.unknown,
    orElse: () => BookingStatus.unknown,
  );
}

DateTime _at(DateTime day, String hhmm) {
  final p = hhmm.split(':');
  return DateTime(
    day.year,
    day.month,
    day.day,
    int.parse(p[0]),
    int.parse(p[1]),
  );
}

/// One row of booking_slot joined with its time_slot.
@immutable
class BookedSlot {
  final String bookingSlotId;
  final String timeSlotId;
  final DateTime date; // date only
  final String start; // "09:00"
  final String end;
  final String selectionStatus; // held | confirmed | released
  final DateTime? expiresAt;

  const BookedSlot({
    required this.bookingSlotId,
    required this.timeSlotId,
    required this.date,
    required this.start,
    required this.end,
    required this.selectionStatus,
    this.expiresAt,
  });

  bool get isReleased => selectionStatus == 'released';
  DateTime get startsAt => _at(date, start);
  DateTime get endsAt => _at(date, end);

  /// Returns null when the time_slot couldn't be read, so one bad row
  /// doesn't take the whole booking down.
  static BookedSlot? tryFromJson(Map<String, dynamic> j) {
    final ts = j['time_slot'] as Map<String, dynamic>?;
    if (ts == null) return null;
    final d = DateTime.parse(ts['slot_date'] as String);
    return BookedSlot(
      bookingSlotId: j['booking_slot_id'].toString(),
      timeSlotId: j['time_slot_id'].toString(),
      date: DateTime(d.year, d.month, d.day),
      start: (ts['start_time'] as String).substring(0, 5),
      end: (ts['end_time'] as String).substring(0, 5),
      selectionStatus: (j['selection_status'] as String?) ?? 'held',
      expiresAt: j['expires_at'] == null
          ? null
          : DateTime.parse(j['expires_at'] as String).toLocal(),
    );
  }
}

/// Back-to-back slots merged into one range (09:00–10:00 + 10:00–11:00 = 09:00–11:00).
@immutable
class TimeBlock {
  final DateTime date;
  final String start;
  final String end;
  const TimeBlock(this.date, this.start, this.end);

  DateTime get startsAt => _at(date, start);
  DateTime get endsAt => _at(date, end);
  int get minutes => endsAt.difference(startsAt).inMinutes;
}

@immutable
class BookingList {
  final String id;
  final String clientId;
  final String serviceId;
  final String eventType;
  final double? budget;
  final String requirements;
  final int numberOfPeople;
  final String location;
  final bool termsAccepted;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data (not columns of booking itself)
  final String? clientName;
  final String? clientEmail;
  final String? clientPhone;
  final String? serviceName;
  final List<BookedSlot> slots; // sorted by start time

  const BookingList({
    required this.id,
    required this.clientId,
    required this.serviceId,
    required this.eventType,
    required this.budget,
    required this.requirements,
    required this.numberOfPeople,
    required this.location,
    required this.termsAccepted,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.clientName,
    this.clientEmail,
    this.clientPhone,
    this.serviceName,
    this.slots = const [],
  });

  factory BookingList.fromJson(Map<String, dynamic> j) {
    final user =
        (j['client'] as Map<String, dynamic>?)?['user']
            as Map<String, dynamic>?;
    final service = j['service'] as Map<String, dynamic>?;

    final slots =
        ((j['booking_slot'] as List?) ?? const [])
            .map((e) => BookedSlot.tryFromJson(e as Map<String, dynamic>))
            .whereType<BookedSlot>()
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    return BookingList(
      id: j['booking_id'].toString(),
      clientId: j['client_id'].toString(),
      serviceId: j['service_id'].toString(),
      eventType: (j['event_type'] as String?) ?? '',
      budget: j['budget'] == null
          ? null
          : double.tryParse(j['budget'].toString()),
      requirements: (j['requirements'] as String?) ?? '',
      numberOfPeople: (j['number_of_people'] as num?)?.toInt() ?? 0,
      location: (j['location'] as String?) ?? '',
      termsAccepted: j['terms_accepted'] == true,
      status: BookingStatus.parse(j['booking_status'] as String?),
      createdAt: DateTime.parse(j['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(j['updated_at'] as String).toLocal(),
      clientName: user?['full_name'] as String?,
      clientEmail: user?['email'] as String?,
      clientPhone: user?['phone'] as String?,
      serviceName: service?['service_name'] as String?,
      slots: slots,
    );
  }

  // ---- derived values ----

  String get displayName => (clientName?.trim().isNotEmpty ?? false)
      ? clientName!.trim()
      : 'Unknown client';

  /// Time ranges the booking occupies. Released slots only count when nothing else is left
  /// (so a declined booking still shows what was asked for).
  List<TimeBlock> get blocks {
    final active = slots.where((s) => !s.isReleased).toList();
    final src = active.isEmpty ? slots : active;
    final out = <TimeBlock>[];
    for (final s in src) {
      final last = out.isEmpty ? null : out.last;
      if (last != null && last.date == s.date && last.end == s.start) {
        out[out.length - 1] = TimeBlock(last.date, last.start, s.end);
      } else {
        out.add(TimeBlock(s.date, s.start, s.end));
      }
    }
    return out;
  }

  DateTime? get firstStart => blocks.isEmpty ? null : blocks.first.startsAt;
  DateTime? get lastEnd => blocks.isEmpty ? null : blocks.last.endsAt;
  int get totalMinutes => blocks.fold(0, (sum, b) => sum + b.minutes);

  /// When a pending request's slot hold runs out (null if none recorded).
  DateTime? get holdExpiresAt {
    if (status != BookingStatus.pending) return null;
    final times =
        slots
            .where((s) => s.selectionStatus == 'held' && s.expiresAt != null)
            .map((s) => s.expiresAt!)
            .toList()
          ..sort();
    return times.isEmpty ? null : times.first;
  }

  // ---- which actions the admin may take (single source of truth for the UI) ----

  bool get canConfirm => status == BookingStatus.pending && slots.isNotEmpty;
  bool get canDecline => status == BookingStatus.pending;
  bool get canCancel =>
      status == BookingStatus.confirmed &&
      (lastEnd == null || lastEnd!.isAfter(DateTime.now()));
  bool get canComplete =>
      status == BookingStatus.confirmed &&
      firstStart != null &&
      !firstStart!.isAfter(DateTime.now());

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      displayName,
      clientEmail,
      clientPhone,
      serviceName,
      eventType,
      location,
      id,
    ].any((v) => (v ?? '').toLowerCase().contains(q));
  }
}
