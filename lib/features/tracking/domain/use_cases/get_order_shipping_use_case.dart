import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

/// Reads the customer's shipping address for an order from Firestore (one-time).
/// Returns null when Firestore has none, so the caller keeps the backend one.
@injectable
class GetOrderShippingUseCase {
  final TrackingRepoContract _repository;

  GetOrderShippingUseCase(this._repository);

  Future<ShippingAddressEntity?> call(String orderId) {
    return _repository.getOrderShipping(orderId);
  }
}
