class ServicesListModel {
  final String serviceName;
  final String description;
  final String dateTime;
  final String availability;

  ServicesListModel({
    required this.serviceName,
    required this.description,
    required this.dateTime,
    required this.availability,
  });
  factory ServicesListModel.fromMap(Map<String, dynamic> map) {
    return ServicesListModel(
      serviceName: map['service_name'] ?? '',
      description: map['description'] ?? '',
      dateTime: map['created_at'] ?? '',
      availability: map['is_active'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'service_name': serviceName,
      'description': description,
      'created_at': dateTime,
      'is_active': availability,
    };
  }

  ServicesListModel copyWith({
    String? serviceName,
    String? description,

    String? dateTime,
    String? availability,
  }) {
    return ServicesListModel(
      serviceName: serviceName ?? this.serviceName,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      availability: availability ?? this.availability,
    );
  }
}
