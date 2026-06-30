import 'package:flowery_rider_app/features/profile/data/models/request/change_password_request.dart';
import 'dart:io';

import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';
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
  Future<BaseResponse<String>> changePassword(
    String password,
    String newPassword,
  ) async {
    final result = await ErrorHandler.handleApiCall(
      () => _apiClient.changePassword(
        ChangePasswordRequest(password: password, newPassword: newPassword),
      ),
    );

    return switch (result) {
      SuccessBaseResponse(:final data) => SuccessBaseResponse<String>(
        data?.token ?? '',
      ),

      ErrorBaseResponse(:final errorMessage) => ErrorBaseResponse<String>(
        errorMessage,
      ),
    };
  }

  @override
  Future<BaseResponse<ProfileResponse>> profile() async {
    return await ErrorHandler.handleApiCall(() => _apiClient.profile());
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
