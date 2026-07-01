import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';
import 'dart:io';

import 'package:flowery_rider_app/core/entities/driver_entity.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_vehicle_request.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response_model.dart';
import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../../../../config/cache/secure_cache_helper.dart';
import '../../../../core/entities/driver_entity.dart' show DriverEntity;
import '../../../../core/utils/app_keys.dart';
import '../../domain/repo/profile_repo_contract.dart';
import '../data_sources/profile_remote_data_source_contract.dart';
import '../models/request/edit_profile_request.dart';

@Injectable(as: ProfileRepoContract)
class ProfileRepoImpl implements ProfileRepoContract {
  final ProfileRemoteDataSourceContract _remoteDataSource;
  final SecureCacheHelper _secureCacheHelper;

  ProfileRepoImpl(this._remoteDataSource, this._secureCacheHelper);

  @override
  Future<BaseResponse<void>> logout() async {
    final result = await _remoteDataSource.logout();
    await _secureCacheHelper.deleteData(key: AppKeys.tokenKey);
    return result;
  }

  @override
  Future<BaseResponse<String>> changePassword(
    String password,
    String newPassword,
  ) => _remoteDataSource.changePassword(password, newPassword);

  @override
  Future<BaseResponse<DriverEntity>> editVehicle(
    EditVehicleRequest request,
  ) async {
    final response = await _remoteDataSource.editVehicle(request);
    switch (response) {
      case SuccessBaseResponse<ProfileResponseModel>():
        if (response.data == null || response.data!.driver == null) {
          return ErrorBaseResponse(AppStrings.userNotFound);
        }

        return SuccessBaseResponse(response.data!.driver!.toEntity());

      case ErrorBaseResponse<ProfileResponseModel>():
        return ErrorBaseResponse<DriverEntity>(response.errorMessage);
    }
  }

  @override
  Future<BaseResponse<DriverEntity>> getProfileData() async {
    final result = await _remoteDataSource.getProfileData();
    return _mapToEntity(result);
  }

  @override
  Future<BaseResponse<DriverEntity>> editProfile(
    EditProfileRequest request,
  ) async {
    final result = await _remoteDataSource.editProfile(request);
    return _mapToEntity(result);
  }

  @override
  Future<BaseResponse<DriverEntity>> uploadPhoto(File photo) async {
    final result = await _remoteDataSource.uploadPhoto(photo);
    return _mapToEntity(result);
  }

  BaseResponse<DriverEntity> _mapToEntity(
    BaseResponse<ProfileResponseModel> result,
  ) {
    return switch (result) {
      SuccessBaseResponse<ProfileResponseModel>() => SuccessBaseResponse(
        result.data?.driver?.toEntity(),
      ),
      ErrorBaseResponse<ProfileResponseModel>() => ErrorBaseResponse(
        result.errorMessage,
      ),
    };
  }

  @override
  Future<BaseResponse<DriverEntity>> profile() async {
    final response = await _remoteDataSource.profile();
    switch (response) {
      case SuccessBaseResponse<ProfileResponse>():
        if (response.data!.driver != null) {
          return SuccessBaseResponse<DriverEntity>(
            response.data!.driver!.toEntity(),
          );
        } else {
          return ErrorBaseResponse<DriverEntity>(AppStrings.userNotFound);
        }

      case ErrorBaseResponse<ProfileResponse>():
        return ErrorBaseResponse<DriverEntity>(response.errorMessage);
    }
  }
}
