import 'package:equatable/equatable.dart';

import '../../../domain/entities/order_entity.dart';

sealed class OrdersScreenEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetDriverOrdersEvent extends OrdersScreenEvents {}

class RefreshOrdersEvent extends OrdersScreenEvents {}

class ChangePageEvent extends OrdersScreenEvents {
  final int page;
  ChangePageEvent(this.page);

  @override
  List<Object?> get props => [page];
}

class OrderTappedEvent extends OrdersScreenEvents {
  final OrderEntity order;
  OrderTappedEvent(this.order);

  @override
  List<Object?> get props => [order];
}
