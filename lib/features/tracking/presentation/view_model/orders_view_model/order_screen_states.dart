import 'package:equatable/equatable.dart';

import '../../../../../config/base_state/base_state.dart';
import '../../../domain/entities/order_entity.dart';

class OrderScreenState extends Equatable {
  final BaseState<List<OrderEntity>> ordersState;
  final int cancelledCount;
  final int completedCount;

  const OrderScreenState({
    this.ordersState = const BaseState(),
    this.cancelledCount = 0,
    this.completedCount = 0,
  });

  OrderScreenState copyWith({
    BaseState<List<OrderEntity>>? ordersState,
    int? cancelledCount,
    int? completedCount,
  }) {
    return OrderScreenState(
      ordersState: ordersState ?? this.ordersState,
      cancelledCount: cancelledCount ?? this.cancelledCount,
      completedCount: completedCount ?? this.completedCount,
    );
  }

  @override
  List<Object?> get props => [ordersState, cancelledCount, completedCount];
}
