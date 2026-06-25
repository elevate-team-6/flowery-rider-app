import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/widgets/custom_text_field.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/validations/app_validations.dart';
import '../../../../../core/utils/app_strings.dart';

class ResetPasswordStepWidget extends StatefulWidget {
  final String email;

  const ResetPasswordStepWidget({super.key, required this.email});

  @override
  State<ResetPasswordStepWidget> createState() =>
      _ResetPasswordStepWidgetState();
}

class _ResetPasswordStepWidgetState extends State<ResetPasswordStepWidget> {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final resetFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: resetFormKey,
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              AppStrings.resetPasswordTitle.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                AppStrings.resetPasswordSubtitle.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
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
            const SizedBox(height: 40),
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
    );
  }
}
