import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/error_handler/error_handler.dart';
import 'package:flowery_rider_app/config/services/multi_part_service.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/forgot_password_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/reset_password_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/verify_reset_code_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/forgot_password_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/reset_password_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/verify_reset_code_response.dart';
import 'package:injectable/injectable.dart';

import '../../data/data_sources/auth_remote_data_source_contract.dart';
import '../../data/models/request/sign_in_request_model.dart';
import '../../data/models/response/sign_in_response_model.dart';
import '../api_client/auth_api_client.dart';

@Injectable(as: AuthRemoteDataSourceContract)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSourceContract {
  final AuthApiClient _apiClient;
  final MultipartService _multipartService;
  const AuthRemoteDataSourceImpl(this._apiClient, this._multipartService);

  @override
  Future<BaseResponse<SignUpResponse>> signup(SignUpRequest request) {
    return ErrorHandler.handleApiCall(() async {
      final formData = await _multipartService.createSignUpFormData(request);
      return _apiClient.signup(formData);
    });
  }

  @override
  Future<BaseResponse<VehicleResponse>> vehicles() {
    return ErrorHandler.handleApiCall(() => _apiClient.vehicles());
  }

  @override
  Future<BaseResponse<SignInResponseModel>> signIn(SignInRequestModel request) {
    return ErrorHandler.handleApiCall(() {
      return _apiClient.signIn(request);
    });
  }

  @override
  Future<BaseResponse<ForgetPasswordResponse>> forgotPassword(
    ForgetPasswordRequest request,
  ) {
    return ErrorHandler.handleApiCall(() => _apiClient.forgotPassword(request));
  }

  @override
  Future<BaseResponse<ResetPasswordResponse>> resetPassword(
    ResetPasswordRequest request,
  ) {
    return ErrorHandler.handleApiCall(() => _apiClient.resetPassword(request));
  }

  @override
  Future<BaseResponse<VerifyResetCodeResponse>> verifyResetCode(
    VerifyResetCodeRequest request,
  ) {
    return ErrorHandler.handleApiCall(
      () => _apiClient.verifyResetCode(request),
    );
  }
}
