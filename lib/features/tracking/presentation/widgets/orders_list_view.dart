import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'order_card_item.dart';

class OrdersListView extends StatelessWidget {
  const OrdersListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderScreenCubit, OrderScreenState>(
      buildWhen: (previous, current) => previous.ordersState != current.ordersState,
      builder: (context, state) {
        final ordersState = state.ordersState;

        if (ordersState.isLoading && (ordersState.data == null || ordersState.data!.isEmpty)) {
          return Skeletonizer(
            enabled: true,
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: 5,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) => const _SkeletonCard(),
            ),
          );
        }

        if (ordersState.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(ordersState.errorMessage!, style: AppTextStyles.black14400),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    // Refresh logic
                  },
                  child: Text(AppStrings.retry.tr()),
                ),
              ],
            ),
          );
        }

        final orders = ordersState.data ?? [];

        if (orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/lottie_files/empty_orders.json',
                  width: 200.w,
                  repeat: true,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppStrings.noCompletedOrders.tr(),
                  style: AppTextStyles.black16600,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh logic
          },
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: orders.length,
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              return OrderCardItem(order: orders[index]);
            },
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
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.black10),
      ),
    );
  }
}
