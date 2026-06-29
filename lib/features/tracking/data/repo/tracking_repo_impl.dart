import 'dart:convert';

import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/hive_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/features/tracking/data/data_sources/tracking_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/all_driver_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/pending_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/update_order_state_response_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: TrackingRepoContract)
class TrackingRepoImpl implements TrackingRepoContract {
  final TrackingRemoteDataSourceContract _remoteDataSource;
  final HiveHelper _hiveHelper;

  TrackingRepoImpl(this._remoteDataSource, this._hiveHelper);

  @override
  Future<BaseResponse<DriverOrdersEntity>> getDriverOrders({int? page}) async {
    final response = await _remoteDataSource.getDriverOrders(page: page);
    return switch (response) {
      SuccessBaseResponse<AllDriverOrdersResponseModel>() => _handleMapping(() {
        final orders =
            response.data?.orders?.map((e) => e.toEntity()).toList() ?? [];
        return DriverOrdersEntity(
          orders: orders,
          currentPage: response.data?.metadata?.currentPage ?? 1,
          totalPages: response.data?.metadata?.totalPages ?? 1,
        );
      }),
      ErrorBaseResponse<AllDriverOrdersResponseModel>() => ErrorBaseResponse(
        response.errorMessage,
      ),
    };
  }

  @override
  Future<BaseResponse<OrderEntity>> startOrder(String id) async {
    final response = await _remoteDataSource.startOrder(id);
    return switch (response) {
      SuccessBaseResponse<UpdateOrderStateResponseModel>() => _handleMapping(
        () => response.data?.order?.toEntity(),
      ),
      ErrorBaseResponse<UpdateOrderStateResponseModel>() => ErrorBaseResponse(
        response.errorMessage,
      ),
    };
  }

  @override
  Future<BaseResponse<OrderEntity>> updateOrderState(
    String id,
    OrderStatus state,
  ) async {
    final response = await _remoteDataSource.updateOrderState(id, state);
    return switch (response) {
      SuccessBaseResponse<UpdateOrderStateResponseModel>() => _handleMapping(
        () => response.data?.order?.toEntity(),
      ),
      ErrorBaseResponse<UpdateOrderStateResponseModel>() => ErrorBaseResponse(
        response.errorMessage,
      ),
    };
  }

  @override
  Future<BaseResponse<PendingOrdersEntity>> getPendingOrders({
    int? page,
  }) async {
    final response = await _remoteDataSource.getPendingOrders(page: page);
    return switch (response) {
      SuccessBaseResponse<PendingOrdersResponseModel>() => _handleMapping(
        () => response.data?.toEntity(),
      ),
      ErrorBaseResponse<PendingOrdersResponseModel>() => ErrorBaseResponse(
        response.errorMessage,
      ),
    };
  }

  @override
  Future<void> cacheActiveOrder(OrderEntity order, int uiStep) async {
    final cacheData = {AppKeys.order: order.toJson(), AppKeys.uiStep: uiStep};

    _hiveHelper.cacheData(
      boxName: AppKeys.activeOrderBox,
      key: AppKeys.activeOrderKey,
      value: jsonEncode(cacheData),
    );
  }

  @override
  Future<Map<String, dynamic>?> getCachedActiveOrder() async {
    final data = _hiveHelper.getData(
      boxName: AppKeys.activeOrderBox,
      key: AppKeys.activeOrderKey,
    );
    return jsonDecode(data as String) as Map<String, dynamic>;
  }

  @override
  Future<void> clearCachedActiveOrder() async {
    _hiveHelper.deleteData(
      boxName: AppKeys.activeOrderBox,
      key: AppKeys.activeOrderKey,
    );
  }

  /// Helper to catch mapping exceptions while using switch expressions
  BaseResponse<T> _handleMapping<T>(T? Function() mapper) {
    try {
      final result = mapper();
      if (result == null) return ErrorBaseResponse('Empty data received');
      return SuccessBaseResponse(result);
    } catch (e) {
      return ErrorBaseResponse('Data Mapping Error: ${e.toString()}');
    }
  }
}
