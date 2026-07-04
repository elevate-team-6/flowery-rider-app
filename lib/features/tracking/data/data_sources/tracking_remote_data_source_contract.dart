import 'package:flowery_rider_app/config/base_response/base_response.dart';

import '../models/request/update_order_state_request_model.dart';
import '../models/response/all_driver_orders_response_model.dart';
import '../models/response/order_shipping_firestore_model.dart';
import '../models/response/pending_orders_response_model.dart';
import '../models/response/update_order_state_response_model.dart';

abstract interface class TrackingRemoteDataSourceContract {
  Future<BaseResponse<AllDriverOrdersResponseModel>> getDriverOrders({
    int? page,
  });

  Future<BaseResponse<UpdateOrderStateResponseModel>> startOrder(String id);

  Future<BaseResponse<UpdateOrderStateResponseModel>> updateOrderState(
    String id,
    OrderStatus state,
  );

  Future<BaseResponse<PendingOrdersResponseModel>> getPendingOrders({
    int? page,
  });

  Future<OrderShippingFirestoreModel?> getOrderShipping(String orderId);

  /// Writes the rider's live position onto the order doc in Firestore so the
  /// customer app can show the rider moving on the map. Merges to avoid
  /// clobbering fields owned by the customer app (shippingAddress, etc.).
  Future<void> updateRiderLocation({
    required String orderId,
    required String lat,
    required String long,
  });
}
