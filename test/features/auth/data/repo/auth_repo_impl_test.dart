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

  late AuthRepoImpl repo;
  late MockAuthRemoteDataSourceContract mockRemoteDataSource;
  late MockAuthRemoteDataSourceContract mockMockDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSourceContract();
    mockMockDataSource = MockAuthRemoteDataSourceContract();
    repo = AuthRepoImpl(mockRemoteDataSource, mockMockDataSource);
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
