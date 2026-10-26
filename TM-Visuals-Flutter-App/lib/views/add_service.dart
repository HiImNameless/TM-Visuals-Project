import 'package:flutter/material.dart';

class AddServiceView extends StatefulWidget {
  const AddServiceView({super.key});

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
