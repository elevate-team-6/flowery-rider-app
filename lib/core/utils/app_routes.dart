import 'package:flowery_rider_app/config/di/di.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String login = 'login';
  static const String home = 'home';

  static MaterialPageRoute<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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

      case home:
        return MaterialPageRoute(
          builder: (BuildContext context) {
            return const Scaffold(body: Center(child: Text('Home')));
          },
        );

      default:
        return _unDefinedRoute(settings.name);
    }
  }

  static MaterialPageRoute<dynamic> _unDefinedRoute(String? name) {
    return MaterialPageRoute(
      builder: (_) =>
          Scaffold(body: Center(child: Text('No route defined for $name'))),
    );
  }
}
