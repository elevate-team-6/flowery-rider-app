import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/widgets/custom_flower_loading.dart';
import 'package:flowery_rider_app/core/widgets/custom_snack_bar.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.login.tr())),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: BlocListener<LoginCubit, LoginState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: _handleStateChange,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LoginForm(
                    onForgetPasswordTap: () {
                      // TODO(FA6): navigate to forget password screen.
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
      ),
    );
  }

  void _handleStateChange(BuildContext context, LoginState state) {
    if (state.status == LoginStatus.loading) {
      LoadingDialog.show(context: context);
      return;
    }

    LoadingDialog.hide(context: context);

    switch (state.status) {
      case LoginStatus.success:
        CustomSnackBar.showSuccessMessage(AppStrings.loginSuccess.tr());
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (route) => false,
        );
      case LoginStatus.failure:
        CustomSnackBar.showErrorMessage(
          state.errorMessage ?? AppStrings.defaultError.tr(),
        );
      case LoginStatus.initial:
      case LoginStatus.loading:
        break;
    }
  }
}
