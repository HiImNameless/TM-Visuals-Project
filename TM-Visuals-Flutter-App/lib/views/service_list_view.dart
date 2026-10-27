import 'package:flutter/material.dart';

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
  // load the services from Supabase when the screen opens
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceViewModel>().fetchServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiceViewModel>(); // NEW

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("TM Visuals", style: TextStyle(color: Colors.orange)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 71, 69, 69),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search...",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                            size: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(color: Colors.orange),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    SizedBox(
                      height: 500,

                      child: ListView.builder(
                        itemCount: vm.services.length,
                        itemBuilder: (context, index) {
                          final item = vm.services[index];
                          return Card(
                            color: const Color.fromARGB(255, 20, 20, 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.orange),
                            ),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ServiceDetailsView(service: item),
                                  ),
                                );
                              },
                              title: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  item.serviceName,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.description,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                item.availability,
                                style: TextStyle(
                                  color: item.availability == "Available"
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow,
              minimumSize: const Size(140, 45),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddServiceView()),
              );
            },
            child: const Text(
              "ADD",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
