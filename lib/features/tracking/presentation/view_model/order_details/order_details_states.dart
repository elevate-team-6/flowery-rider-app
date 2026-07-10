import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';

class OrderDetailsState extends Equatable {
  final OrderStatus? orderStatus;
  final int
  uiStep; // 1: Accepted, 2: ArrivedAtPickup, 3: Picked, 4: OutForDelivery, 5: Arrived, 6: Delivered
  final bool? isUserConfirmedDeliverd;
  final BaseState canselOrderState;
  final BaseState orderDetailsState;
  final BaseState updateStepState;

  const OrderDetailsState({
    this.orderStatus,
    this.uiStep = 1,
    this.isUserConfirmedDeliverd,
    this.canselOrderState = const BaseState(),
    this.orderDetailsState = const BaseState(),
    this.updateStepState = const BaseState(),
  });

  @override
  List<Object?> get props => [
    orderStatus,
    uiStep,
    isUserConfirmedDeliverd,
    canselOrderState,
    orderDetailsState,
    updateStepState,
  ];

  OrderDetailsState copyWith({
    OrderStatus? orderStatus,
    int? uiStep,
    bool? isUserConfirmedDeliverd,
    BaseState? canselOrderState,
    BaseState? orderDetailsState,
    BaseState? updateStepState,
  }) {
    return OrderDetailsState(
      orderStatus: orderStatus ?? this.orderStatus,
      uiStep: uiStep ?? this.uiStep,
      isUserConfirmedDeliverd:
          isUserConfirmedDeliverd ?? this.isUserConfirmedDeliverd,
      canselOrderState: canselOrderState ?? this.canselOrderState,
      orderDetailsState: orderDetailsState ?? this.orderDetailsState,
      updateStepState: updateStepState ?? this.updateStepState,
    );
  }
}
