class ClientBooking {
  final String id;
  final String eventType;
  final String date;
  final String status;

  const ClientBooking({
    required this.id,
    required this.eventType,
    required this.date,
    required this.status,
  });

  factory ClientBooking.fromMap(Map<String, dynamic> map) {
    return ClientBooking(
      id: (map['booking_id'] ?? map['id'] ?? '').toString(),
      eventType: (map['event_type'] ?? '').toString(),
      date: (map['event_date'] ?? map['date'] ?? map['created_at'] ?? '')
          .toString(),
      status: (map['booking_status'] ?? map['status'] ?? '').toString(),
    );
  }
}

class Clients {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String previousBookings;
  final String lastBooking;
  final List<ClientBooking> bookings;

  Clients({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.previousBookings = '',
    this.lastBooking = '',
    this.bookings = const [],
  });

  factory Clients.fromMap(Map<String, dynamic> map) {
    final userValue = map['user'] ?? map['user_profile'];
    final user = userValue is Map
        ? Map<String, dynamic>.from(userValue)
        : <String, dynamic>{};
    final bookings = map['bookings'] is List
        ? (map['bookings'] as List)
              .whereType<Map>()
              .map(
                (booking) =>
                    ClientBooking.fromMap(Map<String, dynamic>.from(booking)),
              )
              .toList()
        : <ClientBooking>[];

    return Clients(
      id: (map['client_id'] ?? map['id'] ?? '').toString(),
      name: (map['full_name'] ?? user['full_name'] ?? map['name'] ?? '')
          .toString(),
      email: (map['email'] ?? user['email'] ?? '').toString(),
      phone: (map['phone'] ?? user['phone'] ?? '').toString(),
      previousBookings: (map['previous_bookings'] ?? bookings.length)
          .toString(),
      lastBooking:
          (map['last_booking'] ?? (bookings.isEmpty ? '' : bookings.first.date))
              .toString(),
      bookings: bookings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'client_id': id,
      'full_name': name,
      'email': email,
      'phone': phone,
      'previous_bookings': previousBookings,
      'last_booking': lastBooking,
      'bookings': bookings
          .map(
            (b) => {
              'booking_id': b.id,
              'event_type': b.eventType,
              'event_date': b.date,
              'booking_status': b.status,
            },
          )
          .toList(),
    };
  }

  Clients copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? previousBookings,
    String? lastBooking,
    List<ClientBooking>? bookings,
  }) {
    return Clients(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      previousBookings: previousBookings ?? this.previousBookings,
      lastBooking: lastBooking ?? this.lastBooking,
      bookings: bookings ?? this.bookings,
    );
  }
}
