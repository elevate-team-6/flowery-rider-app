import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../view_model/order_details/order_details_events.dart';

class OrderShowMapButton extends StatelessWidget {
  final int uiStep;
  final ValueChanged<LocationType> onShowMap;

  const OrderShowMapButton({
    super.key,
    required this.uiStep,
    required this.onShowMap,
  });

  LocationType? get _locationType {
    switch (uiStep) {
      case 1:
        return LocationType.store;
      case 4:
      case 5:
        return LocationType.user;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = _locationType;
    if (type == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: OutlinedButton.icon(
        onPressed: () => onShowMap(type),
        style: OutlinedButton.styleFrom(
          minimumSize: Size(double.infinity, 52.h),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
        ),
        icon: Icon(Icons.map_outlined, color: AppColors.primary, size: 20.w),
        label: Text(
          AppStrings.showMap.tr(),
          style: AppTextStyles.primary16400.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
