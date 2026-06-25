import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/error_handler/error_handler.dart';
import '../../data/data_sources/profile_remote_data_source_contract.dart';
import '../../data/models/request/edit_profile_request.dart';
import '../../data/models/response/profile_response_model.dart';
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
  Future<BaseResponse<ProfileResponseModel>> getProfileData() async {
    return await ErrorHandler.handleApiCall(() => _apiClient.getProfileData());
  }

  @override
  Future<BaseResponse<ProfileResponseModel>> editProfile(
    EditProfileRequest request,
  ) async {
    return await ErrorHandler.handleApiCall(
      () => _apiClient.editProfile(request),
    );
  }

  @override
  Future<BaseResponse<ProfileResponseModel>> uploadPhoto(File photo) async {
    return await ErrorHandler.handleApiCall(
      () => _apiClient.uploadPhoto(photo),
    );
  }
}
