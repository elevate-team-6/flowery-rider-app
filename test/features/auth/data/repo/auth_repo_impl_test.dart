import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/forgot_password_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/reset_password_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/verify_reset_code_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/forgot_password_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/reset_password_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/verify_reset_code_response.dart';
import 'package:flowery_rider_app/features/auth/data/repo/auth_repo_impl.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/forget_password_entity.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/sign_in_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSourceContract])
void main() {
  provideDummy<BaseResponse<ForgetPasswordResponse>>(SuccessBaseResponse(null));
  provideDummy<BaseResponse<VerifyResetCodeResponse>>(
    SuccessBaseResponse(null),
  );
  provideDummy<BaseResponse<ResetPasswordResponse>>(SuccessBaseResponse(null));
  provideDummy<BaseResponse<SignInResponseModel>>(ErrorBaseResponse('dummy'));

  late AuthRepoImpl repo;
  late MockAuthRemoteDataSourceContract mockRemoteDataSource;
  late MockAuthRemoteDataSourceContract mockMockDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSourceContract();
    mockMockDataSource = MockAuthRemoteDataSourceContract();
    repo = AuthRepoImpl(mockRemoteDataSource, mockMockDataSource);
  });

  group('AuthRepoImpl - Sign In', () {
    const request = SignInRequestModel(
      email: 'test@test.com',
      password: 'Ahmed@123',
    );

    const fakeResponse = SignInResponseModel(
      message: 'success',
      token: 'fake_token',
    );

    test('returns SuccessBaseResponse when data source succeeds', () async {
      when(
        mockRemoteDataSource.signIn(request),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeResponse));

      final result = await repo.signIn(request);

      expect(result, isA<SuccessBaseResponse<SignInEntity>>());
      final success = result as SuccessBaseResponse<SignInEntity>;
      expect(success.data?.token, 'fake_token');
      expect(success.data?.message, 'success');
    });

    test('returns ErrorBaseResponse when data source returns error', () async {
      when(
        mockRemoteDataSource.signIn(request),
      ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

      final result = await repo.signIn(request);

      expect(result, isA<ErrorBaseResponse<SignInEntity>>());
      final error = result as ErrorBaseResponse<SignInEntity>;
      expect(error.errorMessage, 'invalid credentials');
    });
  });

  group('AuthRepoImpl - Forget Password', () {
    const tEmail = 'test@example.com';
    const tResponse = ForgetPasswordResponse(
      statusMsg: 'success',
      message: 'OTP sent',
    );
    final tEntity = tResponse.toEntity();

    test(
      'should call forgotPassword on mockDataSource and return SuccessBaseResponse',
      () async {
        // arrange
        when(
          mockMockDataSource.forgotPassword(any),
        ).thenAnswer((_) async => SuccessBaseResponse(tResponse));

        // act
        final result = await repo.forgotPassword(email: tEmail);

        // assert
        verify(
          mockMockDataSource.forgotPassword(
            argThat(isA<ForgetPasswordRequest>()),
          ),
        );
        expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());
        expect(
          (result as SuccessBaseResponse<ForgetPasswordEntity>).data,
          tEntity,
        );
      },
    );

    test('should return ErrorBaseResponse when mockDataSource fails', () async {
      // arrange
      when(
        mockMockDataSource.forgotPassword(any),
      ).thenAnswer((_) async => ErrorBaseResponse('Error'));

      // act
      final result = await repo.forgotPassword(email: tEmail);

      // assert
      expect(result, isA<ErrorBaseResponse<ForgetPasswordEntity>>());
      expect((result as ErrorBaseResponse).errorMessage, 'Error');
    });
  });

  group('AuthRepoImpl - Verify Reset Code', () {
    const tCode = '123456';
    const tResponse = VerifyResetCodeResponse(message: 'Verified');
    final tEntity = tResponse.toEntity();

    test(
      'should call verifyResetCode on mockDataSource and return Success',
      () async {
        // arrange
        when(
          mockMockDataSource.verifyResetCode(any),
        ).thenAnswer((_) async => SuccessBaseResponse(tResponse));

        // act
        final result = await repo.verifyResetCode(resetCode: tCode);

        // assert
        verify(
          mockMockDataSource.verifyResetCode(
            argThat(isA<VerifyResetCodeRequest>()),
          ),
        );
        expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());
        expect(
          (result as SuccessBaseResponse<ForgetPasswordEntity>).data,
          tEntity,
        );
      },
    );
  });

  group('AuthRepoImpl - Reset Password', () {
    const tEmail = 'test@example.com';
    const tPass = 'newPass123';
    const tResponse = ResetPasswordResponse(message: 'Success');
    final tEntity = tResponse.toEntity();

    test(
      'should call resetPassword on mockDataSource and return Success',
      () async {
        // arrange
        when(
          mockMockDataSource.resetPassword(any),
        ).thenAnswer((_) async => SuccessBaseResponse(tResponse));

        // act
        final result = await repo.resetPassword(
          email: tEmail,
          newPassword: tPass,
        );

        // assert
        verify(
          mockMockDataSource.resetPassword(
            argThat(isA<ResetPasswordRequest>()),
          ),
        );
        expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());
        expect(
          (result as SuccessBaseResponse<ForgetPasswordEntity>).data,
          tEntity,
        );
      },
    );
  });
}
