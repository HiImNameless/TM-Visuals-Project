class ServicesListModel {
  final String id;
  final String serviceName;
  final String description;
  final String dateTime;
  final String availability;

  ServicesListModel({
    this.id = '',
    required this.serviceName,
    required this.description,
    required this.dateTime,
    required this.availability,
  });
  factory ServicesListModel.fromMap(Map<String, dynamic> map) {
    final active = map['is_active'];
    return ServicesListModel(
      id: (map['service_id'] ?? '').toString(),
      serviceName: (map['service_name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      dateTime: (map['created_at'] ?? '').toString(),
      availability: active == true || active == 'true'
          ? 'Available'
          : 'Unavailable',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service_name': serviceName,
      'description': description,
      'is_active': availability == 'Available',
    };
  }

  ServicesListModel copyWith({
    String? id,
    String? serviceName,
    String? description,

    String? dateTime,
    String? availability,
  }) {
    return ServicesListModel(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      availability: availability ?? this.availability,
    );
  }
}
