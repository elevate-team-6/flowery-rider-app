import 'package:injectable/injectable.dart';

import '../../../../config/base_response/base_response.dart';
import '../entities/forget_password_entity.dart';
import '../repo/auth_repo_contract.dart';

@injectable
class ResetPasswordUseCase {
  final AuthRepoContract _repository;

  ResetPasswordUseCase(this._repository);

  Future<BaseResponse<ForgetPasswordEntity>> call({
    required String email,
    required String newPassword,
  }) {
    return _repository.resetPassword(email: email, newPassword: newPassword);
  }
}
