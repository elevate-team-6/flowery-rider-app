import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/error_handler/error_handler.dart';
import 'package:injectable/injectable.dart';

import '../../data/data_sources/tracking_remote_data_source_contract.dart';
import '../../data/models/response/pending_orders_response_model.dart';
import '../api_client/tracking_api_client.dart';

@Injectable(as: TrackingRemoteDataSourceContract)
class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSourceContract {
  final TrackingApiClient _apiClient;

  TrackingRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<PendingOrdersResponseModel>> getPendingOrders({
    int? page,
  }) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.getPendingOrders(page: page),
    );
  }
}
