import '../../../domain/entities/order_entity.dart';

sealed class HomeEvents {
  const HomeEvents();
}

class GetPendingOrdersEvent extends HomeEvents {
  final int? page;

  const GetPendingOrdersEvent({this.page});
}

/// Driver accepted the order → navigate to the order details screen.
class AcceptOrderEvent extends HomeEvents {
  final OrderEntity order;

  const AcceptOrderEvent(this.order);
}

/// Driver rejected the order → remove it from the pending list locally
/// (a refresh re-fetches it from the server).
class RejectOrderEvent extends HomeEvents {
  final String orderId;

  const RejectOrderEvent(this.orderId);
}
