import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lottie/lottie.dart';

import '../../../../config/base_ui_event/base_ui_event.dart';
import '../../../../config/base_ui_handler/ui_event_handler_mixin.dart';
import '../../../../config/di/di.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/custom_error_state.dart';
import '../view_model/home_view_model/home_cubit.dart';
import '../view_model/home_view_model/home_events.dart';
import '../view_model/home_view_model/home_states.dart';
import '../widgets/empty_orders_state.dart';
import '../widgets/order_card.dart';
import '../widgets/pagination_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeCubit>(),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> with UiEventHandler {
  StreamSubscription<BaseUiEvent>? _uiEventSubscription;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<HomeCubit>();
    _uiEventSubscription = cubit.eventStream.listen(handleUiEvent);
    cubit.doEvent(const GetPendingOrdersEvent());
  }

  @override
  void dispose() {
    _uiEventSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadOrders() =>
      context.read<HomeCubit>().doEvent(const GetPendingOrdersEvent());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16.w,
        title: Row(
          children: [
            SvgPicture.asset(AppIcons.flowerAppIcon, width: 24.w, height: 24.w),
            SizedBox(width: 8.w),
            Text(
              AppStrings.floweryRiderTitle.tr(),
              style: AppTextStyles.primary20400imFellEnglish,
            ),
          ],
        ),
      ),
      body: BlocBuilder<HomeCubit, HomeStates>(
        buildWhen: (previous, current) =>
            previous.pendingOrdersState != current.pendingOrdersState,
        builder: (context, state) {
          final ordersState = state.pendingOrdersState;
          final bool hasPagination =
              ordersState.data?.totalPages != null &&
              ordersState.data!.totalPages! > 1;

          if (ordersState.isLoading) {
            return Center(
              child: Lottie.asset(AppLottie.flowerLoading, width: 120.w),
            );
          }

          if (ordersState.errorMessage != null) {
            return CustomErrorState(
              message: ordersState.errorMessage!,
              onRetry: _loadOrders,
            );
          }

          final orders = ordersState.data?.orders ?? [];
          if (orders.isEmpty) {
            return EmptyOrdersState(onRefresh: _loadOrders);
          }

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    itemCount: orders.length + (hasPagination ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 16.h),
                    itemBuilder: (context, index) {
                      if (hasPagination && index == orders.length) {
                        return PaginationBar(
                          currentPage: ordersState.data!.currentPage ?? 1,
                          totalPages: ordersState.data!.totalPages!,
                          onPageChanged: (page) {
                            context.read<HomeCubit>().doEvent(
                              GetPendingOrdersEvent(page: page),
                            );
                          },
                        );
                      }
                      final order = orders[index];
                      final cubit = context.read<HomeCubit>();
                      return OrderCard(
                        order: order,
                        onAccept: () => cubit.doEvent(AcceptOrderEvent(order)),
                        onReject: () {
                          cubit.doEvent(RejectOrderEvent(order.id));
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
