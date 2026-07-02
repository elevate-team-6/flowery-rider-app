import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/app_colors.dart';

class OrderStepIndicator extends StatelessWidget {
  final int uiStep;

  const OrderStepIndicator({super.key, required this.uiStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        bool isActive = index < uiStep;
        return Expanded(
          child: Container(
            height: 4.h,
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.black10,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        );
      }),
    );
  }
}
