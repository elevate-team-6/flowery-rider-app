import 'dart:io';

import 'package:flowery_rider_app/core/entities/driver_entity.dart';
import 'package:flowery_rider_app/core/models/rider_session_model.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_vehicle_request.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';
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
    final response = await _remoteDataSource.logout();
    return switch (response) {
      SuccessBaseResponse() || ErrorBaseResponse() => await () async {
        await _secureCacheHelper.deleteData(key: AppKeys.tokenKey);
        await _secureCacheHelper.deleteData(key: AppKeys.userIdKey);
        await _secureCacheHelper.deleteData(key: AppKeys.riderNameKey);
        await _secureCacheHelper.deleteData(key: AppKeys.riderPhoneKey);
        return response;
      }(),
    };
  }

  @override
  Future<BaseResponse<String>> changePassword(
    String password,
    String newPassword,
  ) async {
    final response = await _remoteDataSource.changePassword(
      password,
      newPassword,
    );
    return switch (response) {
      SuccessBaseResponse<String>() => response,
      ErrorBaseResponse<String>() => response,
    };
  }

  @override
  Future<BaseResponse<DriverEntity>> editVehicle(
    EditVehicleRequest request,
  ) async {
    final response = await _remoteDataSource.editVehicle(request);
    return switch (response) {
      SuccessBaseResponse<ProfileResponseModel>(data: final data)
          when data?.driver != null =>
        await _processSuccess(data!.driver!.toEntity()),
      SuccessBaseResponse() => ErrorBaseResponse<DriverEntity>(
        AppStrings.userNotFound,
      ),
      ErrorBaseResponse(errorMessage: final msg) =>
        ErrorBaseResponse<DriverEntity>(msg),
    };
  }

  @override
  Future<BaseResponse<DriverEntity>> getProfileData() async {
    final response = await _remoteDataSource.getProfileData();
    return switch (response) {
      SuccessBaseResponse<ProfileResponseModel>(data: final data)
          when data?.driver != null =>
        await _processSuccess(data!.driver!.toEntity()),
      SuccessBaseResponse() => ErrorBaseResponse<DriverEntity>(
        AppStrings.userNotFound,
      ),
      ErrorBaseResponse(errorMessage: final msg) =>
        ErrorBaseResponse<DriverEntity>(msg),
    };
  }

  @override
  Future<BaseResponse<DriverEntity>> editProfile(
    EditProfileRequest request,
  ) async {
    final response = await _remoteDataSource.editProfile(request);
    return switch (response) {
      SuccessBaseResponse<ProfileResponseModel>(data: final data)
          when data?.driver != null =>
        await _processSuccess(data!.driver!.toEntity()),
      SuccessBaseResponse() => ErrorBaseResponse<DriverEntity>(
        AppStrings.userNotFound,
      ),
      ErrorBaseResponse(errorMessage: final msg) =>
        ErrorBaseResponse<DriverEntity>(msg),
    };
  }

  @override
  Future<BaseResponse<DriverEntity>> uploadPhoto(File photo) async {
    final response = await _remoteDataSource.uploadPhoto(photo);
    return switch (response) {
      SuccessBaseResponse<ProfileResponseModel>(data: final data)
          when data?.driver != null =>
        await _processSuccess(data!.driver!.toEntity()),
      SuccessBaseResponse() => ErrorBaseResponse<DriverEntity>(
        AppStrings.userNotFound,
      ),
      ErrorBaseResponse(errorMessage: final msg) =>
        ErrorBaseResponse<DriverEntity>(msg),
    };
  }

  @override
  Future<BaseResponse<DriverEntity>> profile() async {
    final response = await _remoteDataSource.profile();
    return switch (response) {
      SuccessBaseResponse<ProfileResponse>(data: final data)
          when data?.driver != null =>
        await _processSuccess(data!.driver!.toEntity()),
      SuccessBaseResponse() => ErrorBaseResponse<DriverEntity>(
        AppStrings.userNotFound,
      ),
      ErrorBaseResponse(errorMessage: final msg) =>
        ErrorBaseResponse<DriverEntity>(msg),
    };
  }

  Future<BaseResponse<DriverEntity>> _processSuccess(
    DriverEntity driver,
  ) async {
    await _cacheRiderSession(
      RiderSessionModel(
        id: driver.id,
        name: '${driver.firstName} ${driver.lastName}',
        phone: driver.phone,
      ),
    );
    return SuccessBaseResponse(driver);
  }

  Future<void> _cacheRiderSession(RiderSessionModel session) async {
    await _secureCacheHelper.writeData(
      key: AppKeys.userIdKey,
      value: session.id,
    );
    await _secureCacheHelper.writeData(
      key: AppKeys.riderNameKey,
      value: session.name,
    );
    await _secureCacheHelper.writeData(
      key: AppKeys.riderPhoneKey,
      value: session.phone,
    );
  }
}
