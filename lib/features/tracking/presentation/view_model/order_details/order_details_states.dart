import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

class OrderDetailsState extends BaseState<OrderEntity> {
  final OrderStatus? orderStatus;
  final BaseState canselOrderState;
  final BaseState orderDetailsState;

  const OrderDetailsState({
    this.orderStatus,
    this.canselOrderState = const BaseState(),
    this.orderDetailsState = const BaseState(),
  });

  @override
  List<Object?> get props => [isLoading, data, errorMessage, orderStatus];

  OrderDetailsState copyWith({
    OrderStatus? orderStatus,
    BaseState? canselOrderState,
    BaseState? orderDetailsState,
  }) {
    return OrderDetailsState(
      orderStatus: orderStatus ?? this.orderStatus,
      canselOrderState: canselOrderState ?? this.canselOrderState,
      orderDetailsState: orderDetailsState ?? this.orderDetailsState,
    );
  }
}
