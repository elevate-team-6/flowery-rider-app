import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/widgets/custom_flower_loading.dart';
import 'package:flowery_rider_app/core/widgets/custom_snack_bar.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_side_effect.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  StreamSubscription<LoginSideEffect>? _sideEffectSubscription;

  @override
  void initState() {
    super.initState();
    _sideEffectSubscription = context.read<LoginCubit>().sideEffects.listen(
      _handleSideEffect,
    );
  }

  @override
  void dispose() {
    _sideEffectSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.login.tr())),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LoginForm(
                  onForgetPasswordTap: () {
                    // TODO: navigate to forget password screen.
                  },
                ),
                SizedBox(height: 32.h),
                ElevatedButton(
                  onPressed: () {
                    final viewModel = context.read<LoginCubit>();
                    viewModel.doIntent(
                      LoginEvent(
                        SignInRequestModel(
                          email: viewModel.emailController.text.trim(),
                          password: viewModel.passwordController.text,
                        ),
                      ),
                    );
                  },
                  child: Text(AppStrings.continueText.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSideEffect(LoginSideEffect effect) {
    switch (effect) {
      case ShowLoadingEffect():
        LoadingDialog.show(context: context);
      case HideLoadingEffect():
        LoadingDialog.hide(context: context);
      case LoginSuccessEffect():
        CustomSnackBar.showSuccessMessage(AppStrings.loginSuccess.tr());
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.mainLayout, (route) => false);
      case LoginFailureEffect(:final message):
        CustomSnackBar.showErrorMessage(
          message ?? AppStrings.defaultError.tr(),
        );
    }
  }
}
