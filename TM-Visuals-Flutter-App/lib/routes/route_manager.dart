import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/views/portfolio_content.dart';
import '/viewmodels/portfolio_view_model.dart';

class Routes {
  static const String portfolioContent = '/portfolio-content';
}

class RouteManager {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.portfolioContent:
        return MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => PortfolioViewModel(),
            child: const PortfolioContentScreen(),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route Not Found')),
          ),
        );
    }
  }
}
