import 'package:equatable/equatable.dart';

import '../../../../../config/base_state/base_state.dart';
import '../../../domain/entities/order_entity.dart';

class OrderScreenState extends Equatable {
  final BaseState<List<OrderEntity>> ordersState;
  final int cancelledCount;
  final int completedCount;
  final int currentPage;
  final int totalPages;

  const OrderScreenState({
    this.ordersState = const BaseState(),
    this.cancelledCount = 0,
    this.completedCount = 0,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  OrderScreenState copyWith({
    BaseState<List<OrderEntity>>? ordersState,
    int? cancelledCount,
    int? completedCount,
    int? currentPage,
    int? totalPages,
  }) {
    return OrderScreenState(
      ordersState: ordersState ?? this.ordersState,
      cancelledCount: cancelledCount ?? this.cancelledCount,
      completedCount: completedCount ?? this.completedCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [
    ordersState,
    cancelledCount,
    completedCount,
    currentPage,
    totalPages,
  ];
}
