import 'package:dio/dio.dart';
import 'package:flowery_rider_app/core/utils/app_end_points.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

import '../../data/models/request/forgot_password_request.dart';
import '../../data/models/request/reset_password_request.dart';
import '../../data/models/request/verify_reset_code_request.dart';
import '../../data/models/response/forgot_password_response.dart';
import '../../data/models/response/reset_password_response.dart';
import '../../data/models/response/verify_reset_code_response.dart';

part 'auth_api_client.g.dart';

@injectable
@RestApi(baseUrl: AppEndPoints.baseUrl)
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(Dio dio) = _AuthApiClient;

  // Forget Password Api functions
  @POST(AppEndPoints.forgetPassword)
  Future<ForgetPasswordResponse> forgotPassword(
    @Body() ForgetPasswordRequest request,
  );

  @POST(AppEndPoints.verifyResetCode)
  Future<VerifyResetCodeResponse> verifyResetCode(
    @Body() VerifyResetCodeRequest request,
  );

  @PUT(AppEndPoints.resetPassword)
  Future<ResetPasswordResponse> resetPassword(
    @Body() ResetPasswordRequest request,
  );
}
