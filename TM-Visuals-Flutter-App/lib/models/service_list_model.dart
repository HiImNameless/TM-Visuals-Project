class ServicesListModel {
  final String? serviceId;
  final String serviceName;
  final String description;
  final String dateTime;
  final String availability; // "Available" or "Unavailable"

  ServicesListModel({
    this.serviceId,
    required this.serviceName,
    required this.description,
    this.dateTime = '',
    required this.availability,
  });

  factory ServicesListModel.fromMap(Map<String, dynamic> map) {
    final bool isActive = map['is_active'] == true;

    return ServicesListModel(
      serviceId: map['service_id'].toString(),
      serviceName: map['service_name'] ?? '',
      description: map['description'] ?? '',
      dateTime: map['created_at'] ?? '',
      availability: isActive ? 'Available' : 'Unavailable',
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
    String? serviceId,
    String? serviceName,
    String? description,
    String? dateTime,
    String? availability,
  }) {
    return ServicesListModel(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      availability: availability ?? this.availability,
    );
  }
}
