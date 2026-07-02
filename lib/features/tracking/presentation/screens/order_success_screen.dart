import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 110.w,
                  height: 110.w,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: AppColors.white,
                        size: 40.w,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 48.h),
            Text(
              AppStrings.thankYou.tr(),
              style: AppTextStyles.success14500.copyWith(fontSize: 24.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              AppStrings.orderDeliveredSuccessfully.tr(),
              style: AppTextStyles.black20500,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.mainLayout,
                  (route) => false,
                );
              },
              child: Text(
                AppStrings.done.tr(),
                style: AppTextStyles.white16600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
