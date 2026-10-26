import 'package:flutter/material.dart';
import '../models/clients_modela.dart';

class ClientsViewModel extends ChangeNotifier {

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // list of clients
  final List<Client> _clients = [
    Client(
      name: "Aubrey jones",
      previousBookings: "Party",
      lastBooking: "Party"
    ),
    Client(
      name:"Sergio Kitchens",
      previousBookings: "Graduation, Wedding",
      lastBooking: "Wedding"
    ),
  ];

  //get clients
  List<Client> get clients => _clients;

  //fetch clients
  Future<void> fetchClients() async {
   _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    _isLoading = false;
    notifyListeners();
  } 

  //add client
  Future<void> addClient(Clients client) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    //check if client already exists
    final alreadyExists = _clients.any(
      (c) => c.name == client.name,
    );
     if (alreadyExists) {
      _errorMessage = 'You Already added this client';
      _isLoading = false;
      notifyListeners();
      return false;
     }

     _clients.add(client);
     _isLoading = false;
     notifyListeners();
     return true;
  }
}
