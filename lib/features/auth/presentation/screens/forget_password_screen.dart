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
import '../../../../core/utils/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with UiEventHandler {
  final emailController = TextEditingController();
  final emailFormKey = GlobalKey<FormState>();
  StreamSubscription<BaseUiEvent>? _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    _uiEventSubscription = context
        .read<ForgetPasswordCubit>()
        .eventStream
        .listen(handleUiEvent);
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    emailController.dispose();
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 24),
            Text(
              AppStrings.forgetPasswordTitle.tr(),
              style: AppTextStyles.black18500,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                AppStrings.forgetPasswordSubtitle.tr(),
                style: AppTextStyles.black14400,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32),
            Form(
              key: emailFormKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: emailController,
                    labelText: AppStrings.email.tr(),
                    hintText: AppStrings.enterYourEmail.tr(),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: (value) => AppValidations.validateEmail(value),
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: () {
                      if (emailFormKey.currentState!.validate()) {
                        context.read<ForgetPasswordCubit>().doEvent(
                          ForgetPasswordEvent(
                            email: emailController.text.trim(),
                          ),
                        );
                      }
                    },
                    child: Text(AppStrings.confirm.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
