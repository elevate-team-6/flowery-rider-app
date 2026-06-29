import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';
import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';
import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../../../../config/cache/secure_cache_helper.dart';
import '../../../../core/utils/app_keys.dart';
import '../../domain/repo/profile_repo_contract.dart';
import '../data_sources/profile_remote_data_source_contract.dart';

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
