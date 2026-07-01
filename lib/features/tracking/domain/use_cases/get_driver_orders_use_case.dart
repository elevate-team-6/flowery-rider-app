import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/driver_orders_summary.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_status.dart';
import 'package:flowery_rider_app/features/tracking/domain/repo/tracking_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetDriverOrdersUseCase {
  final TrackingRepoContract _repository;

  GetDriverOrdersUseCase(this._repository);

  Future<BaseResponse<DriverOrdersSummary>> call({int? page}) async {
    final response = await _repository.getDriverOrders(page: page);

    return switch (response) {
      SuccessBaseResponse<DriverOrdersEntity>() => _handleSuccess(
        response.data,
      ),
      ErrorBaseResponse<DriverOrdersEntity>() => ErrorBaseResponse(
        response.errorMessage,
      ),
    };
  }

  BaseResponse<DriverOrdersSummary> _handleSuccess(DriverOrdersEntity? data) {
    if (data == null) return SuccessBaseResponse(null);

    final completedCount = data.orders
        .where((o) => o.state.toLowerCase() == DriverOrderState.completed.value)
        .length;
    final canceledCount = data.orders
        .where((o) => o.state.toLowerCase() == DriverOrderState.canceled.value)
        .length;

    return SuccessBaseResponse(
      DriverOrdersSummary(
        driverOrders: data,
        completedCount: completedCount,
        canceledCount: canceledCount,
      ),
    );
  }
}
