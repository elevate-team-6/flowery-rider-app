import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetActiveOrderFromBackendUseCase {
  final TrackingRepoContract _repository;

  GetActiveOrderFromBackendUseCase(this._repository);

  /// Returns the driver's currently active (inProgress) order from the backend
  /// — the source of truth — or null if none exists.
  Future<OrderEntity?> call() async {
    final response = await _repository.getDriverOrders();
    if (response is SuccessBaseResponse<DriverOrdersEntity>) {
      final DriverOrdersEntity? driverOrders = response.data;
      if (driverOrders == null) {
        return null;
      }

      final orders = driverOrders.orders;
      for (final order in orders) {
        if (OrderStatus.fromString(order.state) == OrderStatus.inProgress) {
          return order;
        }
      }
    }
    return null;
  }
}
