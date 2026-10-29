import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/portfolio_model.dart';

class PortfolioGalleryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<PortfolioCategory>> fetchCategories() async {
    final response = await _supabase
        .from('portfolio_category')
        .select('category_id, category_name')
        .order('category_name');

    return response
        .map<PortfolioCategory>(
          (item) => PortfolioCategory.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<List<PortfolioItem>> fetchItems({String? categoryId}) async {
    var query = _supabase
        .from('portfolio_item')
        .select('media_id, admin_id, category_id, title, media_location, media_type');

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.eq('category_id', categoryId);
    }

    final response = await query.order('title');

    return response
        .map<PortfolioItem>(
          (item) => PortfolioItem.fromMap(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<void> deleteItem(PortfolioItem item) async {
    if (item.id == null || item.id!.isEmpty) {
      throw const PortfolioError('No portfolio item selected.');
    }

    await _supabase
        .from('portfolio_item')
        .delete()
        .eq('media_id', item.id!);
  }
}
