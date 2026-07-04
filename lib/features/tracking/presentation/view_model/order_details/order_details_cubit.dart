import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/notification/domain/entities/user_notification_state.dart';
import 'package:flowery_rider_app/features/notification/domain/use_cases/update_order_progress_use_case.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/cache_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/clear_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/get_active_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/open_communication_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/start_order_use_case.dart';
import 'package:flowery_rider_app/features/tracking/domain/use_cases/update_order_state_use_case.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_events.dart';
import 'package:flowery_rider_app/features/tracking/presentation/view_model/order_details/order_details_states.dart';
import 'package:injectable/injectable.dart';

import '../../../../../config/base_state/base_state.dart';
import '../../../../../core/utils/app_keys.dart';

@injectable
class OrderDetailsCubit extends BaseCubit<OrderDetailsState, BaseUiEvent> {
  final UpdateOrderStateUseCase _updateOrderStateUseCase;
  final StartOrderUseCase _startOrderUseCase;
  final OpenCommunicationUseCase _openCommunicationUseCase;
  final CacheActiveOrderUseCase _cacheActiveOrderUseCase;
  final GetActiveOrderUseCase _getActiveOrderUseCase;
  final ClearActiveOrderUseCase _clearActiveOrderUseCase;
  final UpdateOrderProgressUseCase _updateOrderProgressUseCase;

  OrderDetailsCubit(
    this._updateOrderStateUseCase,
    this._startOrderUseCase,
    this._openCommunicationUseCase,
    this._cacheActiveOrderUseCase,
    this._getActiveOrderUseCase,
    this._clearActiveOrderUseCase,
    this._updateOrderProgressUseCase,
  ) : super(const OrderDetailsState());

  void doEvent(OrderDetailsEvents event) {
    switch (event) {
      case OrderDetailsInitializeEvent():
        _onInitialize(event.order, initialStep: event.initialStep);
      case OrderDetailsNextStepEvent():
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

    // Check Cache first
    final cachedData = await _getActiveOrderUseCase();
    if (cachedData != null) {
      final cachedOrder = OrderEntity.fromJson(cachedData[AppKeys.order]);
      if (cachedOrder.id == order.id) {
        final cachedStep = cachedData[AppKeys.uiStep] as int;
        emit(
          state.copyWith(
            orderDetailsState: BaseState(data: cachedOrder),
            orderStatus: OrderStatus.fromString(cachedOrder.state),
            uiStep: cachedStep,
          ),
        );
        return; // Don't call startOrder API if cached
      }
    }

    // Fallback if no cache
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

    BaseResponse<OrderEntity> startResult = await _startOrderUseCase(order.id);

    if (startResult is SuccessBaseResponse<OrderEntity>) {
      final updatedOrder = startResult.data;
      final mergedOrder = order.mergeWith(updatedOrder);

      emit(
        state.copyWith(
          orderDetailsState: BaseState(data: mergedOrder),
          orderStatus: OrderStatus.fromString(mergedOrder.state),
        ),
      );
      await _cacheActiveOrderUseCase(mergedOrder, state.uiStep);
      // Notify User: Step 1 (Accepted)
      _updateProgress(UserNotificationState.accepted);
    }
  }

  Future<void> _onNextStep() async {
    final currentStep = state.uiStep;
    if (currentStep >= 6 || state.updateStepState.isLoading) return;

    final currentOrder = state.orderDetailsState.data;
    if (currentOrder == null) return;

    final nextStep = currentStep + 1;
    final orderId = currentOrder.id;

    OrderStatus backendStatus = (nextStep == 6)
        ? OrderStatus.completed
        : OrderStatus.inProgress;

    emitUiEvent(ShowLoadingEvent());
    emit(state.copyWith(updateStepState: const BaseState(isLoading: true)));
    final result = await _updateOrderStateUseCase(orderId, backendStatus);
    emit(state.copyWith(updateStepState: const BaseState(isLoading: false)));
    emitUiEvent(HideLoadingEvent());

    switch (result) {
      case SuccessBaseResponse<OrderEntity>():
        final mergedOrder = currentOrder.mergeWith(result.data);

        emit(
          state.copyWith(
            orderDetailsState: BaseState(data: mergedOrder),
            orderStatus: backendStatus,
            uiStep: nextStep,
          ),
        );

        // Notification logic for specific user-facing steps
        final notifyState = switch (nextStep) {
          2 => UserNotificationState.preparing,
          4 => UserNotificationState.onWay,
          6 => UserNotificationState.delivered,
          _ => null,
        };

        if (notifyState != null) {
          _updateProgress(notifyState);
        }

        if (nextStep == 6) {
          await _clearActiveOrderUseCase();
          emitUiEvent(
            NavigateEvent(
              AppRoutes.orderSuccess,
              navigationType: NavigationType.pushReplacement,
            ),
          );
        } else {
          await _cacheActiveOrderUseCase(mergedOrder, nextStep);
        }
      case ErrorBaseResponse<OrderEntity>():
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
  }

  Future<void> _updateProgress(UserNotificationState notifyState) async {
    final order = state.orderDetailsState.data;
    if (order?.id == null || order?.user?.id == null) return;

    await _updateOrderProgressUseCase(
      userId: order!.user!.id!,
      orderId: order.id!,
      state: notifyState,
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
        await _clearActiveOrderUseCase();
        emitUiEvent(
          NavigateEvent(
            AppRoutes.mainLayout,
            navigationType: NavigationType.pushAndRemoveUntil,
          ),
        );
        _updateProgress(UserNotificationState.canceled);
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
    if (order == null) return;

    final lat = type == LocationType.store
        ? order.store.lat
        : order.shippingAddress.lat;
    final long = type == LocationType.store
        ? order.store.long
        : order.shippingAddress.long;

    if (lat.isNotEmpty && long.isNotEmpty) {
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
