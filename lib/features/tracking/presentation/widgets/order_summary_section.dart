import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';

class OrderSummarySection extends StatelessWidget {
  final num total;
  final String paymentMethod;

  const OrderSummarySection({
    super.key,
    required this.total,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryTile(
          label: AppStrings.total.tr(),
          value: '${AppStrings.egp.tr()} $total',
        ),
        SizedBox(height: 12.h),
        _SummaryTile(
          label: AppStrings.paymentMethod.tr(),
          value: paymentMethod.tr(),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.black10.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.black16600),
          Text(value, style: AppTextStyles.black14400),
        ],
      ),
    );
  }
}
