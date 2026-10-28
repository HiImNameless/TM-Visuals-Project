import 'package:flutter/material.dart';
import 'package:photography_flutter_application/models/service_list_model.dart';
import 'package:photography_flutter_application/viewmodels/service_list_viewmodel.dart';
import 'package:photography_flutter_application/views/add_service.dart';
import 'package:photography_flutter_application/views/service_details.dart';
import 'package:provider/provider.dart';

class ServiceList extends StatefulWidget {
  const ServiceList({super.key});

  @override
  State<ServiceList> createState() => _ServiceListState();
}

class _ServiceListState extends State<ServiceList> {
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceViewModel>().loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiceViewModel>();
    final services = vm.services.where((service) {
      final query = _searchText.toLowerCase();
      return service.serviceName.toLowerCase().contains(query) ||
          service.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Services', style: TextStyle(color: Colors.orange)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchText = value.trim()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
          ),
          Expanded(
            child: vm.isLoading && vm.services.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : vm.errorMessage != null && vm.services.isEmpty
                ? _MessageView(
                    message: vm.errorMessage!,
                    onRetry: vm.loadServices,
                  )
                : services.isEmpty
                ? const Center(
                    child: Text(
                      'No services found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                    itemCount: services.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return _ServiceCard(service: service);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddServiceView()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add service'),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final ServicesListModel service;

  @override
  Widget build(BuildContext context) {
    final available = service.availability == 'Available';
    return Card(
      color: const Color(0xFF1C1C1C),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailsView(service: service),
          ),
        ),
        title: Text(
          service.serviceName,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          service.description.isEmpty ? 'No description' : service.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Text(
          service.availability,
          style: TextStyle(
            color: available ? Colors.green : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
