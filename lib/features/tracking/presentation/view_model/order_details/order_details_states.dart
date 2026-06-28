import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

class OrderDetailsState extends BaseState<OrderEntity> {
  final OrderStatus? orderStatus;
  final int
  uiStep; // 1: Accepted, 2: ArrivedAtPickup, 3: Picked, 4: OutForDelivery, 5: Arrived, 6: Delivered
  final BaseState canselOrderState;
  final BaseState orderDetailsState;
  final BaseState updateStepState;

  const OrderDetailsState({
    this.orderStatus,
    this.uiStep = 1,
    this.canselOrderState = const BaseState(),
    this.orderDetailsState = const BaseState(),
    this.updateStepState = const BaseState(),
  });

  @override
  List<Object?> get props => [
    isLoading,
    data,
    errorMessage,
    orderStatus,
    uiStep,
    canselOrderState,
    orderDetailsState,
    updateStepState,
  ];

  OrderDetailsState copyWith({
    OrderStatus? orderStatus,
    int? uiStep,
    BaseState? canselOrderState,
    BaseState? orderDetailsState,
    BaseState? updateStepState,
  }) {
    return OrderDetailsState(
      orderStatus: orderStatus ?? this.orderStatus,
      uiStep: uiStep ?? this.uiStep,
      canselOrderState: canselOrderState ?? this.canselOrderState,
      orderDetailsState: orderDetailsState ?? this.orderDetailsState,
      updateStepState: updateStepState ?? this.updateStepState,
    );
  }
}
