import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/app_text_styles.dart';

class RouteStatusChip extends StatelessWidget {
  final bool loading;
  final bool fallback;
  final VoidCallback onRetry;

  const RouteStatusChip({
    super.key,
    required this.loading,
    required this.fallback,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8.r,
          ),
        ],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: _content()),
    );
  }

  List<Widget> _content() {
    if (loading) {
      return [
        SizedBox(
          width: 14.w,
          height: 14.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 8.w),
        Text(AppStrings.loadingRoute.tr(), style: AppTextStyles.black12400),
      ];
    }
    if (fallback) {
      return [
        Icon(Icons.timeline, color: AppColors.primary, size: 16.w),
        SizedBox(width: 6.w),
        Text(
          AppStrings.showingDirectLine.tr(),
          style: AppTextStyles.black12400,
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onRetry,
          child: Text(AppStrings.retry.tr(), style: AppTextStyles.primary12600),
        ),
      ];
    }
    return [
      Icon(Icons.error_outline, color: AppColors.primary, size: 16.w),
      SizedBox(width: 6.w),
      Text(
        AppStrings.noDestinationLocation.tr(),
        style: AppTextStyles.black12400,
      ),
    ];
  }
}
