import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/content_model.dart';
import '../services/content_service.dart';

class ContentViewModel extends ChangeNotifier {
  ContentViewModel({ContentService? service})
    : _service = service ?? ContentService();

  final ContentService _service;
  List<ContentModel> _items = [];
  List<ContentBookingOption> _bookings = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<ContentModel> get items => List.unmodifiable(_items);
  List<ContentBookingOption> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadForClient(String clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _items = await _service.fetchForClient(clientId);
    } catch (error) {
      _recordError('Load content', error);
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBookings(String clientId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _bookings = await _service.fetchBookingsForClient(clientId);
    } catch (error) {
      _recordError('Load client bookings', error);
      _errorMessage = _friendlyError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addContent({
    required String bookingId,
    required String title,
    required String deliveryLink,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.addContent(
        bookingId: bookingId,
        title: title,
        deliveryLink: deliveryLink,
      );
    } catch (error) {
      _recordError('Add client content', error);
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateContent({
    required ContentModel content,
    required String title,
    required String deliveryLink,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _service.updateContent(
        content: content,
        title: title,
        deliveryLink: deliveryLink,
      );
      final index = _items.indexWhere(
        (item) => item.contentId == updated.contentId,
      );
      if (index >= 0) _items[index] = updated;
    } catch (error) {
      _recordError('Update client content', error);
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteContent(String contentId) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.deleteContent(contentId);
      _items.removeWhere((item) => item.contentId == contentId);
    } catch (error) {
      _recordError('Delete client content', error);
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _recordError(String action, Object error) {
    debugPrint('$action error: $error');
  }

  String _friendlyError(Object error) {
    if (error is ContentError) return error.message;
    if (error is PostgrestException && error.code == '42501') {
      return 'You do not have permission to manage client content.';
    }
    return 'Could not load client content. Check your connection and try again.';
  }
}
