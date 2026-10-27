import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photography_flutter_application/models/service_list_model.dart';
import 'package:photography_flutter_application/viewmodels/service_list_viewmodel.dart';
import 'package:photography_flutter_application/views/edit_service.dart';

class ServiceDetailsView extends StatelessWidget {
  final ServicesListModel service;
  const ServiceDetailsView({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Service Details",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [],
                    ),
                    const Divider(
                      color: Color.fromARGB(31, 104, 103, 103),
                      height: 24,
                    ),

                    const Text(
                      'Service:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),

                    Text(
                      service.serviceName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      "Description:",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),

                    Text(
                      service.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 14),

                    const Text(
                      'Created At:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.dateTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),
                    ServiceStatusDropdown(initialStatus: service.availability),
                    const SizedBox(height: 16),

                    const Divider(color: Colors.grey),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // CHANGED: EDIT now opens the edit screen
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditServiceView(service: service),
                              ),
                            );
                          },
                          child: const Text("EDIT"),
                        ),
                        
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete service?'),
                                content: Text(
                                  'Delete "${service.serviceName}"? This cannot be undone.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm != true || !context.mounted) return;

                            try {
                              await context
                                  .read<ServiceViewModel>()
                                  .deleteService(service);
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Could not delete: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text("DELETE"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // end container
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceStatusDropdown extends StatefulWidget {
  final String initialStatus;

  const ServiceStatusDropdown({super.key, required this.initialStatus});

  @override
  State<ServiceStatusDropdown> createState() => _ServiceStatusDropdownState();
}

class _ServiceStatusDropdownState extends State<ServiceStatusDropdown> {
  late String selectedStatus;

  final List<String> availabilities = ["Available", "Unavailable"];

  @override
  void initState() {
    super.initState();
    selectedStatus = availabilities.contains(widget.initialStatus)
        ? widget.initialStatus
        : availabilities.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedStatus,
      dropdownColor: const Color.fromARGB(255, 46, 46, 46),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: "Booking Status",
        labelStyle: const TextStyle(color: Colors.orange),
        filled: true,
        fillColor: Colors.black,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.orange),
        ),
      ),
      items: availabilities.map((status) {
        return DropdownMenuItem<String>(value: status, child: Text(status));
      }).toList(),
      onChanged: (newStatus) {
        if (newStatus != null) {
          setState(() {
            selectedStatus = newStatus;
          });
        }
      },
    );
  }
}
