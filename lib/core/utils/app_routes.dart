import 'package:flowery_rider_app/config/di/di.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:flowery_rider_app/features/mainLayout/presentation/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';

abstract class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String applyScreen = 'apply';
  static const String mainLayout = 'mainLayout';

  static MaterialPageRoute<dynamic> onGenerateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case onboarding:
          return MaterialPageRoute(
            builder: (_) => const OnboardingScreen(),
            settings: settings,
          );

        case login:
          return MaterialPageRoute(
            builder: (BuildContext context) {
              return BlocProvider<LoginCubit>(
                create: (_) =>
                    getIt<LoginCubit>()
                      ..doIntent(const LoadRememberedEmailEvent()),
                child: const LoginScreen(),
              );
            },
          );

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
