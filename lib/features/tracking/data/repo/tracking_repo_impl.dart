import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/tracking/data/data_sources/tracking_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/driver_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/order_action_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/pending_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: TrackingRepoContract)
class TrackingRepoImpl implements TrackingRepoContract {
  final TrackingRemoteDataSourceContract _remoteDataSource;

  TrackingRepoImpl(this._remoteDataSource);

  @override
  Future<BaseResponse<List<OrderEntity>>> getDriverOrders() async {
    final result = await _remoteDataSource.getDriverOrders();
    return switch (result) {
      SuccessBaseResponse<DriverOrdersResponseModel>() => SuccessBaseResponse(
        result.data?.orders?.map((e) => e.toEntity()).toList(),
      ),
      ErrorBaseResponse<DriverOrdersResponseModel>() => ErrorBaseResponse(
        result.errorMessage,
      ),
    };
  }

  @override
  Future<BaseResponse<OrderEntity>> startOrder(String id) async {
    final result = await _remoteDataSource.startOrder(id);
    return switch (result) {
      SuccessBaseResponse<OrderActionResponseModel>() => SuccessBaseResponse(
        result.data?.order?.toEntity(),
      ),
      ErrorBaseResponse<OrderActionResponseModel>() => ErrorBaseResponse(
        result.errorMessage,
      ),
    };
  }

  @override
  Future<BaseResponse<OrderEntity>> updateOrderState(
    String id,
    OrderStatus state,
  ) async {
    final result = await _remoteDataSource.updateOrderState(id, state);
    return switch (result) {
      SuccessBaseResponse<OrderActionResponseModel>() => SuccessBaseResponse(
        result.data?.order?.toEntity(),
      ),
      ErrorBaseResponse<OrderActionResponseModel>() => ErrorBaseResponse(
        result.errorMessage,
      ),
    };
  }

  @override
  Future<BaseResponse<PendingOrdersEntity>> getPendingOrders({
    int? page,
  }) async {
    final response = await _remoteDataSource.getPendingOrders(page: page);
    return switch (response) {
      SuccessBaseResponse<PendingOrdersResponseModel>() => SuccessBaseResponse(
        response.data?.toEntity(),
      ),
      ErrorBaseResponse<PendingOrdersResponseModel>() => ErrorBaseResponse(
        response.errorMessage,
      ),
    };
  }
}
