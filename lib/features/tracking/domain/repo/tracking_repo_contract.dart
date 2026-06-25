import 'package:flowery_rider_app/config/base_response/base_response.dart';

import '../entities/order_entity.dart';

abstract interface class TrackingRepoContract {
  Future<BaseResponse<PendingOrdersEntity>> getPendingOrders({int? page});
}
