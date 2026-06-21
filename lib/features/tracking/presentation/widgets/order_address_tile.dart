import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_cached_image.dart';

class OrderAddressTile extends StatelessWidget {
  final String? imageUrl;
  final String? title;
  final String? address;

  const OrderAddressTile({super.key, this.imageUrl, this.title, this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.white90.withOpacity(0.25),
            blurRadius: 4.r,
          ),
        ],
      ),
      child: Row(
        children: [
          _Avatar(imageUrl: imageUrl),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null && title!.trim().isNotEmpty)
                  Text(
                    title!.trim(),
                    style: AppTextStyles.black14600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.w,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        (address != null && address!.trim().isNotEmpty)
                            ? address!.trim()
                            : '—',
                        style: AppTextStyles.gray12400,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? imageUrl;

  const _Avatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24.r);
    if (imageUrl == null || imageUrl!.isEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          AppImages.defaultImage,
          width: 40.w,
          height: 40.w,
          fit: BoxFit.cover,
        ),
      );
    }
    return CustomCachedImage(
      imageUrl: imageUrl!,
      width: 40.w,
      height: 40.w,
      borderRadius: radius,
    );
  }
}
