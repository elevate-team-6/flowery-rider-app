import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../entities/forget_password_entity.dart';
import '../repo/auth_repo_contract.dart';

@injectable
class ForgetPasswordUseCase {
  final AuthRepoContract _repository;

  ForgetPasswordUseCase(this._repository);

  Future<BaseResponse<ForgetPasswordEntity>> call({required String email}) {
    return _repository.forgotPassword(email: email);
  }
}
