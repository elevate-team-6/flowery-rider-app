import 'package:flowery_rider_app/config/di/di.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/apply_page.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/submit_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String login = 'login';
  static const String apply = '/apply';
  static const String submit = 'submit';
  static MaterialPageRoute<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case apply:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => getIt<ApplyCubit>(),
            child: const ApplyPage(),
          ),
        );
      case submit:
        return MaterialPageRoute(builder: (_) => const SubmitScreen());

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
