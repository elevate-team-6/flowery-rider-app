import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/widgets/custom_text_field.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/validations/app_validations.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/app_text_styles.dart';

class EmailStepWidget extends StatefulWidget {
  const EmailStepWidget({super.key});

  @override
  State<EmailStepWidget> createState() => _EmailStepWidgetState();
}

class _EmailStepWidgetState extends State<EmailStepWidget> {
  final emailController = TextEditingController();
  final emailFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          Text(
            AppStrings.forgetPasswordTitle.tr(),
            style: AppTextStyles.black18500,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 44.w),
            child: Text(
              AppStrings.forgetPasswordSubtitle.tr(),
              style: AppTextStyles.black14400,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
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
                SizedBox(height: 50.h),
                ElevatedButton(
                  onPressed: () {
                    if (emailFormKey.currentState!.validate()) {
                      context.read<ForgetPasswordCubit>().doEvent(
                        ForgetPasswordEvent(email: emailController.text.trim()),
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
    );
  }
}
