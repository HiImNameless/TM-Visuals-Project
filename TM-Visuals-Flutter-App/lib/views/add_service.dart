import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photography_flutter_application/models/service_list_model.dart';
import 'package:photography_flutter_application/viewmodels/service_list_viewmodel.dart';

class AddServiceView extends StatefulWidget {
  const AddServiceView({super.key});

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedAvailability = 'Available';

  @override
  void dispose() {
    _serviceNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
                      children: [const Divider(color: Colors.grey, height: 24)],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Service:',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _serviceNameController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Text...",
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Description:",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),

                        Expanded(
                          child: TextField(
                            controller: _descriptionController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            decoration: const InputDecoration(
                              hintText: "Text...",
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedAvailability,
                      dropdownColor: const Color.fromARGB(255, 46, 46, 46),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: "Availability",
                        labelStyle: const TextStyle(color: Colors.orange),
                        filled: true,
                        fillColor: Colors.black,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                      ),
                      items: const ["Available", "Unavailable"]
                          .map(
                            (s) => DropdownMenuItem<String>(
                              value: s,
                              child: Text(s),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null)
                          setState(() => _selectedAvailability = v);
                      },
                    ),

                    SizedBox(height: 20),
                    const Divider(color: Colors.grey),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("CANCEL"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                          ),

                          onPressed: () async {
                            final name = _serviceNameController.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a service name'),
                                ),
                              );
                              return;
                            }
                            try {
                              await context
                                  .read<ServiceViewModel>()
                                  .addNewService(
                                    ServicesListModel(
                                      serviceName: name,
                                      description: _descriptionController.text
                                          .trim(),
                                      availability: _selectedAvailability,
                                    ),
                                  );
                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Could not add service: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text("ADD"),
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
