import 'package:injectable/injectable.dart';

import '../../data/data_sources/tracking_remote_data_source_contract.dart';
import '../api_client/tracking_api_client.dart';

@Injectable(as: TrackingRemoteDataSourceContract)
class TrackingRemoteDataSourceImpl implements TrackingRemoteDataSourceContract {
  // ignore: unused_field
  final TrackingApiClient _apiClient;

  TrackingRemoteDataSourceImpl(this._apiClient);
}
