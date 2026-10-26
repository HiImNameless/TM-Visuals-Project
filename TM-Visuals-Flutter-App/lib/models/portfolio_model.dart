/// Thrown for problems we can explain to the user in plain words.
class PortfolioError implements Exception {
  const PortfolioError(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thrown when a category with the same name already exists.
class DuplicateCategoryError extends PortfolioError {
  const DuplicateCategoryError() : super('This category already exists.');
}

/// One row of the portfolio category table.
class PortfolioCategory {
  const PortfolioCategory({required this.id, required this.name});

  final String id; // category_id
  final String name; // category_name

  factory PortfolioCategory.fromMap(Map<String, dynamic> map) {
    return PortfolioCategory(
      id: map['category_id'].toString(),
      name: map['category_name'].toString(),
    );
  }
}

/// One row of the portfolio item table.
class PortfolioItem {
  const PortfolioItem({
  this.id,
  required this.adminId,
  required this.categoryId,
  required this.title,
  required this.mediaLocation,
  required this.mediaType,
}) : assert(
       mediaType == 'image' || mediaType == 'video',
       'mediaType must be image or video',
     );

  /// media_id. Null for a new item: the database creates it.
  final String? id;
  final String adminId;
  final String categoryId;
  final String title;
  final String mediaLocation;

  /// 'image' or 'video' (the database only allows these two values).
  final String mediaType;

  bool get isVideo => mediaType == 'video';

  factory PortfolioItem.fromMap(Map<String, dynamic> map) {
    return PortfolioItem(
      id: map['media_id']?.toString(),
      adminId: map['admin_id'].toString(),
      categoryId: map['category_id'].toString(),
      title: map['title'].toString(),
      mediaLocation: map['media_location'].toString(),
      mediaType: map['media_type'].toString(),
    );
  }

  /// The columns to send when inserting a new row.
  Map<String, dynamic> toInsertMap() {
    return {
      'admin_id': adminId,
      'category_id': categoryId,
      'title': title,
      'media_location': mediaLocation,
      'media_type': mediaType,
    };
  }
}