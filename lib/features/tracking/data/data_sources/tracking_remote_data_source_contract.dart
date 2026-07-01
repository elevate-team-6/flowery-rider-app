import 'package:flowery_rider_app/config/base_response/base_response.dart';

import '../models/request/update_order_state_request_model.dart';
import '../models/response/all_driver_orders_response_model.dart';
import '../models/response/pending_orders_response_model.dart';
import '../models/response/update_order_state_response_model.dart';

abstract interface class TrackingRemoteDataSourceContract {
  Future<BaseResponse<AllDriverOrdersResponseModel>> getDriverOrders();

  Future<BaseResponse<UpdateOrderStateResponseModel>> startOrder(String id);

  Future<BaseResponse<UpdateOrderStateResponseModel>> updateOrderState(
    String id,
    OrderStatus state,
  );

  Future<BaseResponse<PendingOrdersResponseModel>> getPendingOrders({
    int? page,
  });
}
