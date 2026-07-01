import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';

class OrderActionButton extends StatelessWidget {
  final int uiStep;
  final bool isLoading;
  final VoidCallback onPressed;

  const OrderActionButton({
    super.key,
    required this.uiStep,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (uiStep == 6) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.black30,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Center(
          child: Text(
            AppStrings.deliveredToTheUser.tr(),
            style: AppTextStyles.white16600,
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(_getButtonText(uiStep).tr(), style: AppTextStyles.white16600),
    );
  }

  String _getButtonText(int step) {
    switch (step) {
      case 1:
        return AppStrings.arrivedAtPickupPoint;
      case 2:
        return AppStrings.picked;
      case 3:
        return AppStrings.startDeliver;
      case 4:
        return AppStrings.arrivedToTheUser;
      case 5:
        return AppStrings.deliveredToTheUser;
      default:
        return AppStrings.done;
    }
  }
}
