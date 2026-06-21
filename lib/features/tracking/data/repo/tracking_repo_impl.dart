import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/cache/secure_cache_helper.dart';
import '../../domain/entites/order_entity.dart';
import '../../domain/repo/tracking_repo_contract.dart';
import '../data_sources/tracking_remote_data_source_contract.dart';
import '../models/response/pending_orders_response_model.dart';

@Injectable(as: TrackingRepoContract)
class TrackingRepoImpl implements TrackingRepoContract {
  final TrackingRemoteDataSourceContract _remoteDataSource;
  // ignore: unused_field
  final SecureCacheHelper _secureCacheHelper;

  TrackingRepoImpl(this._remoteDataSource, this._secureCacheHelper);

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
