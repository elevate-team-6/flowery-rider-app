import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/utils/app_assets.dart';
import 'order_card_item.dart';

class OrdersListView extends StatelessWidget {
  const OrdersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderScreenCubit, OrderScreenState>(
      buildWhen: (previous, current) =>
          previous.ordersState != current.ordersState,
      builder: (context, state) {
        final ordersState = state.ordersState;

        // Loading or Initial state
        if (ordersState.isLoading || ordersState.data == null) {
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: const _SkeletonCard(),
                ),
                childCount: 5,
              ),
            ),
          );
        }

        // Error state
        if (ordersState.errorMessage != null) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    ordersState.errorMessage!,
                    style: AppTextStyles.black14400,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<OrderScreenCubit>().doEvent(
                      GetDriverOrdersEvent(),
                    ),
                    child: Text(AppStrings.retry.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        final orders = ordersState.data!;

        // Empty state
        if (orders.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    AppLottie.empty,
                    width: 200.w,
                    height: 200.h,
                    repeat: true,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    AppStrings.noCompletedOrders.tr(),
                    style: AppTextStyles.black16600,
                  ),
                ],
              ),
            ),
          );
        }

        // Success state
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: OrderCardItem(order: orders[index]),
              ),
              childCount: orders.length,
            ),
          ),
        );
      },
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.black10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 100.w, height: 16.h, color: AppColors.black10),
              Container(width: 60.w, height: 16.h, color: AppColors.black10),
            ],
          ),
          SizedBox(height: 12.h),
          Container(width: 80.w, height: 24.h, color: AppColors.black10),
          SizedBox(height: 16.h),
          _buildSkeletonInfoTile(),
          SizedBox(height: 12.h),
          _buildSkeletonInfoTile(),
        ],
      ),
    );
  }

  Widget _buildSkeletonInfoTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 120.w, height: 12.h, color: AppColors.black10),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.black10),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 20.r, backgroundColor: AppColors.black10),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 100.w,
                    height: 14.h,
                    color: AppColors.black10,
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    width: 150.w,
                    height: 12.h,
                    color: AppColors.black10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
