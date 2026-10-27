import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:photography_flutter_application/models/service_list_model.dart';

class ServiceViewModel extends ChangeNotifier {
  final _client = Supabase.instance.client;

  List<ServicesListModel> _services = [];
  List<ServicesListModel> get services => _services;

  // Loads all services from Supabase (call when the list screen opens)
  Future<void> fetchServices() async {
    final data = await _client.from('services').select().order('created_at');
    _services = data
        .map<ServicesListModel>((e) => ServicesListModel.fromMap(e))
        .toList();
    notifyListeners();
  }

  // Saves a new service to Supabase, then adds it to the local list
  Future<void> addNewService(ServicesListModel newService) async {
    final inserted = await _client
        .from('services')
        .insert(newService.toMap())
        .select()
        .single();
    _services.add(ServicesListModel.fromMap(inserted));
    notifyListeners();
  }

  // Updates a service in Supabase, then updates it in the local list
  Future<void> editService(ServicesListModel updated) async {
    final result = await _client
        .from('services')
        .update(updated.toMap())
        .eq('service_id', updated.serviceId!)
        .select()
        .single();
    final index = _services.indexWhere((s) => s.serviceId == updated.serviceId);
    if (index != -1) _services[index] = ServicesListModel.fromMap(result);
    notifyListeners();
  }

  // Deletes a service from Supabase, then removes it from the local list
  Future<void> deleteService(ServicesListModel service) async {
    await _client.from('services').delete().eq('service_id', service.serviceId!);
    _services.removeWhere((s) => s.serviceId == service.serviceId);
    notifyListeners();
  }
}
