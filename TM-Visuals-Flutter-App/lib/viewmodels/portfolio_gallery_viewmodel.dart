import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/portfolio_model.dart';
import '../services/portfolio_gallery_service.dart';

class PortfolioGalleryViewModel extends ChangeNotifier {
  final PortfolioGalleryService _service = PortfolioGalleryService();

  List<PortfolioItem> items = [];
  List<PortfolioCategory> categories = [];
  String? selectedCategoryId;

  bool isLoading = true;
  bool isDeleting = false;
  String? errorMessage;

  Future<void> loadGallery() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      categories = await _service.fetchCategories();
      items = await _service.fetchItems(categoryId: selectedCategoryId);
    } catch (error) {
      errorMessage = friendlyError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCategory(String? categoryId) async {
    selectedCategoryId = categoryId;
    await loadGallery();
  }

  String categoryName(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category.name;
    }
    return '';
  }

  Future<bool> deleteItem(PortfolioItem item) async {
    isDeleting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.deleteItem(item);
      items.removeWhere((i) => i.id == item.id);
      return true;
    } catch (error) {
      errorMessage = friendlyError(error);
      return false;
    } finally {
      isDeleting = false;
      notifyListeners();
    }
  }

  String friendlyError(Object error) {
    debugPrint('Portfolio gallery error: $error');

    if (error is PortfolioError) return error.message;

    if (error is PostgrestException) {
      switch (error.code) {
        case '42501':
          return 'You do not have permission to do that.';
        case '23503':
          return 'A related record could not be found.';
      }
    }

    return 'Something went wrong. Please check your connection and try again.';
  }
}
