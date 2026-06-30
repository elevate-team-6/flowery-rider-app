import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_profile_request.dart';
import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';
import 'package:flowery_rider_app/features/profile/domain/repo/profile_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class EditProfileUseCase {
  final ProfileRepoContract _repo;

  EditProfileUseCase(this._repo);

  Future<BaseResponse<DriverEntity>> call(EditProfileRequest request) async {
    return _repo.editProfile(request);
  }
}
