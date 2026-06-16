import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RememberMeRow extends StatelessWidget {
  final VoidCallback? onForgetPasswordTap;

  const RememberMeRow({super.key, this.onForgetPasswordTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocSelector<LoginCubit, LoginState, bool>(
          selector: (state) => state.rememberMe,
          builder: (context, isChecked) {
            return SizedBox(
              height: 24.h,
              width: 24.w,
              child: Checkbox(
                value: isChecked,
                onChanged: (value) => context.read<LoginCubit>().doIntent(
                  ToggleRememberMeEvent(value ?? false),
                ),
              ),
            );
          },
        ),
        SizedBox(width: 8.w),
        Text(AppStrings.rememberMe.tr(), style: AppTextStyles.black14400),
        const Spacer(),
        GestureDetector(
          onTap: onForgetPasswordTap,
          child: Text(
            AppStrings.forgetPasswordQuestion.tr(),
            style: AppTextStyles.black13400.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
