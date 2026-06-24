import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_cached_image.dart';
import '../../domain/entities/order_entity.dart';

class OrderItemsList extends StatelessWidget {
  final List<OrderItemEntity> items;

  const OrderItemsList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.orderDetails.tr(), style: AppTextStyles.black16600),
        SizedBox(height: 12.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, _) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final item = items[index];
            return Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.black10.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  CustomCachedImage(
                    imageUrl: item.productImage ?? '',
                    width: 50.w,
                    height: 50.w,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName ?? '',
                          style: AppTextStyles.black14400.copyWith(
                            color: AppColors.white90,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${AppStrings.egp.tr()} ${item.price}',
                          style: AppTextStyles.black14600,
                        ),
                      ],
                    ),
                  ),
                  Text('X${item.quantity}', style: AppTextStyles.primary14500),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
