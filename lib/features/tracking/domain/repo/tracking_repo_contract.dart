import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';

import '../../data/models/request/update_order_state_request_model.dart';

abstract interface class TrackingRepoContract {
  Future<BaseResponse<List<OrderEntity>>> getDriverOrders();

  Future<BaseResponse<OrderEntity>> startOrder(String id);

  Future<BaseResponse<OrderEntity>> updateOrderState(
    String id,
    OrderStatus state,
  );
}
