
import 'package:flutter/material.dart';
import 'package:photography_flutter_application/models/booking_list_model.dart';
import 'package:photography_flutter_application/viewmodels/booking_list_viewmodel.dart';
import 'package:photography_flutter_application/views/booking_details.dart';
import 'package:provider/provider.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  @override
  Widget build(BuildContext context) {
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
                      child: Selector<BookingViewModel, List<BookingListModel>>(
                        selector: (context, viewModel) => viewModel.bookings,
                        builder: (context, bookingsList, child) {
                          return ListView.builder(
                            itemCount: bookingsList.length,
                            itemBuilder: (context, index) {
                              final item = bookingsList[index];
                              return Card(
                                color: Colors.black,
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
                                            BookingDetailsListScreen(
                                              booking: item,
                                            ),
                                      ),
                                    );
                                  },
                                  title: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.venue,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        item.time,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                                  trailing: Text(
                                    item.status,
                                    style: TextStyle(
                                      color: item.status == "Approved"
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.orange,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.black,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 26),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book, size: 26),
                label: "Bookings",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month, size: 26),
                label: "Calendar",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 26),
                label: "Profile",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore, size: 26),
                label: "Explore",
              ),
            ],
          ),
        ],
      ),
    );
  }
}
