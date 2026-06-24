import 'package:dio/dio.dart';
import 'package:flowery_rider_app/core/utils/app_end_points.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/driver_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/order_action_response_model.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'tracking_api_client.g.dart';

@lazySingleton
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class TrackingApiClient {
  @factoryMethod
  factory TrackingApiClient(Dio dio) = _TrackingApiClient;

  @GET(AppEndPoints.driverOrders)
  Future<DriverOrdersResponseModel> getDriverOrders();

  @PUT('${AppEndPoints.startOrder}{id}')
  Future<OrderActionResponseModel> startOrder(@Path('id') String id);

  @PUT('${AppEndPoints.updateOrderState}{id}')
  Future<OrderActionResponseModel> updateOrderState(
    @Path('id') String id,
    @Body() UpdateOrderStateRequestModel stateRequest,
  );
}
