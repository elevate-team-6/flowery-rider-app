import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:flowery_rider_app/core/widgets/custom_rich_text_with_link.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_events.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';

class VerifyResetCodeScreen extends StatefulWidget {
  final String email;
  const VerifyResetCodeScreen({super.key, required this.email});

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen>
    with UiEventHandler {
  bool hasError = false;
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
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: 24),
            Text(
              AppStrings.emailVerification.tr(),
              style: AppTextStyles.black18500,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 44),
              child: Text(
                AppStrings.emailVerificationSubtitle.tr(),
                style: AppTextStyles.black13400,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32),
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
                      length: 6, // تم التعديل لـ 6 خانات
                      onChanged: (value) {},
                      onCompleted: (value) {
                        if (!state.verifyResetCodeState.isLoading) {
                          context.read<ForgetPasswordCubit>().doEvent(
                            VerifyResetCodeEvent(
                              resetCode: value,
                              email: widget.email,
                            ),
                          );
                        }
                      },
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.scale,
                      animationDuration: const Duration(milliseconds: 200),
                      textStyle: AppTextStyles.black20500,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(10),
                        fieldHeight: 55,
                        fieldWidth: 55,
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.error,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
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
            SizedBox(height: 24),
            CustomRichTextWithLink(
              normalText: AppStrings.didntReceiveCode.tr(),
              linkText: AppStrings.resend.tr(),
              onLinkTap: () {
                context.read<ForgetPasswordCubit>().doEvent(
                  ForgetPasswordEvent(email: widget.email),
                );
              },
              linkTextColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
