import '../../../data/models/request/update_order_state_request_model.dart';

sealed class OrderDetailsEvents {}

class InitializeOrderDetailsEvent extends OrderDetailsEvents {
  final String orderId;

  InitializeOrderDetailsEvent(this.orderId);
}

class UpdateOrderStateEvent extends OrderDetailsEvents {
  final OrderStatus newStatus;

  UpdateOrderStateEvent(this.newStatus);
}

class ConfirmBackButtonPressedEvent extends OrderDetailsEvents {}

class RevertOrderToPendingEvent extends OrderDetailsEvents {
  final String orderId;

  RevertOrderToPendingEvent(this.orderId);
}

class NavigateToMapEvent extends OrderDetailsEvents {
  final LocationType locationType;

  NavigateToMapEvent(this.locationType);
}

enum LocationType { store, user }
