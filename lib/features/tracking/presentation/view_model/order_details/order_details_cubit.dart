import 'package:flowery_rider_app/config/base_cubit/base_cubit.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
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

  OrderDetailsCubit(this._updateOrderStateUseCase, this._startOrderUseCase)
    : super(const OrderDetailsState());

  void doEvent(OrderDetailsEvents event) {
    switch (event) {
      case InitializeOrderDetailsEvent():
        _onInitialize(event.orderId);
      case UpdateOrderStateEvent():
        _onUpdateOrderState(event.newStatus);
      case ConfirmBackButtonPressedEvent():
        _onBackButtonPressed();
      case RevertOrderToPendingEvent():
        _onRevertToPending(event.orderId);
      case NavigateToMapEvent():
        _onNavigateToMap(event.locationType);
    }
  }

  Future<void> _onInitialize(String orderId) async {
    emitUiEvent(ShowLoadingEvent());

    BaseResponse<OrderEntity> startResult = await _startOrderUseCase(orderId);

    if (startResult is ErrorBaseResponse) {
      emitUiEvent(HideLoadingEvent());
      emit(
        state.copyWith(
          orderDetailsState: BaseState(
            errorMessage: (startResult as ErrorBaseResponse).errorMessage,
          ),
        ),
      );
      return;
    }
    emitUiEvent(HideLoadingEvent());
    _onUpdateOrderState(OrderStatus.accepted);
  }

  Future<void> _onUpdateOrderState(OrderStatus newStatus) async {
    final orderId = state.data?.id;
    if (orderId == null) return;

    emitUiEvent(ShowLoadingEvent());

    final result = await _updateOrderStateUseCase(orderId, newStatus);

    emitUiEvent(HideLoadingEvent());

    switch (result) {
      case SuccessBaseResponse<OrderEntity>():
        emit(
          state.copyWith(
            orderDetailsState: BaseState(data: result.data),
            orderStatus: newStatus,
          ),
        );
      case ErrorBaseResponse<OrderEntity>():
        emitUiEvent(DisplayErrorEvent(result.errorMessage));
    }
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
    // Preparation for next sprint: extract coordinates and navigate
    final lat = type == LocationType.store
        ? state.data?.store?.lat
        : state.data?.shippingAddress?.lat;
    final long = type == LocationType.store
        ? state.data?.store?.long
        : state.data?.shippingAddress?.long;

    if (lat != null && long != null) {
      // emitUiEvent(NavigateToMapScreenEvent(lat, long));
    }
  }
}
