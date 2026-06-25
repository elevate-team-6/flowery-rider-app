import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/sign_in_response_model.dart';
import '../models/request/forgot_password_request.dart';
import '../models/request/reset_password_request.dart';
import '../models/request/verify_reset_code_request.dart';
import '../models/response/forgot_password_response.dart';
import '../models/response/reset_password_response.dart';
import '../models/response/verify_reset_code_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_response.dart';

abstract interface class AuthRemoteDataSourceContract {
  Future<BaseResponse<SignInResponseModel>> signIn(SignInRequestModel request);
  Future<BaseResponse<SignUpResponse>> signup(SignUpRequest request);
  Future<BaseResponse<VehicleResponse>> vehicles();
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
