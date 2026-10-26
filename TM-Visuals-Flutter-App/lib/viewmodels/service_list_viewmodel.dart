import 'package:flutter/material.dart';
import 'package:photography_flutter_application/models/service_list_model.dart';

class ServiceViewModel extends ChangeNotifier {
  final List<ServicesListModel> _services = [];

  List<ServicesListModel> get services => _services;

  void addNewService(ServicesListModel newService) {
    _services.add(newService);
    notifyListeners();
  }

  void editService(int index, ServicesListModel updatedService) {
    _services[index] = updatedService;
    notifyListeners();
  }

  void deleteService(ServicesListModel service) {
    _services.remove(service);
    notifyListeners();
  }
}
