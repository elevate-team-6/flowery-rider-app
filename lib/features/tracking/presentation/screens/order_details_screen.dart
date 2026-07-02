import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/base_ui_handler/ui_event_handler_mixin.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/widgets/custom_flower_loading.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_cubit.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_states.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/confirm_cancel_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widgets/address_info_card.dart';
import '../widgets/order_action_button.dart';
import '../widgets/order_show_map_button.dart';
import '../widgets/order_items_list.dart';
import '../widgets/order_status_card.dart';
import '../widgets/order_step_indicator.dart';
import '../widgets/order_summary_section.dart';

class OrderDetailsArgs {
  final OrderEntity order;
  final int? initialStep;

  const OrderDetailsArgs({required this.order, this.initialStep});
}

class OrderDetailsScreen extends StatefulWidget {
  final OrderDetailsArgs args;

  const OrderDetailsScreen({super.key, required this.args});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with UiEventHandler {
  StreamSubscription<BaseUiEvent>? _sideEffectSubscription;

  @override
  void initState() {
    super.initState();
    _sideEffectSubscription = context
        .read<OrderDetailsCubit>()
        .eventStream
        .listen(handleUiEvent);

    Future.microtask(() {
      if (mounted) {
        context.read<OrderDetailsCubit>().doEvent(
          OrderDetailsInitializeEvent(
            widget.args.order,
            initialStep: widget.args.initialStep,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _sideEffectSubscription?.cancel();
    super.dispose();
  }

  @override
  void onShowConfirmationDialog() {
    final cubit = context.read<OrderDetailsCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: ConfirmCancelDialog(order: widget.args.order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.read<OrderDetailsCubit>().doEvent(
          ConfirmBackButtonPressedEvent(),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppStrings.orderDetails.tr()),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              context.read<OrderDetailsCubit>().doEvent(
                ConfirmBackButtonPressedEvent(),
              );
            },
          ),
        ),
        body: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
          buildWhen: (previous, current) =>
              previous.orderDetailsState != current.orderDetailsState,
          builder: (context, state) {
            final order = state.orderDetailsState.data;

            if (state.orderDetailsState.isLoading || order == null) {
              return const Center(child: LoadingDialog());
            }

            if (state.orderDetailsState.errorMessage != null) {
              return Center(child: Text(state.orderDetailsState.errorMessage!));
            }

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
                          buildWhen: (previous, current) =>
                              previous.uiStep != current.uiStep,
                          builder: (context, state) {
                            return OrderStepIndicator(uiStep: state.uiStep);
                          },
                        ),
                        SizedBox(height: 24.h),
                        BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
                          buildWhen: (previous, current) =>
                              previous.uiStep != current.uiStep,
                          builder: (context, state) {
                            return OrderStatusCard(
                              uiStep: state.uiStep,
                              orderId: order.orderNumber,
                              date: order.createdAt,
                            );
                          },
                        ),
                        SizedBox(height: 24.h),
                        AddressInfoCard(
                          label: AppStrings.pickupAddress,
                          imageUrl: order.store.image,
                          title: order.store.name,
                          address: order.store.address,
                          onTap: () {
                            context.read<OrderDetailsCubit>().doEvent(
                              NavigateToMapEvent(LocationType.store),
                            );
                          },
                          onPhoneTap: () {
                            context.read<OrderDetailsCubit>().doEvent(
                              CallPhoneEvent(order.store.phoneNumber),
                            );
                          },
                          onWhatsappTap: () {
                            context.read<OrderDetailsCubit>().doEvent(
                              OpenWhatsAppEvent(order.store.phoneNumber),
                            );
                          },
                        ),
                        SizedBox(height: 24.h),
                        AddressInfoCard(
                          label: AppStrings.userAddress,
                          imageUrl: order.user.photo,
                          title: order.user.fullName,
                          address:
                              '${order.shippingAddress.street}, ${order.shippingAddress.city}',
                          onTap: () {
                            context.read<OrderDetailsCubit>().doEvent(
                              NavigateToMapEvent(LocationType.user),
                            );
                          },
                          onPhoneTap: () {
                            context.read<OrderDetailsCubit>().doEvent(
                              CallPhoneEvent(order.user.phone),
                            );
                          },
                          onWhatsappTap: () {
                            context.read<OrderDetailsCubit>().doEvent(
                              OpenWhatsAppEvent(order.user.phone),
                            );
                          },
                        ),
                        SizedBox(height: 24.h),
                        OrderItemsList(items: order.orderItems),
                        SizedBox(height: 24.h),
                        OrderSummarySection(
                          total: order.totalPrice,
                          paymentMethod: order.paymentType,
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: BlocBuilder<OrderDetailsCubit, OrderDetailsState>(
                    buildWhen: (previous, current) =>
                        previous.uiStep != current.uiStep ||
                        previous.updateStepState.isLoading !=
                            current.updateStepState.isLoading,
                    builder: (context, state) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Route to the store (step 1) or the customer
                          // (steps 4 & 5). Hidden on every other step.
                          OrderShowMapButton(
                            uiStep: state.uiStep,
                            onShowMap: (type) {
                              context.read<OrderDetailsCubit>().doEvent(
                                NavigateToMapEvent(type),
                              );
                            },
                          ),
                          OrderActionButton(
                            uiStep: state.uiStep,
                            isLoading: state.updateStepState.isLoading,
                            onPressed: () {
                              context.read<OrderDetailsCubit>().doEvent(
                                OrderDetailsNextStepEvent(),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
