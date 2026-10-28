import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/clients_model.dart';

class ClientsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Clients>> fetchClients() async {
    final response = await _supabase
        .from('clients')
        .select(
          'client_id, full_name, email, phone, previous_bookings, last_booking',
        );

    return response
        .map<Clients>((item) => Clients.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }
}
