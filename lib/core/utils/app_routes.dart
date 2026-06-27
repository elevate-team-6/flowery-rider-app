import 'package:flowery_rider_app/config/di/di.dart';
import 'package:flowery_rider_app/core/entities/driver_entity.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/apply_page.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/success_apply_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:flowery_rider_app/features/mainLayout/presentation/main_layout.dart';
import 'package:flowery_rider_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_profile_view_model/edit_profile_cubit.dart';
import 'package:flowery_rider_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String onboarding = 'onboarding';
  static const String login = '/login';
  static const String applyScreen = 'apply';
  static const String submit = 'submit';
  static const String mainLayout = 'mainLayout';
  static const String forgetPassword = '/forgotPassword';
  static const String verifyResetCode = '/VerifyResetCode';
  static const String resetPassword = '/resetPassword';
  static const String orderDetails = 'orderDetails';
  static const String editProfile = 'editProfile';
  // TODO(team): add the route case below when the Change Password screen is ready.
  static const String changePassword = 'changePassword';

  static MaterialPageRoute<dynamic> onGenerateRoute(RouteSettings settings) {
    try {
      switch (settings.name) {
        case splash:
          return MaterialPageRoute(
            builder: (_) => const SplashScreen(),
            settings: settings,
          );

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
            settings: settings,
          );
        case applyScreen:
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => getIt<ApplyCubit>(),
              child: const ApplyPage(),
            ),
          );
        case submit:
          return MaterialPageRoute(builder: (_) => const SuccessApplyScreen());
        case mainLayout:
          return MaterialPageRoute(
            builder: (_) => const MainLayout(),
            settings: settings,
          );

        case forgetPassword:
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => getIt<ForgetPasswordCubit>(),
              child: const ForgotPasswordScreen(),
            ),
            settings: settings,
          );

        case editProfile:
          final driver = settings.arguments as DriverEntity;
          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => getIt<EditProfileCubit>(),
              child: EditProfileScreen(driver: driver),
            ),
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
