import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

abstract interface class TrackingRepoContract {
  Future<BaseResponse<DriverOrdersEntity>> getDriverOrders({int? page});

  Future<BaseResponse<OrderEntity>> startOrder(String id);

  Future<BaseResponse<OrderEntity>> updateOrderState(
    String id,
    OrderStatus state,
  );

  Future<BaseResponse<PendingOrdersEntity>> getPendingOrders({int? page});

  Future<void> cacheActiveOrder(OrderEntity order, int uiStep);

  Future<Map<String, dynamic>?> getCachedActiveOrder();

  Future<void> clearCachedActiveOrder();

  Future<ShippingAddressEntity?> getOrderShipping(String orderId);

  Future<void> updateRiderLocation({
    required String orderId,
    required String lat,
    required String long,
  });
}
