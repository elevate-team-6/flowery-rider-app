import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdatePasswordButton extends StatelessWidget {
  final bool isFormValid;
  final bool isLoading;
  final GlobalKey<FormState> formKey;
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordButton({
    super.key,
    required this.isFormValid,
    required this.isLoading,
    required this.formKey,
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: !isFormValid || isLoading
            ? null
            : () {
                if (formKey.currentState!.validate()) {
                  context.read<ChangePasswordCubit>().doIntent(
                    SubmitChangePasswordEvent(
                      currentPassword: currentPassword,
                      newPassword: newPassword,
                    ),
                  );
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFormValid ? AppColors.primary : AppColors.black30,
          disabledBackgroundColor: AppColors.black30,
        ),
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(AppStrings.update),
      ),
    );
  }
}
