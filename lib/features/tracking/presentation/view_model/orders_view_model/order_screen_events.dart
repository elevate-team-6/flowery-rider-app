import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

sealed class OrderDetailsEvents extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderDetailsInitializeEvent extends OrderDetailsEvents {
  final OrderEntity order;
  final int? initialStep;

  OrderDetailsInitializeEvent(this.order, {this.initialStep});

  @override
  List<Object?> get props => [order, initialStep];
}

class OrderDetailsNextStepEvent extends OrderDetailsEvents {}

class ConfirmBackButtonPressedEvent extends OrderDetailsEvents {}

class RevertOrderToPendingEvent extends OrderDetailsEvents {
  final String orderId;

  RevertOrderToPendingEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class NavigateToMapEvent extends OrderDetailsEvents {
  final LocationType locationType;

  NavigateToMapEvent(this.locationType);

  @override
  List<Object?> get props => [locationType];
}

class CallPhoneEvent extends OrderDetailsEvents {
  final String phoneNumber;

  CallPhoneEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class OpenWhatsAppEvent extends OrderDetailsEvents {
  final String phoneNumber;

  OpenWhatsAppEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

enum LocationType { store, user }
