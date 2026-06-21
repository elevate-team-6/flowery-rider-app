import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entites/order_entity.dart';
import 'order_address_tile.dart';

class OrderCard extends StatelessWidget {
  final OrderEntity order;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const OrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onReject,
  });

  String? get _customerAddress {
    final shipping = order.shippingAddress;
    if (shipping == null) return null;
    return [
      shipping.street,
      shipping.city,
    ].where((e) => e != null && e.isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final store = order.store;
    final user = order.user;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.black10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.flowerOrder.tr(), style: AppTextStyles.black16600),
          SizedBox(height: 12.h),

          // Pickup (store) address
          Text(
            AppStrings.pickupAddress.tr(),
            style: AppTextStyles.gray12400.copyWith(color: AppColors.white90),
          ),
          SizedBox(height: 8.h),
          OrderAddressTile(
            imageUrl: store?.image,
            title: store?.name,
            address: store?.address,
          ),
          SizedBox(height: 12.h),

          // Customer address
          Text(
            AppStrings.userAddress.tr(),
            style: AppTextStyles.gray12400.copyWith(color: AppColors.white90),
          ),
          SizedBox(height: 8.h),
          OrderAddressTile(
            imageUrl: _userPhotoUrl(user?.photo),
            title: user?.fullName,
            address: _customerAddress,
          ),
          SizedBox(height: 16.h),

          // Price + actions
          Row(
            children: [
              Text(
                '${AppStrings.egp.tr()} ${order.totalPrice?.toStringAsFixed(0)}',
                style: AppTextStyles.black16600,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _ActionButton(
                  label: AppStrings.reject.tr(),
                  onPressed: onReject,
                  isOutlined: true,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _ActionButton(
                  label: AppStrings.accept.tr(),
                  onPressed: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _userPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty) return null;
    if (photo.startsWith('http')) return photo;
    return '${AppImages.imageBaseUrl}$photo';
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isOutlined;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
      ),
      minimumSize: WidgetStatePropertyAll(Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
      ),
    );

    if (isOutlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: style.copyWith(
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.primary),
          ),
        ),
        child: Text(label, style: AppTextStyles.primary14500),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: style.copyWith(
        backgroundColor: const WidgetStatePropertyAll(AppColors.primary),
      ),
      child: Text(label, style: AppTextStyles.white14600),
    );
  }
}
