import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/validations/app_validations.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/widgets/custom_text_field.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_state.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/remember_me_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginForm extends StatelessWidget {
  final VoidCallback? onForgetPasswordTap;

  const LoginForm({super.key, this.onForgetPasswordTap});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<LoginCubit>();

    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: viewModel.emailController,
            labelText: AppStrings.email.tr(),
            hintText: AppStrings.enterYourEmail.tr(),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: AppValidations.validateEmail,
          ),
          SizedBox(height: 16.h),
          BlocSelector<LoginCubit, LoginState, bool>(
            selector: (state) => state.obscurePassword,
            builder: (context, isObscured) {
              return CustomTextField(
                controller: viewModel.passwordController,
                labelText: AppStrings.password.tr(),
                hintText: AppStrings.enterYourPassword.tr(),
                obscureText: isObscured,
                textInputAction: TextInputAction.done,
                validator: AppValidations.validatePassword,
                suffixIcon: IconButton(
                  onPressed: () => context.read<LoginCubit>().doIntent(
                    const TogglePasswordVisibilityEvent(),
                  ),
                  icon: Icon(
                    isObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.gray,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 8.h),
          RememberMeRow(onForgetPasswordTap: onForgetPasswordTap),
        ],
      ),
    );
  }
}
