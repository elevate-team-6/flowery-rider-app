import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/logout_response_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/sign_in_response_model.dart';

abstract interface class AuthRemoteDataSourceContract {
  Future<BaseResponse<SignInResponseModel>> signIn(SignInRequestModel request);

  Future<BaseResponse<LogoutResponseModel>> logout();
}
