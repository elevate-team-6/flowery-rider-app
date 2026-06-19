import 'package:dio/dio.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/api/api_client/auth_api_client.dart';
import 'package:flowery_rider_app/features/auth/api/data_sources/auth_remote_data_source_impl.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([AuthApiClient])
void main() {
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

  setUp(() {
    mockApiClient = MockAuthApiClient();
    dataSource = AuthRemoteDataSourceImpl(mockApiClient);
  });

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
      },
    );

    test(
      'returns ErrorBaseResponse when api call throws generic exception',
      () async {
        when(
          mockApiClient.signIn(request),
        ).thenThrow(Exception('unexpected error'));

        final result = await dataSource.signIn(request);

        expect(result, isA<ErrorBaseResponse<SignInResponseModel>>());
        final error = result as ErrorBaseResponse<SignInResponseModel>;
        expect(error.errorMessage, isNotEmpty);
      },
    );
  });
}
