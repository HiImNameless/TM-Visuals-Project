import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/clients_model.dart';
import '../services/clients_service.dart';

class ClientListViewModel extends ChangeNotifier {
  final ClientsService _service = ClientsService();

  bool _isLoading = false;
  String? _errorMessage;
  String _searchText = '';
  List<Clients> _clients = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Clients> get clients => _clients;

  List<Clients> get filteredClients {
    if (_searchText.isEmpty) return _clients;

    final text = _searchText.toLowerCase();
    return _clients
        .where(
          (client) =>
              client.name.toLowerCase().contains(text) ||
              client.email.toLowerCase().contains(text),
        )
        .toList();
  }

  void search(String text) {
    _searchText = text.trim();
    notifyListeners();
  }

  Future<void> fetchClients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _clients = await _service.fetchClients();
    } catch (error) {
      _errorMessage = friendlyError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String friendlyError(Object error) {
    debugPrint('Clients error: $error');

    if (error is PostgrestException) {
      switch (error.code) {
        case '42501':
          return 'You do not have permission to view clients.';
        case 'PGRST116':
          return 'No clients were found.';
      }
    }

    return 'Could not load clients. Please check your connection and try again.';
  }
}
