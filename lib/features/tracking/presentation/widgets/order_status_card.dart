import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';

class OrderStatusCard extends StatelessWidget {
  final int uiStep;
  final String orderId;
  final String date;

  const OrderStatusCard({
    super.key,
    required this.uiStep,
    required this.orderId,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.lightPink.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${AppStrings.status.tr()} : ',
                  style: AppTextStyles.success14500,
                ),
                TextSpan(
                  text: _getStatusText(uiStep).tr(),
                  style: AppTextStyles.success14500,
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '${AppStrings.orderID.tr()} : # $orderId',
            style: AppTextStyles.black16600,
          ),
          SizedBox(height: 8.h),
          Text(date, style: AppTextStyles.gray14400),
        ],
      ),
    );
  }

  String _getStatusText(int step) {
    switch (step) {
      case 1:
        return AppStrings.accepted;
      case 2:
        return AppStrings.arrivedAtPickup;
      case 3:
        return AppStrings.picked;
      case 4:
        return AppStrings.outForDelivery;
      case 5:
        return AppStrings.arrived;
      case 6:
        return AppStrings.delivered;
      default:
        return AppStrings.accepted;
    }
  }
}
