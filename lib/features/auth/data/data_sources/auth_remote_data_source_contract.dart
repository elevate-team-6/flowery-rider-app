import '../../../../config/base_response/base_response.dart';
import '../models/request/forgot_password_request.dart';
import '../models/request/reset_password_request.dart';
import '../models/request/verify_reset_code_request.dart';
import '../models/response/forgot_password_response.dart';
import '../models/response/reset_password_response.dart';
import '../models/response/verify_reset_code_response.dart';

abstract interface class AuthRemoteDataSourceContract {
  // Forget Password contract functions
  Future<BaseResponse<ForgetPasswordResponse>> forgotPassword(
    ForgetPasswordRequest request,
  );
  Future<BaseResponse<VerifyResetCodeResponse>> verifyResetCode(
    VerifyResetCodeRequest request,
  );
  Future<BaseResponse<ResetPasswordResponse>> resetPassword(
    ResetPasswordRequest request,
  );
}
