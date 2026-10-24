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
     
      service:     map['event_type'] ?? '',       
      venue:       map['location'] ?? '',         
      status:      map['booking_status'] ?? '',   
      name:        map['full_name'] ?? '',        
      phoneNumber: map['phone'] ?? '',            
      time:        map['time'] ?? '',             
      date:        map['date'] ?? '',             
    );
  }

  Map<String, dynamic> toMap() {
    return {
      
      'event_type':     service,
      'location':       venue,
      'booking_status': status,
      'full_name':      name,
      'phone':          phoneNumber,
      'time':           time,
      'date':           date,
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
