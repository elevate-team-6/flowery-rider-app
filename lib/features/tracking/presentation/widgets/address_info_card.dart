import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_cached_image.dart';

class AddressInfoCard extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final String? title;
  final String? address;
  final VoidCallback? onTap;
  final VoidCallback? onPhoneTap;
  final VoidCallback? onWhatsappTap;

  const AddressInfoCard({
    super.key,
    required this.label,
    this.imageUrl,
    this.title,
    this.address,
    this.onTap,
    this.onPhoneTap,
    this.onWhatsappTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.tr(), style: AppTextStyles.black16600),
        SizedBox(height: 12.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.black10.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                _Avatar(imageUrl: imageUrl),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title ?? '',
                        style: AppTextStyles.black14400.copyWith(
                          color: AppColors.white90,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16.w,
                            color: AppColors.black,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              address ?? '',
                              style: AppTextStyles.black12400.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onPhoneTap != null)
                  IconButton(
                    onPressed: onPhoneTap,
                    icon: Icon(
                      Icons.phone_outlined,
                      color: AppColors.primary,
                      size: 20.w,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.all(4.w),
                  ),
                if (onWhatsappTap != null)
                  IconButton(
                    onPressed: onWhatsappTap,
                    icon: Icon(
                      Icons.chat_outlined,
                      color: AppColors.primary,
                      size: 20.w,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.all(4.w),
                  ),
              ],
            ),
          ),
        ),
      ],
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
      return Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: AppColors.black10,
          borderRadius: radius,
        ),
        child: Icon(Icons.person, color: AppColors.white, size: 24.w),
      );
    }
    return CustomCachedImage(
      imageUrl: imageUrl!,
      width: 48.w,
      height: 48.w,
      borderRadius: radius,
    );
  }
}
