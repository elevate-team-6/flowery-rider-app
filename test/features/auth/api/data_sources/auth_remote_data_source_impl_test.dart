import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/services/multi_part_service.dart';

import 'package:flowery_rider_app/features/auth/api/api_client/auth_api_client.dart';
import 'package:flowery_rider_app/features/auth/api/data_sources/auth_remote_data_source_impl.dart';

import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/forgot_password_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/verify_reset_code_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/reset_password_request.dart';

import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_type_model.dart';

import 'package:flowery_rider_app/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/forgot_password_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/verify_reset_code_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/reset_password_response.dart';

import 'auth_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([AuthApiClient, MultipartService])
void main() {
  late MockAuthApiClient mockApiClient;
  late MockMultipartService mockMultipartService;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockAuthApiClient();
    mockMultipartService = MockMultipartService();

    dataSource = AuthRemoteDataSourceImpl(mockApiClient, mockMultipartService);
  });

  group('signup', () {
    test('should return SuccessBaseResponse when api call succeeds', () async {
      const request = SignUpRequest(
        country: '',
        firstName: '',
        lastName: '',
        vehicleType: '',
        vehicleNumber: '',
        nid: '',
        email: '',
        password: '',
        rePassword: '',
        gender: '',
        phone: '',
        vehicleLicense: null,
        nidImg: null,
      );

      when(
        mockMultipartService.createSignUpFormData(request),
      ).thenAnswer((_) async => FormData());

      when(mockApiClient.signup(any)).thenAnswer((_) async => SignUpResponse());

      final result = await dataSource.signup(request);

      expect(result, isA<SuccessBaseResponse<SignUpResponse>>());

      verify(mockMultipartService.createSignUpFormData(request)).called(1);

      verify(mockApiClient.signup(any)).called(1);
    });
  });

  group('vehicles', () {
    test('should return SuccessBaseResponse when api call succeeds', () async {
      final response = VehicleResponse(
        vehicles: const [VehicleModel(id: '1', type: 'Car', image: 'image')],
      );

      when(mockApiClient.vehicles()).thenAnswer((_) async => response);

      final result = await dataSource.vehicles();

      expect(result, isA<SuccessBaseResponse<VehicleResponse>>());

      final success = result as SuccessBaseResponse<VehicleResponse>;

      expect(success.data?.vehicles.length, 1);

      verify(mockApiClient.vehicles()).called(1);
    });
  });

  group('AuthRemoteDataSourceImpl - Sign In', () {
    const request = SignInRequestModel(
      email: 'test@test.com',
      password: 'Ahmed@123',
    );

    const fakeResponse = SignInResponseModel(
      message: 'success',
      token: 'fake_token',
    );

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
      },
    );
  });

  group('AuthRemoteDataSourceImpl - Forget Password', () {
    const request = ForgetPasswordRequest(email: 'test@example.com');

    const response = ForgetPasswordResponse(
      statusMsg: 'success',
      message: 'OTP sent',
    );

    test('should return SuccessBaseResponse', () async {
      when(mockApiClient.forgotPassword(any)).thenAnswer((_) async => response);

      final result = await dataSource.forgotPassword(request);

      verify(mockApiClient.forgotPassword(request));

      expect(result, isA<SuccessBaseResponse<ForgetPasswordResponse>>());
    });

    test('should return ErrorBaseResponse', () async {
      when(mockApiClient.forgotPassword(any)).thenThrow(Exception());

      final result = await dataSource.forgotPassword(request);

      expect(result, isA<ErrorBaseResponse<ForgetPasswordResponse>>());
    });
  });

  group('AuthRemoteDataSourceImpl - Verify Reset Code', () {
    const request = VerifyResetCodeRequest(resetCode: '123456');

    const response = VerifyResetCodeResponse(
      status: 'Success',
      message: 'Code verified',
    );

    test('should return SuccessBaseResponse', () async {
      when(
        mockApiClient.verifyResetCode(any),
      ).thenAnswer((_) async => response);

      final result = await dataSource.verifyResetCode(request);

      verify(mockApiClient.verifyResetCode(request));

      expect(result, isA<SuccessBaseResponse<VerifyResetCodeResponse>>());
    });
  });

  group('AuthRemoteDataSourceImpl - Reset Password', () {
    const request = ResetPasswordRequest(
      email: 'test@example.com',
      newPassword: 'password123',
    );

    const response = ResetPasswordResponse(
      message: 'Password reset successfully',
      token: 'token123',
    );

    test('should return SuccessBaseResponse', () async {
      when(mockApiClient.resetPassword(any)).thenAnswer((_) async => response);

      final result = await dataSource.resetPassword(request);

      verify(mockApiClient.resetPassword(request));

      expect(result, isA<SuccessBaseResponse<ResetPasswordResponse>>());
    });
  });
}
