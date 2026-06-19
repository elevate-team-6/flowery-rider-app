import 'package:flowery_rider_app/features/auth/api/api_client/auth_api_client.dart';
import 'package:flowery_rider_app/features/auth/api/data_sources/auth_remote_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([AuthApiClient])
void main() {
  late MockAuthApiClient mockApiClient;
  late AuthRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockAuthApiClient();
    dataSource = AuthRemoteDataSourceImpl(mockApiClient);
  });

  test('should call signup api and return success response', () async {
    final request = SignUpRequest(
      email: 'test@test.com',
      password: '123456',
    );

    final response = SignUpResponse();

    when(
      mockApiClient.signup(any),
    ).thenAnswer((_) async => response);

    final result = await dataSource.signup(request);

    expect(result, isA<SuccessBaseResponse<SignUpResponse>>());

    verify(
      mockApiClient.signup(any),
    ).called(1);
  });
}