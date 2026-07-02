import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../core/utils/app_assets.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_text_styles.dart';

class MapPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isFlowery;

  const MapPill({
    super.key,
    required this.label,
    this.icon = Icons.location_on,
    this.isFlowery = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // White circle with the icon (or flower logo) inside.
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: isFlowery
                  ? SvgPicture.asset(
                      AppIcons.flowerAppIcon,
                      width: 8.w,
                      height: 8.w,
                    )
                  : Icon(icon, size: 8.w, color: AppColors.primary),
            ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: AppTextStyles.white12600.copyWith(
                fontSize: 10.sp,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              softWrap: false,
            ),
            SizedBox(width: 3.w),
          ],
        ),
      ),
    );
  }
}
