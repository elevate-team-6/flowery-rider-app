import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Rebuild this widget's texts when the locale changes (no state reset).
    context.locale;

    final state = DriverOrderState.fromString(status);

    Color color;
    IconData icon;
    String label;

    switch (state) {
      case DriverOrderState.completed:
        color = AppColors.success;
        icon = Icons.check_circle_outline;
        label = status.tr();
      case DriverOrderState.canceled:
        color = AppColors.error;
        icon = Icons.cancel_outlined;
        label = AppStrings.cancelledStatus.tr();
      default:
        color = AppColors.primary;
        icon = Icons.info_outline;
        label = status.tr();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: AppTextStyles.black14400.copyWith(
              color: color,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
