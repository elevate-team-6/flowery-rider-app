import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/error_handler/error_handler.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/all_driver_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/update_order_state_response_model.dart';
import 'package:injectable/injectable.dart';

import '../../data/data_sources/tracking_remote_data_source_contract.dart';
import '../../data/models/response/pending_orders_response_model.dart';
import '../api_client/tracking_api_client.dart';

@Injectable(as: TrackingRemoteDataSourceContract)
class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSourceContract {
  final TrackingApiClient _apiClient;

  TrackingRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<AllDriverOrdersResponseModel>> getDriverOrders() {
    return ErrorHandler.handleApiCall(() => _apiClient.getDriverOrders());
  }

  @override
  Future<BaseResponse<UpdateOrderStateResponseModel>> startOrder(String id) {
    return ErrorHandler.handleApiCall(() => _apiClient.startOrder(id));
  }

  @override
  Future<BaseResponse<UpdateOrderStateResponseModel>> updateOrderState(
    String id,
    OrderStatus state,
  ) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.updateOrderState(
        id,
        UpdateOrderStateRequestModel(state: state),
      ),
    );
  }

  @override
  Future<BaseResponse<PendingOrdersResponseModel>> getPendingOrders({
    int? page,
  }) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.getPendingOrders(page: page),
    );
  }
}
