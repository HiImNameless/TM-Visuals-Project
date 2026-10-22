import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'viewmodels/portfolio_view_model.dart';
import 'routes/route_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your test credentials
  await Supabase.initialize(
    url: 'https://YOUR_SUPABASE_PROJECT.supabase.co',
    publishableKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // If you want the ChangeNotifier available globally across the whole app:
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PortfolioViewModel>(
          create: (_) => PortfolioViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'TM Visuals',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        initialRoute: Routes.portfolioContent,
        onGenerateRoute: RouteManager.getRoute,
      ),
    );
  }
}
