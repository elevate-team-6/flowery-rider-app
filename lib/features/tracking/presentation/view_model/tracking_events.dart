import '../../domain/entites/order_entity.dart';

sealed class TrackingEvents {
  const TrackingEvents();
}

class GetPendingOrdersEvent extends TrackingEvents {
  final int? page;

  const GetPendingOrdersEvent({this.page});
}

/// Driver accepted the order → navigate to the order details screen.
class AcceptOrderEvent extends TrackingEvents {
  final OrderEntity order;

  const AcceptOrderEvent(this.order);
}

/// Driver rejected the order → remove it from the pending list locally
/// (a refresh re-fetches it from the server).
class RejectOrderEvent extends TrackingEvents {
  final String orderId;

  const RejectOrderEvent(this.orderId);
}
