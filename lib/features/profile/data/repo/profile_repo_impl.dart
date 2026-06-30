import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/cache/secure_cache_helper.dart';
import '../../../../core/exceptions/missing_field_exception.dart';
import '../../../../core/utils/app_keys.dart';
import '../../../../core/utils/app_strings.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/repo/profile_repo_contract.dart';
import '../data_sources/profile_remote_data_source_contract.dart';
import '../models/request/edit_profile_request.dart';
import '../models/response/profile_response_model.dart';

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
  ) async {
    final result = await _remoteDataSource.changePassword(
      password,
      newPassword,
    );

    switch (result) {
      case SuccessBaseResponse<String>():
        if (result.data != null && result.data!.isNotEmpty) {
          await _secureCacheHelper.writeData(
            key: AppKeys.tokenKey,
            value: result.data!,
          );
        }
        return result;

      case ErrorBaseResponse<String>():
        return result;
    }
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
      SuccessBaseResponse<ProfileResponseModel>() => _mapDriver(result.data),
      ErrorBaseResponse<ProfileResponseModel>() => ErrorBaseResponse(
        result.errorMessage,
      ),
    };
  }

  BaseResponse<DriverEntity> _mapDriver(ProfileResponseModel? data) {
    try {
      return SuccessBaseResponse(data?.driver?.toEntity());
    } on MissingFieldException {
      return ErrorBaseResponse(AppStrings.unexpectedError.tr());
    }
  }
}
