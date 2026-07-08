import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/widgets/custom_rich_text_with_link.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_events.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/app_text_styles.dart';

class OtpStepWidget extends StatelessWidget {
  final String email;
  const OtpStepWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          Text(
            AppStrings.emailVerification.tr(),
            style: AppTextStyles.black18500,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 44.w),
            child: Text(
              AppStrings.emailVerificationSubtitle.tr(),
              style: AppTextStyles.black13400,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 32.h),
          BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
            buildWhen: (previous, current) {
              return previous.verifyResetCodeState !=
                  current.verifyResetCodeState;
            },
            builder: (context, state) {
              final isError = state.verifyResetCodeState.errorMessage != null;
              return Column(
                children: [
                  PinCodeTextField(
                    appContext: context,
                    length: 6,
                    onChanged: (value) {},
                    onCompleted: (value) {
                      if (!state.verifyResetCodeState.isLoading) {
                        context.read<ForgetPasswordCubit>().doEvent(
                          VerifyResetCodeEvent(resetCode: value, email: email),
                        );
                      }
                    },
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.scale,
                    animationDuration: const Duration(milliseconds: 200),
                    textStyle: AppTextStyles.black20500,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(10.r),
                      fieldHeight: 55.h,
                      fieldWidth: 55.w,
                      activeFillColor: AppColors.white60,
                      inactiveFillColor: AppColors.white60,
                      selectedFillColor: AppColors.white,
                      activeColor: isError
                          ? AppColors.error
                          : AppColors.white60,
                      inactiveColor: isError
                          ? AppColors.error
                          : AppColors.white60,
                      selectedColor: isError
                          ? AppColors.error
                          : AppColors.primary,
                      borderWidth: 1.5,
                    ),
                    enableActiveFill: true,
                    cursorColor: AppColors.primary,
                  ),
                  if (isError) ...[
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            state.verifyResetCodeState.errorMessage!,
                            style: AppTextStyles.black13400.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          SizedBox(height: 24.h),
          CustomRichTextWithLink(
            normalText: AppStrings.didntReceiveCode.tr(),
            linkText: AppStrings.resend.tr(),
            onLinkTap: () {
              context.read<ForgetPasswordCubit>().doEvent(
                ForgetPasswordEvent(email: email),
              );
            },
            linkTextColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
