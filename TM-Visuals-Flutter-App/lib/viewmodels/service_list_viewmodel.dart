import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_list_model.dart';
import '../services/service_service.dart';

class ServiceViewModel extends ChangeNotifier {
  ServiceViewModel({ServiceService? service})
    : _service = service ?? ServiceService();

  final ServiceService _service;
  List<ServicesListModel> _services = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<ServicesListModel> get services => List.unmodifiable(_services);
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> loadServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _services = await _service.fetchServices();
    } catch (error) {
      debugPrint('Service list error: $error');
      _errorMessage = error is PostgrestException && error.code == '42501'
          ? 'You do not have permission to view services.'
          : 'Could not load services. Check your connection and try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ServicesListModel> addService({
    required String serviceName,
    required String description,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final service = await _service.addService(
        serviceName: serviceName,
        description: description,
      );
      _services = [service, ..._services];
      return service;
    } catch (error) {
      debugPrint('Add service error: $error');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<ServicesListModel> updateService(ServicesListModel service) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final updated = await _service.updateService(service);
      final index = _services.indexWhere((item) => item.id == updated.id);
      if (index >= 0) _services[index] = updated;
      return updated;
    } catch (error) {
      debugPrint('Update service error: $error');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteService(String serviceId) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.deleteService(serviceId);
      _services.removeWhere((service) => service.id == serviceId);
    } catch (error) {
      debugPrint('Delete service error: $error');
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
