import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/logout_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/repo/auth_repo_contract.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogoutUseCase {
  final AuthRepoContract _repo;

  LogoutUseCase(this._repo);

  Future<BaseResponse<LogoutEntity>> call() {
    return _repo.logout();
  }
}
