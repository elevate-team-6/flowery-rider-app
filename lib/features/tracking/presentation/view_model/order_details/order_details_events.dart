import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

sealed class OrderDetailsEvents {}

class InitializeOrderDetailsEvent extends OrderDetailsEvents {
  final OrderEntity order;

  InitializeOrderDetailsEvent(this.order);
}

class NextStepEvent extends OrderDetailsEvents {}

class ConfirmBackButtonPressedEvent extends OrderDetailsEvents {}

class RevertOrderToPendingEvent extends OrderDetailsEvents {
  final String orderId;

  RevertOrderToPendingEvent(this.orderId);
}

class NavigateToMapEvent extends OrderDetailsEvents {
  final LocationType locationType;

  NavigateToMapEvent(this.locationType);
}

class CallPhoneEvent extends OrderDetailsEvents {
  final String phoneNumber;

  CallPhoneEvent(this.phoneNumber);
}

class OpenWhatsAppEvent extends OrderDetailsEvents {
  final String phoneNumber;

  OpenWhatsAppEvent(this.phoneNumber);
}

enum LocationType { store, user }
