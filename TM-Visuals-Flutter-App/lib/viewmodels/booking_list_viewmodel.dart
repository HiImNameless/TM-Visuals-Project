
import 'package:flutter/material.dart';
import 'package:photography_flutter_application/models/booking_list_model.dart';

class BookingViewModel extends ChangeNotifier {
  
  List<BookingListModel> bookings = [
   
  ];

  
  void addNewBooking(BookingListModel newBooking) {
    bookings.add(newBooking);
    notifyListeners(); 
  }

 
  void editBooking(int index, BookingListModel updatedBooking) {
    bookings[index] = updatedBooking;
    notifyListeners();
  }

  
  void deleteBooking(BookingListModel booking) {
    bookings.remove(booking);
    notifyListeners();
  }
}
