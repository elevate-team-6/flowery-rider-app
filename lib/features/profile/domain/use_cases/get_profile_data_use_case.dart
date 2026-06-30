import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';
import 'package:flowery_rider_app/features/profile/domain/repo/profile_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetProfileDataUseCase {
  final ProfileRepoContract _repo;

  GetProfileDataUseCase(this._repo);

  Future<BaseResponse<DriverEntity>> call() async {
    return _repo.getProfileData();
  }
}
