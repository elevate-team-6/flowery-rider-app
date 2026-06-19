import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/widgets/email_step_widget.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/widgets/otp_step_widget.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/widgets/reset_password_step_widget.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../core/utils/app_routes.dart';
import '../../../../core/utils/app_strings.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with UiEventHandler {
  final PageController _pageController = PageController();
  StreamSubscription<BaseUiEvent>? _uiEventSubscription;
  String _email = '';

  @override
  void initState() {
    super.initState();
    _uiEventSubscription = context
        .read<ForgetPasswordCubit>()
        .eventStream
        .listen(_handleLocalUiEvent);
  }

  void _handleLocalUiEvent(BaseUiEvent event) {
    if (event is NavigateEvent) {
      if (event.routeName == AppRoutes.verifyResetCode) {
        _email = event.arguments as String;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      } else if (event.routeName == AppRoutes.resetPassword) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }
    }
    handleUiEvent(event);
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (_pageController.page == 0) {
              Navigator.pop(context);
            } else {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(AppStrings.password.tr()),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          const EmailStepWidget(),
          OtpStepWidget(email: _email),
          ResetPasswordStepWidget(email: _email),
        ],
      ),
    );
  }
}
