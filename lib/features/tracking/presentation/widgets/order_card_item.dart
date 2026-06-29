import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../view_model/orders_view_model/order_screen_cubit.dart';
import '../view_model/orders_view_model/order_screen_events.dart';
import 'order_status_badge.dart';

class OrderCardItem extends StatelessWidget {
  final OrderEntity order;

  const OrderCardItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.read<OrderScreenCubit>().doEvent(OrderTappedEvent(order)),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.black10.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.flowerOrder.tr(),
                  style: AppTextStyles.black16600,
                ),
                Text('#${order.orderNumber}', style: AppTextStyles.black16600),
              ],
            ),
            SizedBox(height: 12.h),
            OrderStatusBadge(status: order.state),
            SizedBox(height: 16.h),
            _buildInfoTile(
              label: AppStrings.pickupAddress.tr(),
              name: order.store.name,
              address: order.store.address,
              image: order.store.image,
            ),
            SizedBox(height: 12.h),
            _buildInfoTile(
              label: AppStrings.userAddress.tr(),
              name: order.user.fullName,
              address:
                  "${order.shippingAddress.city}, ${order.shippingAddress.street}",
              image: order.user.photo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String label,
    required String name,
    required String address,
    required String image,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.black14400.copyWith(color: AppColors.black60),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.black10.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                backgroundColor: AppColors.black10,
                child: image.isEmpty
                    ? Icon(Icons.person, size: 24.r, color: AppColors.black40)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.black14400.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      address,
                      style: AppTextStyles.black14400.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.black60,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
