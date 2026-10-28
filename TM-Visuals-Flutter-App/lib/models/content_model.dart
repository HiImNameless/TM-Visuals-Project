/// Thrown for problems we can explain to the user in plain words.
class ContentError implements Exception {
  const ContentError(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One row of the client_content table: a private Google Drive link
/// delivered to a client for a booking.
class ContentModel {
  final String contentId;
  final String bookingId;
  final String title;
  final String deliveryLink;
  final String uploadedAt;
  final String eventType;
  final String clientName;

  ContentModel({
    required this.contentId,
    required this.bookingId,
    required this.title,
    required this.deliveryLink,
    required this.uploadedAt,
    this.eventType = '',
    this.clientName = '',
  });

  factory ContentModel.fromMap(Map<String, dynamic> map) {
    final booking = map['booking'] is Map
        ? Map<String, dynamic>.from(map['booking'])
        : <String, dynamic>{};

    final client = booking['client'] is Map
        ? Map<String, dynamic>.from(booking['client'])
        : <String, dynamic>{};

    final profile = client['user_profile'] is Map
        ? Map<String, dynamic>.from(client['user_profile'])
        : <String, dynamic>{};

    final uploaded = (map['uploaded_at'] ?? '').toString();

    return ContentModel(
      contentId: (map['content_id'] ?? '').toString(),
      bookingId: (map['booking_id'] ?? '').toString(),
      title: map['title'] ?? 'Delivery',
      deliveryLink: map['delivery_link'] ?? '',
      uploadedAt: uploaded.length >= 10 ? uploaded.substring(0, 10) : uploaded,
      eventType: booking['event_type'] ?? '',
      clientName: profile['full_name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'booking_id': bookingId,
      'title': title,
      'delivery_link': deliveryLink,
    };
  }

  ContentModel copyWith({
    String? contentId,
    String? bookingId,
    String? title,
    String? deliveryLink,
    String? uploadedAt,
    String? eventType,
    String? clientName,
  }) {
    return ContentModel(
      contentId: contentId ?? this.contentId,
      bookingId: bookingId ?? this.bookingId,
      title: title ?? this.title,
      deliveryLink: deliveryLink ?? this.deliveryLink,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      eventType: eventType ?? this.eventType,
      clientName: clientName ?? this.clientName,
    );
  }
}

/// A booking the administrator can add content to (shown in the dropdown).
class ContentBookingOption {
  final String bookingId;
  final String eventType;
  final String status;
  final String clientName;

  ContentBookingOption({
    required this.bookingId,
    required this.eventType,
    required this.status,
    required this.clientName,
  });

  factory ContentBookingOption.fromMap(Map<String, dynamic> map) {
    final client = map['client'] is Map
        ? Map<String, dynamic>.from(map['client'])
        : <String, dynamic>{};

    final profile = client['user_profile'] is Map
        ? Map<String, dynamic>.from(client['user_profile'])
        : <String, dynamic>{};

    return ContentBookingOption(
      bookingId: (map['booking_id'] ?? '').toString(),
      eventType: map['event_type'] ?? '',
      status: map['booking_status'] ?? '',
      clientName: profile['full_name'] ?? '',
    );
  }

  String get label => '$eventType - $clientName ($status)';
}
