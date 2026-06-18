import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:flowery_rider_app/core/widgets/custom_text_field.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../config/validations/app_validations.dart';
import '../../../../core/utils/app_strings.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with UiEventHandler {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final resetFormKey = GlobalKey<FormState>();
  late final ForgetPasswordCubit _cubit;
  StreamSubscription<BaseUiEvent>? _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ForgetPasswordCubit>();
    _uiEventSubscription = _cubit.eventStream.listen(handleUiEvent);
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(AppStrings.password.tr()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: resetFormKey,
          child: Column(
            children: [
              SizedBox(height: 24),
              Text(
                AppStrings.resetPasswordTitle.tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  AppStrings.resetPasswordSubtitle.tr(),
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 32),
              CustomTextField(
                controller: passwordController,
                labelText: AppStrings.newPassword.tr(),
                hintText: AppStrings.enterYourPassword.tr(),
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: (value) => AppValidations.validatePassword(value),
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: confirmPasswordController,
                labelText: AppStrings.confirmPassword.tr(),
                hintText: AppStrings.confirmPassword.tr(),
                obscureText: true,
                textInputAction: TextInputAction.done,
                validator: (value) => AppValidations.validateConfirmPassword(
                  value,
                  passwordController.text,
                ),
              ),

              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (resetFormKey.currentState!.validate()) {
                    context.read<ForgetPasswordCubit>().doEvent(
                      ResetPasswordEvent(
                        email: widget.email,
                        newPassword: passwordController.text,
                      ),
                    );
                  }
                },
                child: Text(AppStrings.continueText.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
