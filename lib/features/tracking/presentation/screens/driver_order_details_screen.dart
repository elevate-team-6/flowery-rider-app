import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/address_info_card.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/order_items_list.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/order_status_badge.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/order_summary_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverOrderDetailsScreen extends StatelessWidget {
  final OrderEntity order;

  const DriverOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.orderDetails.tr()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(),
            SizedBox(height: 24.h),
            AddressInfoCard(
              label: AppStrings.pickupAddress,
              imageUrl: order.store.image,
              title: order.store.name,
              address: order.store.address,
              titleStyle: AppTextStyles.black14400.copyWith(
                fontWeight: FontWeight.w600,
              ),
              addressStyle: AppTextStyles.black12400.copyWith(
                color: AppColors.black60,
              ),
            ),
            SizedBox(height: 24.h),
            AddressInfoCard(
              label: AppStrings.userAddress,
              imageUrl: order.user.photo,
              title: order.user.fullName,
              address:
                  '${order.shippingAddress.street}, ${order.shippingAddress.city}',
              titleStyle: AppTextStyles.black14400.copyWith(
                fontWeight: FontWeight.w600,
              ),
              addressStyle: AppTextStyles.black12400.copyWith(
                color: AppColors.black60,
              ),
            ),
            SizedBox(height: 24.h),
            OrderItemsList(
              items: order.orderItems,
              nameStyle: AppTextStyles.black14400.copyWith(
                color: AppColors.black60,
              ),
            ),
            SizedBox(height: 24.h),
            OrderSummarySection(
              total: order.totalPrice,
              paymentMethod: order.paymentType,
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OrderStatusBadge(
          status: order.state,
          isPlain: true,
          iconSize: 24.w,
          textStyle: AppTextStyles.black16600.copyWith(fontSize: 14.sp),
        ),
        Text(
          '# ${order.orderNumber}',
          style: AppTextStyles.black16600.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
