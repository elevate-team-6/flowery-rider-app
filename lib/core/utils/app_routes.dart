import 'package:flowery_rider_app/features/mainLayout/presentation/main_layout.dart';
import 'package:flutter/material.dart';

abstract class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String mainLayout = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  static MaterialPageRoute<dynamic> onGenerateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case mainLayout:
          return MaterialPageRoute(
            builder: (_) => const MainLayout(),
            settings: settings,
          );

        default:
          return _unDefinedRoute(settings.name);
      }
    } catch (e) {
      return _errorRoute(e.toString());
    }
  }

  static MaterialPageRoute<dynamic> _unDefinedRoute(String? name) {
    return MaterialPageRoute(
      builder: (_) =>
          Scaffold(body: Center(child: Text('No route defined for $name'))),
    );
  }

  static MaterialPageRoute<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(
            'Something went wrong\n$message',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
