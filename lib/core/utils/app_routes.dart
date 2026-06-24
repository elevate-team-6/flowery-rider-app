import 'package:flowery_rider_app/config/di/di.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:flowery_rider_app/features/mainLayout/presentation/main_layout.dart';
import 'package:flowery_rider_app/features/splash/presentation/pages/splash_screen.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/order_details_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/screens/order_success_screen.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String splash = '/';
  static const String onboarding = 'onboarding';
  static const String login = '/login';
  static const String applyScreen = 'apply';
  static const String mainLayout = 'mainLayout';
  static const String forgetPassword = '/forgotPassword';
  static const String verifyResetCode = '/VerifyResetCode';
  static const String resetPassword = '/resetPassword';
  static const String orderDetails = 'orderDetails';
  static const String orderSuccess = 'orderSuccess';
  static const String mapScreen = 'mapScreen';

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

        case orderDetails:
          OrderEntity order;
          int? initialStep;

          if (settings.arguments is OrderEntity) {
            order = settings.arguments as OrderEntity;
          } else {
            final map = settings.arguments as Map<String, dynamic>;
            order = map[AppKeys.order] as OrderEntity;
            initialStep = map[AppKeys.uiStep] as int?;
          }

          return MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (context) => getIt<OrderDetailsCubit>(),
              child: OrderDetailsScreen(order: order, initialStep: initialStep),
            ),
            settings: settings,
          );

        case orderSuccess:
          return MaterialPageRoute(
            builder: (_) => const OrderSuccessScreen(),
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
