<<<<<<< HEAD
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/api/api_client/auth_api_client.dart';
import 'package:flowery_rider_app/features/auth/api/data_sources/auth_remote_data_source_impl.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/forgot_password_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/reset_password_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/verify_reset_code_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/forgot_password_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/reset_password_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/verify_reset_code_response.dart';
=======
import 'package:dio/dio.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/api/api_client/auth_api_client.dart';
import 'package:flowery_rider_app/features/auth/api/data_sources/auth_remote_data_source_impl.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/sign_in_response_model.dart';
>>>>>>> origin/develop
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([AuthApiClient])
void main() {
<<<<<<< HEAD
  late AuthRemoteDataSourceImpl dataSource;
  late MockAuthApiClient mockApiClient;
=======
  late MockAuthApiClient mockApiClient;
  late AuthRemoteDataSourceImpl dataSource;

  const request = SignInRequestModel(
    email: 'test@test.com',
    password: 'Ahmed@123',
  );

  const fakeResponse = SignInResponseModel(
    message: 'success',
    token: 'fake_token',
  );
>>>>>>> origin/develop

  setUp(() {
    mockApiClient = MockAuthApiClient();
    dataSource = AuthRemoteDataSourceImpl(mockApiClient);
  });

<<<<<<< HEAD
  group('AuthRemoteDataSourceImpl - Forget Password', () {
    const tRequest = ForgetPasswordRequest(email: 'test@example.com');
    const tResponse = ForgetPasswordResponse(
      statusMsg: 'success',
      message: 'OTP sent',
    );

    test('should return SuccessBaseResponse when apiClient succeeds', () async {
      // arrange
      when(
        mockApiClient.forgotPassword(any),
      ).thenAnswer((_) async => tResponse);

      // act
      final result = await dataSource.forgotPassword(tRequest);

      // assert
      verify(mockApiClient.forgotPassword(tRequest));
      expect(result, isA<SuccessBaseResponse<ForgetPasswordResponse>>());
      expect(
        (result as SuccessBaseResponse<ForgetPasswordResponse>).data,
        tResponse,
      );
    });

    test(
      'should return ErrorBaseResponse when apiClient throws Exception',
      () async {
        // arrange
        when(
          mockApiClient.forgotPassword(any),
        ).thenThrow(Exception('Server Error'));

        // act
        final result = await dataSource.forgotPassword(tRequest);

        // assert
        expect(result, isA<ErrorBaseResponse<ForgetPasswordResponse>>());
      },
    );
  });

  group('AuthRemoteDataSourceImpl - Verify Reset Code', () {
    const tRequest = VerifyResetCodeRequest(resetCode: '123456');
    const tResponse = VerifyResetCodeResponse(
      status: 'Success',
      message: 'Code verified',
    );

    test(
      'should return SuccessBaseResponse when apiClient verifies reset code',
      () async {
        // arrange
        when(
          mockApiClient.verifyResetCode(any),
        ).thenAnswer((_) async => tResponse);

        // act
        final result = await dataSource.verifyResetCode(tRequest);

        // assert
        verify(mockApiClient.verifyResetCode(tRequest));
        expect(result, isA<SuccessBaseResponse<VerifyResetCodeResponse>>());
        expect(
          (result as SuccessBaseResponse<VerifyResetCodeResponse>).data,
          tResponse,
        );
=======
  group('AuthRemoteDataSourceImpl', () {
    test('returns SuccessBaseResponse when api call succeeds', () async {
      when(mockApiClient.signIn(request)).thenAnswer((_) async => fakeResponse);

      final result = await dataSource.signIn(request);

      expect(result, isA<SuccessBaseResponse<SignInResponseModel>>());
      final success = result as SuccessBaseResponse<SignInResponseModel>;
      expect(success.data?.token, 'fake_token');
      expect(success.data?.message, 'success');
    });

    test(
      'returns ErrorBaseResponse when api call throws DioException',
      () async {
        when(mockApiClient.signIn(request)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ),
        );

        final result = await dataSource.signIn(request);

        expect(result, isA<ErrorBaseResponse<SignInResponseModel>>());
        final error = result as ErrorBaseResponse<SignInResponseModel>;
        expect(error.errorMessage, isNotEmpty);
>>>>>>> origin/develop
      },
    );

    test(
<<<<<<< HEAD
      'should return ErrorBaseResponse when verifyResetCode throws Exception',
      () async {
        // arrange
        when(
          mockApiClient.verifyResetCode(any),
        ).thenThrow(Exception('Invalid Code'));

        // act
        final result = await dataSource.verifyResetCode(tRequest);

        // assert
        expect(result, isA<ErrorBaseResponse<VerifyResetCodeResponse>>());
      },
    );
  });

  group('AuthRemoteDataSourceImpl - Reset Password', () {
    const tRequest = ResetPasswordRequest(
      email: 'test@example.com',
      newPassword: 'password123',
    );
    const tResponse = ResetPasswordResponse(
      message: 'Password reset successfully',
      token: 'token123',
    );

    test(
      'should return SuccessBaseResponse when apiClient resets password',
      () async {
        // arrange
        when(
          mockApiClient.resetPassword(any),
        ).thenAnswer((_) async => tResponse);

        // act
        final result = await dataSource.resetPassword(tRequest);

        // assert
        verify(mockApiClient.resetPassword(tRequest));
        expect(result, isA<SuccessBaseResponse<ResetPasswordResponse>>());
        expect(
          (result as SuccessBaseResponse<ResetPasswordResponse>).data,
          tResponse,
        );
      },
    );

    test(
      'should return ErrorBaseResponse when resetPassword throws Exception',
      () async {
        // arrange
        when(
          mockApiClient.resetPassword(any),
        ).thenThrow(Exception('Weak Password'));

        // act
        final result = await dataSource.resetPassword(tRequest);

        // assert
        expect(result, isA<ErrorBaseResponse<ResetPasswordResponse>>());
=======
      'returns ErrorBaseResponse when api call throws generic exception',
      () async {
        when(
          mockApiClient.signIn(request),
        ).thenThrow(Exception('unexpected error'));

        final result = await dataSource.signIn(request);

        expect(result, isA<ErrorBaseResponse<SignInResponseModel>>());
        final error = result as ErrorBaseResponse<SignInResponseModel>;
        expect(error.errorMessage, isNotEmpty);
>>>>>>> origin/develop
      },
    );
  });
}
