import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/profile/domain/repo/profile_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChangePasswordUseCase {
  final ProfileRepoContract _repo;
  const ChangePasswordUseCase(this._repo);

  Future<BaseResponse<String>> call(String password, String newPassword) =>
      _repo.changePassword(password, newPassword);
}
