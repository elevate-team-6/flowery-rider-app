import 'dart:io';

import 'package:injectable/injectable.dart';
import '../../../../config/base_response/base_response.dart';
import '../../../../config/cache/secure_cache_helper.dart';
import '../../../../core/utils/app_keys.dart';
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
}
