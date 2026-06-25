import 'package:easy_localization/easy_localization.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/data/data_sources/auth_local_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_response.dart';
import 'package:flowery_rider_app/features/auth/domain/repo/auth_repo_contract.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/reset_password_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/verify_reset_code_response.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/forget_password_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/sign_in_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/country_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/driver_entity.dart';
import 'package:flowery_rider_app/features/tracking/presentation/widgets/vehicle_type_entity.dart';
import 'package:injectable/injectable.dart';
import '../models/request/forgot_password_request.dart';
import '../models/request/reset_password_request.dart';
import '../models/request/verify_reset_code_request.dart';
import '../models/response/forgot_password_response.dart';

@Injectable(as: AuthRepoContract)
class AuthRepoImpl implements AuthRepoContract {
  final AuthRemoteDataSourceContract _remoteDataSource;
  final AuthLocalDataSourceContract localDataSource;
  final AuthRemoteDataSourceContract? _mockDataSource;

  const AuthRepoImpl(
    this._remoteDataSource,
    this.localDataSource, [
    @Named('mock') this._mockDataSource,
  ]);

  @override
  Future<BaseResponse<DriverEntity>> signup(SignUpRequest request) async {
    final response = await _remoteDataSource.signup(request);

    switch (response) {
      case SuccessBaseResponse<SignUpResponse>():
        if (response.data == null || response.data!.driver == null) {
          return ErrorBaseResponse(AppStrings.signupFailedUserIsNull.tr());
        }

        return SuccessBaseResponse(response.data!.driver!.toEntity());

      case ErrorBaseResponse<SignUpResponse>():
        return ErrorBaseResponse(response.errorMessage.tr());
    }
  }

  @override
  Future<List<CountryEntity>> getCountries() async =>
      (await localDataSource.getCountries()).map((e) => e.toEntity()).toList();

  @override
  Future<BaseResponse<List<VehicleTypeEntity>>> getVehicles() async {
    final response = await _remoteDataSource.vehicles();

    switch (response) {
      case SuccessBaseResponse<VehicleResponse>():
        return SuccessBaseResponse(
          response.data!.vehicles.map((e) => e.toEntity()).toList(),
        );

      case ErrorBaseResponse<VehicleResponse>():
        return ErrorBaseResponse(response.errorMessage.tr());
    }
  }

  @override
  Future<BaseResponse<SignInEntity>> signIn(SignInRequestModel request) async {
    final result = await _remoteDataSource.signIn(request);

    return switch (result) {
      SuccessBaseResponse<SignInResponseModel>() => SuccessBaseResponse(
        result.data?.toEntity(),
      ),
      ErrorBaseResponse<SignInResponseModel>() => ErrorBaseResponse(
        result.errorMessage,
      ),
    };
  }

  @override
  Future<BaseResponse<ForgetPasswordEntity>> forgotPassword({
    required String email,
  }) async {
    final dataSource = _mockDataSource ?? _remoteDataSource;

    final response = await dataSource.forgotPassword(
      ForgetPasswordRequest(email: email),
    );

    switch (response) {
      case SuccessBaseResponse<ForgetPasswordResponse>():
        return SuccessBaseResponse<ForgetPasswordEntity>(
          response.data?.toEntity(),
        );

      case ErrorBaseResponse<ForgetPasswordResponse>():
        return ErrorBaseResponse<ForgetPasswordEntity>(response.errorMessage);
    }
  }

  @override
  Future<BaseResponse<ForgetPasswordEntity>> verifyResetCode({
    required String resetCode,
  }) async {
    final dataSource = _mockDataSource ?? _remoteDataSource;

    final response = await dataSource.verifyResetCode(
      VerifyResetCodeRequest(resetCode: resetCode),
    );

    switch (response) {
      case SuccessBaseResponse<VerifyResetCodeResponse>():
        return SuccessBaseResponse<ForgetPasswordEntity>(
          response.data?.toEntity(),
        );

      case ErrorBaseResponse<VerifyResetCodeResponse>():
        return ErrorBaseResponse<ForgetPasswordEntity>(response.errorMessage);
    }
  }

  @override
  Future<BaseResponse<ForgetPasswordEntity>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final dataSource = _mockDataSource ?? _remoteDataSource;

    final response = await dataSource.resetPassword(
      ResetPasswordRequest(email: email, newPassword: newPassword),
    );

    switch (response) {
      case SuccessBaseResponse<ResetPasswordResponse>():
        return SuccessBaseResponse<ForgetPasswordEntity>(
          response.data?.toEntity(),
        );

      case ErrorBaseResponse<ResetPasswordResponse>():
        return ErrorBaseResponse<ForgetPasswordEntity>(response.errorMessage);
    }
  }
}
