import 'package:flutter/material.dart';
import 'package:photography_flutter_application/models/service_list_model.dart';

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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {},
                          child: Text("EDIT"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.orange,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black, size: 30),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book, color: Colors.black),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month, color: Colors.black),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation, color: Colors.black),
            label: " ",
          ),
        ],
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
