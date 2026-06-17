import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:flowery_rider_app/features/auth/data/repo/auth_repo_impl.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/sign_in_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSourceContract])
void main() {
  late MockAuthRemoteDataSourceContract mockDataSource;
  late AuthRepoImpl repo;

  const request = SignInRequestModel(
    email: 'test@test.com',
    password: 'Ahmed@123',
  );

  const fakeResponse = SignInResponseModel(
    message: 'success',
    token: 'fake_token',
  );

  setUp(() {
    mockDataSource = MockAuthRemoteDataSourceContract();
    repo = AuthRepoImpl(mockDataSource);
    provideDummy<BaseResponse<SignInResponseModel>>(ErrorBaseResponse('dummy'));
  });

  group('AuthRepoImpl', () {
    test('returns SuccessBaseResponse when data source succeeds', () async {
      when(
        mockDataSource.signIn(request),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeResponse));

      final result = await repo.signIn(request);

      expect(result, isA<SuccessBaseResponse<SignInEntity>>());
      final success = result as SuccessBaseResponse<SignInEntity>;
      expect(success.data?.token, 'fake_token');
      expect(success.data?.message, 'success');
    });

    test('returns ErrorBaseResponse when data source returns error', () async {
      when(
        mockDataSource.signIn(request),
      ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

      final result = await repo.signIn(request);

      expect(result, isA<ErrorBaseResponse<SignInEntity>>());
      final error = result as ErrorBaseResponse<SignInEntity>;
      expect(error.errorMessage, 'invalid credentials');
    });

    test(
      'returns SuccessBaseResponse with null data when response is null',
      () async {
        when(
          mockDataSource.signIn(request),
        ).thenAnswer((_) async => SuccessBaseResponse(null));

        final result = await repo.signIn(request);

        expect(result, isA<SuccessBaseResponse<SignInEntity>>());
        final success = result as SuccessBaseResponse<SignInEntity>;
        expect(success.data, isNull);
      },
    );
  });
}
