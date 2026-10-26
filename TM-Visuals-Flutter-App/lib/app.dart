import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'viewmodels/portfolio_view_model.dart';
import 'viewmodels/admin_profile_viewmodel.dart';
import 'viewmodels/invoice_list_viewmodel.dart';
import 'viewmodels/admin_settings_viewmodel.dart';
import 'viewmodels/booking_list_viewmodel.dart';
import 'viewmodels/service_list_viewmodel.dart';
import 'views/admin_entry.dart';
import 'views/supabase_setup.dart';
import 'widgets/admin_widgets.dart';
import 'services/admin_auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.client, this.startupError, this.authService});
  final SupabaseClient? client;
  final Object? startupError;
  final AdminAuthService? authService;
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PortfolioViewModel()),
      ChangeNotifierProvider(create: (_) => AdminProfileViewModel()),
      ChangeNotifierProvider(create: (_) => InvoiceListViewModel()),
      ChangeNotifierProvider(create: (_) => AdminSettingsViewModel()),
      ChangeNotifierProvider(create: (_) => BookingViewModel()),
      ChangeNotifierProvider(create: (_) => ServiceViewModel()),
    ],
    child: MaterialApp(
      title: 'TM Visuals',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: adminGold,
          brightness: Brightness.dark,
          primary: adminGold,
          onPrimary: Colors.black,
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF242424),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF6B5300)),
          ),
        ),
      ),
      home: client == null
          ? SupabaseSetupScreen(error: startupError)
          : AdminEntryScreen(client: client!, service: authService),
    ),
  );
}
