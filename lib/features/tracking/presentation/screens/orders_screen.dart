import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:flowery_rider_app/config/di/di.dart';
import 'package:flowery_rider_app/core/utils/app_colors.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/utils/app_text_styles.dart';
import 'package:flowery_rider_app/features/mainLayout/presentation/view_model/main_layout_cubit.dart';
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
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with UiEventHandler {
  late StreamSubscription<BaseUiEvent> _uiSubscription;
  bool _hasFetched = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _uiSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Make the screen reactive to locale changes
    context.locale;

    return BlocProvider(
      create: (context) {
        final cubit = getIt<OrderScreenCubit>();
        _uiSubscription = cubit.eventStream.listen(handleUiEvent);

        // Initial check in case we start at index 1
        final mainLayoutCubit = context.read<MainLayoutCubit>();
        if (mainLayoutCubit.state == 1 && !_hasFetched) {
          _hasFetched = true;
          cubit.doEvent(GetDriverOrdersEvent());
        }

        return cubit;
      },
      child: BlocListener<MainLayoutCubit, int>(
        listenWhen: (previous, current) => current == 1 && !_hasFetched,
        listener: (context, index) {
          _hasFetched = true;
          context.read<OrderScreenCubit>().doEvent(GetDriverOrdersEvent());
        },
        child: Scaffold(
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
        ),
      ),
    );
  }
}
