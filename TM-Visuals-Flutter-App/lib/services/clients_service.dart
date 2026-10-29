import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/clients_model.dart';

class ClientsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Clients>> fetchClients() async {
    final clientRows = await _supabase
        .from('client')
        .select('client_id,user_id,user:user_id(full_name,email,phone)');
    final bookingRows = await _supabase
        .from('booking')
        .select('booking_id,client_id,event_type,created_at,booking_status')
        .order('created_at', ascending: false);

    final bookingsByClient = <String, List<Map<String, dynamic>>>{};
    for (final booking in bookingRows) {
      final row = Map<String, dynamic>.from(booking);
      final clientId = (row['client_id'] ?? '').toString();
      bookingsByClient.putIfAbsent(clientId, () => []).add({
        'booking_id': row['booking_id'],
        'event_type': row['event_type'],
        'event_date': row['created_at'],
        'booking_status': row['booking_status'],
      });
    }

    return clientRows.map<Clients>((client) {
      final row = Map<String, dynamic>.from(client);
      return Clients.fromMap({
        ...row,
        'bookings': bookingsByClient[(row['client_id'] ?? '').toString()] ?? [],
      });
    }).toList();
  }
}
