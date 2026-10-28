import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/client_list_viewmodel.dart';

class ClientsView extends StatelessWidget {
  const ClientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClientListViewModel()..fetchClients(),
      child: const _ClientsContent(),
    );
  }
}

class _ClientsContent extends StatelessWidget {
  const _ClientsContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ClientListViewModel>();
    final clients = vm.filteredClients;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('TM Visuals', style: TextStyle(color: Colors.orange)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              onChanged: vm.search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search clients...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: vm.isLoading && vm.clients.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    )
                  : vm.errorMessage != null
                      ? Center(
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        )
                      : clients.isEmpty
                          ? const Center(
                              child: Text(
                                'No clients found.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.separated(
                              itemCount: clients.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final client = clients[index];
                                return Card(
                                  color: const Color(0xFF1C1C1C),
                                  child: ListTile(
                                    title: Text(
                                      client.name,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      client.email.isEmpty ? 'No email provided' : client.email,
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                    trailing: const Icon(Icons.chevron_right, color: Colors.orange),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
