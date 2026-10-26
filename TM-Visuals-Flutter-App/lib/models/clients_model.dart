class Clients{
  final String name;
  final String previousBookings;
  final String lastBooking;

  Clients({
    required this.name,
    required this.previousBookings,
    required this.lastBooking
  });

  factory Clients.fromMap(Map<String, dynamic> map) {
    return Clients(
      
      name:        map['full_name'] ?? '',        
      previousBookings: map['previous_bookings'] ?? '',            
      lastBooking:        map['last_booking'] ?? '',                          
    );
  }

  Map<String, dynamic> toMap() {
    return {
      
      'full_name':      name,
      'previous_bookings':          previousBookings,
      'last_booking':           lastBooking,
    };
  }

  Clients copyWith({
    String? name,
    String? previousBookings,
    String? lastBookings,
  }) {
    return Clients(
      name: name ?? this.name,
      previousBookings: previousBookings ?? this.previousBookings,
      lastBooking: lastBooking ?? this.lastBooking,
      );
  }
}
