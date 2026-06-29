import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/orders_view_model/order_screen_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../widgets/orders_list_view.dart';
import '../widgets/orders_tab_summary_section.dart';
import '../widgets/pagination_bar.dart';

class OrdersScreen extends StatefulWidget {
  final bool isActive;

  const OrdersScreen({super.key, this.isActive = false});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with UiEventHandler {
  late StreamSubscription<BaseUiEvent> _uiSubscription;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
    _uiSubscription = context.read<OrderScreenCubit>().eventStream.listen(
      handleUiEvent,
    );
    _checkFetch();
  }

  @override
  void didUpdateWidget(covariant OrdersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkFetch();
  }

  void _checkFetch() {
    if (widget.isActive && !_hasFetched) {
      _hasFetched = true;
      context.read<OrderScreenCubit>().doEvent(GetDriverOrdersEvent());
    }
  }

  @override
  void dispose() {
    _uiSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.myOrders.tr())),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<OrderScreenCubit>().doEvent(RefreshOrdersEvent());
        },
        child: BlocBuilder<OrderScreenCubit, OrderScreenState>(
          buildWhen: (previous, current) =>
              previous.ordersState != current.ordersState,
          builder: (context, state) {
            return Skeletonizer(
              enabled: state.ordersState.isLoading,
              effect: ShimmerEffect(
                baseColor: AppColors.black10.withValues(alpha: 0.8),
                highlightColor: AppColors.white,
              ),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: const OrdersTabSummarySection(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 8.h),
                      child: Text(
                        AppStrings.recentOrders.tr(),
                        style: AppTextStyles.black18600,
                      ),
                    ),
                  ),
                  const OrdersListView(),
                  SliverToBoxAdapter(
                    child: BlocBuilder<OrderScreenCubit, OrderScreenState>(
                      buildWhen: (previous, current) =>
                          previous.currentPage != current.currentPage ||
                          previous.totalPages != current.totalPages,
                      builder: (context, state) {
                        if (state.totalPages <= 1) {
                          return const SizedBox.shrink();
                        }
                        return PaginationBar(
                          currentPage: state.currentPage,
                          totalPages: state.totalPages,
                          onPageChanged: (page) => context
                              .read<OrderScreenCubit>()
                              .doEvent(ChangePageEvent(page)),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
