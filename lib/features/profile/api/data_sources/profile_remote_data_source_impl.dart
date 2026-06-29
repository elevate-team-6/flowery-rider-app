import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/error_handler/error_handler.dart';
import '../../data/data_sources/profile_remote_data_source_contract.dart';
import '../api_client/profile_api_client.dart';

@Injectable(as: ProfileRemoteDataSourceContract)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSourceContract {
  final ProfileApiClient _apiClient;

  ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BaseResponse<void>> logout() async {
    return await ErrorHandler.handleApiCall(() => _apiClient.logout());
  }

  @override
  Future<BaseResponse<ProfileResponse>> profile() async {
    return await ErrorHandler.handleApiCall(() => _apiClient.profile());
  }
}
