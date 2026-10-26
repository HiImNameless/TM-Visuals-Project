import 'package:flutter/material.dart';
import 'package:photography_flutter_application/viewmodels/bookingList_viewmodel.dart';
import 'package:provider/provider.dart';
import '/views/portfolio_content.dart';
import '/viewmodels/portfolio_view_model.dart';
import '/views/bookings.dart';
import '/views/booking_details.dart';
import '/views/admin_settings_screen.dart';

class Routes {
  static const String portfolioContent = '/portfolio-content';
  static const String bookings = '/bookings';
  static const String bookingDetails = '/booking-details';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminProfile = '/admin-profile';
  static const String adminSettings = '/admin-settings';
  static const String calendar = '/calendar';
  static const String clientsList = '/clients-list';
  static const String invoices = '/invoices';
  static const String login = '/login';
  static const String register = '/register';
}

class RouteManager {
  static const String portfolioContent = '/portfolio-content';

  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case portfolioContent:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => PortfolioViewModel(),
            child: const PortfolioContentScreen(),
          ),
        );

      case Routes.bookings:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => BookingsViewModel(),
            child: const BookingsScreen(),
          ),
        );

      case Routes.bookingDetails:
        final bookingId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BookingDetailScreen(bookingId: bookingId),
        );

      /*case Routes.adminDashboard:
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        );*/

      /* case Routes.adminProfile:
        return MaterialPageRoute(
          builder: (_) => const AdminProfileScreen(),
        );*/

      case Routes.adminSettings:
        return MaterialPageRoute(builder: (_) => AdminSettingsScreen());

      /* case Routes.calendar:
        return MaterialPageRoute(
          builder: (_) => const CalendarScreen(),
        );

      case Routes.clientsList:
        return MaterialPageRoute(
          builder: (_) => const/* ClientsListScreen()*/,
        );

      case Routes.invoices:
        return MaterialPageRoute(
          builder: (_) => const/* InvoicesScreen()*/,
        );

      case Routes.login:
        return MaterialPageRoute(
          builder: (_) => const/* LoginScreen()*/,
        );

      case Routes.register:
      return MaterialPageRoute(
        builder: (_) => const/* RegisterScreen()*/,
        );*/

      default:
        return MaterialPageRoute(
          builder: (_) => const BookingsScreen(),
        ); //AdminDashboardScreen());
    }
  }
}
