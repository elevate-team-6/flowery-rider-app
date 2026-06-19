import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:flowery_rider_app/config/validations/app_validations.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with UiEventHandler {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  StreamSubscription<BaseUiEvent>? _sideEffectSubscription;

  @override
  void initState() {
    super.initState();
    _sideEffectSubscription = context.read<LoginCubit>().eventStream.listen(
      handleUiEvent,
    );
    context.read<LoginCubit>().doIntent(const LoadRememberedEmailEvent());
  }

  @override
  void dispose() {
    _sideEffectSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void onFillTextField(String text) {
    _emailController.text = text;
  }

  void _onLoginPressed() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    context.read<LoginCubit>().doIntent(
      LoginEvent(
        SignInRequestModel(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      ),
    );
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
                  formKey: _formKey,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  onForgetPasswordTap: () {
                    Navigator.pushNamed(context, AppRoutes.forgetPassword);
                  },
                ),
                SizedBox(height: 32.h),
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _emailController,
                    _passwordController,
                  ]),
                  builder: (context, child) {
                    final isFormValid =
                        AppValidations.validateEmail(_emailController.text) ==
                            null &&
                        AppValidations.validatePassword(
                              _passwordController.text,
                            ) ==
                            null;

                    return ElevatedButton(
                      onPressed: isFormValid ? _onLoginPressed : null,
                      child: child,
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
}
