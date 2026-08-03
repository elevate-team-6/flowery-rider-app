import 'package:equatable/equatable.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

/// An active order restored from the local cache together with the UI step the
/// rider had reached, so the flow can resume exactly where it was left.
class CachedActiveOrder extends Equatable {
  final OrderEntity order;
  final int uiStep;

  const CachedActiveOrder({required this.order, required this.uiStep});

  @override
  List<Object?> get props => [order, uiStep];
}
