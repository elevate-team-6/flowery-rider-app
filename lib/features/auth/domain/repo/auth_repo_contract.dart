import '../../../../config/base_response/base_response.dart';
import '../entities/forget_password_entity.dart';

abstract interface class AuthRepoContract {
  // Forget Password contract functions
  Future<BaseResponse<ForgetPasswordEntity>> forgotPassword({
    required String email,
  });

  Future<BaseResponse<ForgetPasswordEntity>> verifyResetCode({
    required String resetCode,
  });

  Future<BaseResponse<ForgetPasswordEntity>> resetPassword({
    required String email,
    required String newPassword,
  });
}
