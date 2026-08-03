import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/hive_helper.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/features/tracking/data/data_sources/tracking_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/all_driver_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/pending_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/cache/order_cache_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/route_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/update_order_state_response_model.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/cached_active_order.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';
import 'package:latlong2/latlong.dart';

@Injectable(as: TrackingRepoContract)
class TrackingRepoImpl implements TrackingRepoContract {
  final TrackingRemoteDataSourceContract _remoteDataSource;
  final HiveHelper _hiveHelper;
  final FirebaseFirestore _firestore;

  TrackingRepoImpl(this._remoteDataSource, this._hiveHelper, this._firestore);

  @override
  Future<BaseResponse<DriverOrdersEntity>> getDriverOrders({int? page}) async {
    final response = await _remoteDataSource.getDriverOrders(page: page);
    return switch (response) {
      SuccessBaseResponse<AllDriverOrdersResponseModel>() =>
        await _handleMappingAsync(() async {
          final orders = <OrderEntity>[];
          if (response.data?.orders != null) {
            for (final orderModel in response.data!.orders!) {
              final entity = orderModel.toEntity();
              orders.add(await _enrichOrderWithFirestoreAddress(entity));
            }
          }
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
      SuccessBaseResponse<UpdateOrderStateResponseModel>() =>
        await _handleMappingAsync(() async {
          final entity = response.data?.order?.toEntity();
          if (entity == null) return null;
          return await _enrichOrderWithFirestoreAddress(entity);
        }),
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
      SuccessBaseResponse<UpdateOrderStateResponseModel>() =>
        await _handleMappingAsync(() async {
          final entity = response.data?.order?.toEntity();
          if (entity == null) return null;
          return await _enrichOrderWithFirestoreAddress(entity);
        }),
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
      SuccessBaseResponse<PendingOrdersResponseModel>() =>
        await _handleMappingAsync(() async {
          final orders = <OrderEntity>[];
          if (response.data?.orders != null) {
            for (final orderModel in response.data!.orders!) {
              final entity = orderModel.toEntity();
              orders.add(await _enrichOrderWithFirestoreAddress(entity));
            }
          }
          final pendingOrders = response.data?.toEntity();
          return PendingOrdersEntity(
            message: pendingOrders?.message ?? '',
            orders: orders,
            currentPage: pendingOrders?.currentPage,
            totalPages: pendingOrders?.totalPages,
          );
        }),
      ErrorBaseResponse<PendingOrdersResponseModel>() => ErrorBaseResponse(
        response.errorMessage,
      ),
    };
  }

  @override
  Future<void> cacheActiveOrder(OrderEntity order, int uiStep) async {
    final cacheData = {
      AppKeys.order: OrderCacheModel.fromEntity(order).toJson(),
      AppKeys.uiStep: uiStep,
    };

    await _hiveHelper.cacheData(
      boxName: AppKeys.activeOrderBox,
      key: AppKeys.activeOrderKey,
      value: jsonEncode(cacheData),
    );
  }

  @override
  Future<CachedActiveOrder?> getCachedActiveOrder() async {
    final String? data = await _hiveHelper.getData<String>(
      boxName: AppKeys.activeOrderBox,
      key: AppKeys.activeOrderKey,
    );
    if (data == null) return null;

    final map = jsonDecode(data) as Map<String, dynamic>;
    return CachedActiveOrder(
      order: OrderCacheModel.fromJson(
        map[AppKeys.order] as Map<String, dynamic>,
      ).toEntity(),
      uiStep: map[AppKeys.uiStep] as int,
    );
  }

  @override
  Future<void> clearCachedActiveOrder() async {
    await _hiveHelper.deleteData(
      boxName: AppKeys.activeOrderBox,
      key: AppKeys.activeOrderKey,
    );
  }

  @override
  Future<List<LatLng>> getRoute(LatLng start, LatLng end) async {
    final response = await _remoteDataSource.getRoute(start, end);
    return switch (response) {
      SuccessBaseResponse<RouteResponseModel>() =>
        response.data?.toEntity() ?? const [],
      ErrorBaseResponse<RouteResponseModel>() => const [],
    };
  }

  @override
  Future<ShippingAddressEntity?> getOrderShipping(String orderId) async {
    try {
      final model = await _remoteDataSource.getOrderShipping(orderId);
      return model?.toEntity();
    } catch (_) {
      // Best-effort read: on any Firestore failure fall back to the backend
      // address the map already has.
      return null;
    }
  }

  @override
  Future<void> updateRiderLocation({
    required String orderId,
    required String lat,
    required String long,
  }) async {
    try {
      await _remoteDataSource.updateRiderLocation(
        orderId: orderId,
        lat: lat,
        long: long,
      );
    } catch (_) {
      // Best-effort write: a dropped location tick must never disrupt the map
      // or the delivery flow; the next tick will retry.
    }
  }

  /// Fetches missing address from Firestore if API address is incomplete
  Future<OrderEntity> _enrichOrderWithFirestoreAddress(
    OrderEntity order,
  ) async {
    // Current mapping uses '_' as fallback for missing street/city
    final isAddressMissing =
        order.shippingAddress.street == '_' ||
        order.shippingAddress.street.isEmpty ||
        order.shippingAddress.city == '_' ||
        order.shippingAddress.city.isEmpty;

    if (!isAddressMissing) return order;

    try {
      final doc = await _firestore
          .collection(AppConstants.ordersCollection)
          .doc(order.id)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final shipping = data['shippingAddress'] as Map<String, dynamic>?;

        if (shipping != null) {
          return order.copyWith(
            shippingAddress: ShippingAddressEntity(
              street:
                  shipping['street']?.toString() ??
                  order.shippingAddress.street,
              city: shipping['city']?.toString() ?? order.shippingAddress.city,
              phone:
                  shipping['phone']?.toString() ?? order.shippingAddress.phone,
              lat: shipping['lat']?.toString() ?? order.shippingAddress.lat,
              long: shipping['long']?.toString() ?? order.shippingAddress.long,
            ),
          );
        }
      }
    } catch (e) {
      // In case of error, we keep the original order data
    }
    return order;
  }

  /// Async version of mapping helper
  Future<BaseResponse<T>> _handleMappingAsync<T>(
    Future<T?> Function() mapper,
  ) async {
    try {
      final result = await mapper();
      if (result == null) return ErrorBaseResponse('Empty data received');
      return SuccessBaseResponse(result);
    } catch (e) {
      return ErrorBaseResponse('Data Mapping Error: ${e.toString()}');
    }
  }
}
