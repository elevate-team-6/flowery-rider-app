import 'package:injectable/injectable.dart';

import '../../../../config/cache/secure_cache_helper.dart';
import '../../domain/repo/tracking_repo_contract.dart';
import '../data_sources/tracking_remote_data_source_contract.dart';

@Injectable(as: TrackingRepoContract)
class TrackingRepoImpl implements TrackingRepoContract {
  // ignore: unused_field
  final TrackingRemoteDataSourceContract _remoteDataSource;
  // ignore: unused_field
  final SecureCacheHelper _secureCacheHelper;

  TrackingRepoImpl(this._remoteDataSource, this._secureCacheHelper);
}
