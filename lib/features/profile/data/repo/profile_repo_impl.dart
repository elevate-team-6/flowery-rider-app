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
    await _secureCacheHelper.deleteData(key: AppKeys.onboardingKey);
    return result;
  }
}
