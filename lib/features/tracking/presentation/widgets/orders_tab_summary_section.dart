import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrdersTabSummarySection extends StatelessWidget {
  const OrdersTabSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderScreenCubit, OrderScreenState>(
      buildWhen: (previous, current) =>
          previous.cancelledCount != current.cancelledCount ||
          previous.completedCount != current.completedCount,
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Expanded(
                child: _SummaryBox(
                  count: state.cancelledCount,
                  label: AppStrings.requestCancelled.tr(),
                  icon: Icons.cancel_outlined,
                  color: AppColors.error,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _SummaryBox(
                  count: state.completedCount,
                  label: AppStrings.completed.tr(),
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryBox extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryBox({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$count',
            style: AppTextStyles.black16600.copyWith(
              fontSize: 24.sp,
              color: AppColors.black,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(icon, size: 16.sp, color: color),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.black14400.copyWith(
                    color: AppColors.black60,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
