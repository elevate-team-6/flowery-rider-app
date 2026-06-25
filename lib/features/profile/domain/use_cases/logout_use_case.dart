import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../repo/profile_repo_contract.dart';

@injectable
class LogoutUseCase {
  final ProfileRepoContract _repo;

  LogoutUseCase(this._repo);

  Future<BaseResponse<void>> call() async {
    return _repo.logout();
  }
}
