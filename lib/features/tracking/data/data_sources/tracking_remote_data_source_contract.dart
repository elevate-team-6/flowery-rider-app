import 'package:flowery_rider_app/config/base_response/base_response.dart';

import '../models/request/update_order_state_request_model.dart';
import '../models/response/driver_orders_response_model.dart';
import '../models/response/order_action_response_model.dart';
import '../models/response/pending_orders_response_model.dart';

abstract interface class TrackingRemoteDataSourceContract {
  Future<BaseResponse<DriverOrdersResponseModel>> getDriverOrders();

  Future<BaseResponse<OrderActionResponseModel>> startOrder(String id);

  Future<BaseResponse<OrderActionResponseModel>> updateOrderState(
    String id,
    OrderStatus state,
  );

  Future<BaseResponse<PendingOrdersResponseModel>> getPendingOrders({
    int? page,
  });
}
}
