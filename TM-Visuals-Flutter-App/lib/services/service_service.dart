import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/service_list_model.dart';

class ServiceService {
  ServiceService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<ServicesListModel>> fetchServices() async {
    final rows = await _client
        .from('service')
        .select('service_id,service_name,description,is_active,created_at')
        .order('created_at', ascending: false);
    return rows
        .map<ServicesListModel>(
          (row) => ServicesListModel.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<ServicesListModel> addService({
    required String serviceName,
    required String description,
  }) async {
    final row = await _client
        .from('service')
        .insert({
          'service_name': serviceName.trim(),
          'description': description.trim(),
          'is_active': true,
        })
        .select('service_id,service_name,description,is_active,created_at')
        .single();
    return ServicesListModel.fromMap(Map<String, dynamic>.from(row));
  }

  Future<ServicesListModel> updateService(ServicesListModel service) async {
    final row = await _client
        .from('service')
        .update(service.toMap())
        .eq('service_id', service.id)
        .select('service_id,service_name,description,is_active,created_at')
        .single();
    return ServicesListModel.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> deleteService(String serviceId) async {
    final deleted = await _client
        .from('service')
        .delete()
        .eq('service_id', serviceId)
        .select('service_id');
    if (deleted.isEmpty) {
      throw StateError('The service was not found or could not be deleted.');
    }
  }
}
