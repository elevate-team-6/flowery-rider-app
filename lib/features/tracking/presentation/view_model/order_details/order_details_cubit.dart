import 'dart:convert';

import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/cache/hive_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/open_communication_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/start_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/update_order_state_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_states.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base_state/base_state.dart';

@injectable
class OrderDetailsCubit extends BaseCubit<OrderDetailsState, BaseUiEvent> {
  final UpdateOrderStateUseCase _updateOrderStateUseCase;
  final StartOrderUseCase _startOrderUseCase;
  final OpenCommunicationUseCase _openCommunicationUseCase;
  final HiveHelper _hiveHelper;

  OrderDetailsCubit(
    this._updateOrderStateUseCase,
    this._startOrderUseCase,
    this._openCommunicationUseCase,
    this._hiveHelper,
  ) : super(const OrderDetailsState());

  void doEvent(OrderDetailsEvents event) {
    switch (event) {
      case InitializeOrderDetailsEvent():
        _onInitialize(event.order, initialStep: event.initialStep);
      case NextStepEvent():
        _onNextStep();
      case ConfirmBackButtonPressedEvent():
        _onBackButtonPressed();
      case RevertOrderToPendingEvent():
        _onRevertToPending(event.orderId);
      case NavigateToMapEvent():
        _onNavigateToMap(event.locationType);
      case CallPhoneEvent():
        _onCallPhone(event.phoneNumber);
      case OpenWhatsAppEvent():
        _onOpenWhatsApp(event.phoneNumber);
    }
  }

  Future<void> _onInitialize(OrderEntity order, {int? initialStep}) async {
    final initialBackendStatus = OrderStatus.fromString(order.state);
    int step = initialStep ?? 1;

    // If no initialStep is provided, fallback to basic logic
    if (initialStep == null) {
      if (initialBackendStatus == OrderStatus.completed) {
        step = 6;
      } else if (initialBackendStatus == OrderStatus.inProgress) {
        step = 1;
      }
    }

    emit(
      state.copyWith(
        orderDetailsState: BaseState(data: order),
        orderStatus: initialBackendStatus,
        uiStep: step,
      ),
    );

    if (order.id != null) {
      BaseResponse<OrderEntity> startResult = await _startOrderUseCase(
        order.id!,
      );

      if (startResult is SuccessBaseResponse<OrderEntity>) {
        final updatedOrder = startResult.data;
        // Merge: Keep the rich data (user/store) from passed entity if API response is partial
        final mergedOrder = order.mergeWith(updatedOrder);

        emit(
          state.copyWith(
            orderDetailsState: BaseState(data: mergedOrder),
            orderStatus: OrderStatus.fromString(mergedOrder.state),
          ),
        );
        _cacheOrder(mergedOrder);
      }
    }
  }

  Future<void> _onNextStep() async {
    final currentStep = state.uiStep;
    if (currentStep >= 6) return;

    final nextStep = currentStep + 1;
    final currentOrder = state.orderDetailsState.data;
    final orderId = currentOrder?.id;
    if (orderId == null) return;

    OrderStatus backendStatus = (nextStep == 6)
        ? OrderStatus.completed
        : OrderStatus.inProgress;

    emitUiEvent(ShowLoadingEvent());
    final result = await _updateOrderStateUseCase(orderId, backendStatus);
    emitUiEvent(HideLoadingEvent());

    switch (result) {
      case SuccessBaseResponse<OrderEntity>():
        // Merge to prevent losing user/store details
        final mergedOrder = currentOrder!.mergeWith(result.data);

        emit(
          state.copyWith(
            orderDetailsState: BaseState(data: mergedOrder),
            orderStatus: backendStatus,
            uiStep: nextStep,
          ),
        );
        if (nextStep == 6) {
          _clearCache();
          emitUiEvent(
            NavigateEvent(
              AppRoutes.orderSuccess,
              navigationType: NavigationType.pushReplacement,
            ),
          );
        } else {
          _cacheOrder(mergedOrder);
        }
      case ErrorBaseResponse<OrderEntity>():
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  void _cacheOrder(OrderEntity order) {
    final cacheData = {
      AppKeys.order: order.toJson(),
      AppKeys.uiStep: state.uiStep,
    };

    _hiveHelper.cacheData(
      boxName: AppKeys.activeOrderBox,
      key: AppKeys.activeOrderKey,
      value: jsonEncode(cacheData),
    );
  }

  void _clearCache() {
    _hiveHelper.deleteData(
      boxName: AppKeys.activeOrderBox,
      key: AppKeys.activeOrderKey,
    );
  }

  void _onBackButtonPressed() {
    emitUiEvent(ShowConfirmationDialogEvent());
  }

  Future<void> _onRevertToPending(String orderId) async {
    emit(state.copyWith(canselOrderState: BaseState(isLoading: true)));
    final result = await _updateOrderStateUseCase(
      orderId,
      OrderStatus.canceled,
    );
    emit(state.copyWith(canselOrderState: BaseState()));
    switch (result) {
      case SuccessBaseResponse<OrderEntity>():
        _clearCache();
        emitUiEvent(
          NavigateEvent(
            AppRoutes.mainLayout,
            navigationType: NavigationType.pushAndRemoveUntil,
          ),
        );
      case ErrorBaseResponse<OrderEntity>():
        emit(
          state.copyWith(
            orderDetailsState: BaseState(errorMessage: result.errorMessage),
          ),
        );
    }
  }

  void _onNavigateToMap(LocationType type) {
    final order = state.orderDetailsState.data;
    final lat = type == LocationType.store
        ? order?.store?.lat
        : order?.shippingAddress?.lat;
    final long = type == LocationType.store
        ? order?.store?.long
        : order?.shippingAddress?.long;

    if (lat != null && long != null && order != null) {
      emitUiEvent(
        NavigateEvent(
          AppRoutes.mapScreen,
          arguments: {
            'targetLat': lat,
            'targetLong': long,
            'locationType': type,
            'order': order,
          },
        ),
      );
    }
  }

  Future<void> _onCallPhone(String phoneNumber) async {
    final success = await _openCommunicationUseCase(
      phoneNumber,
      CommunicationType.phone,
    );
    if (!success) {
      emitUiEvent(DisplayErrorEvent(AppStrings.couldNotLaunchUrl));
    }
  }

  Future<void> _onOpenWhatsApp(String phoneNumber) async {
    final success = await _openCommunicationUseCase(
      phoneNumber,
      CommunicationType.whatsapp,
    );
    if (!success) {
      emitUiEvent(DisplayErrorEvent(AppStrings.couldNotLaunchUrl));
    }
  }
}
