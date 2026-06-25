import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class PasswordChangeField extends StatelessWidget {
  final VoidCallback? onChangePressed;

  const PasswordChangeField({super.key, this.onChangePressed});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      initialValue: AppStrings.passwordMask,
      style: AppTextStyles.black16600,
      decoration: InputDecoration(
        labelText: AppStrings.password.tr(),
        suffixIcon: TextButton(
          onPressed: onChangePressed,
          child: Text(AppStrings.change.tr(), style: AppTextStyles.black14600),
        ),
      ),
    );
  }
}
