import 'package:flowery_rider_app/features/profile/api/api_client/profile_api_client.dart';
import 'package:flowery_rider_app/features/profile/api/data_sources/profile_remote_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/change_password_request.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/change_password_response.dart';

import 'profile_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([ProfileApiClient])
void main() {
  late MockProfileApiClient mockApiClient;
  late ProfileRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockProfileApiClient();
    dataSource = ProfileRemoteDataSourceImpl(mockApiClient);
  });

  group('changePassword', () {
    test(
      'should return SuccessBaseResponse<String> when api call succeeds',
      () async {
        final response = ChangePasswordResponse(
          message: 'success',
          token: 'new_token',
        );

        when(
          mockApiClient.changePassword(any),
        ).thenAnswer((_) async => response);

        final result = await dataSource.changePassword('oldPass', 'newPass');

        expect(result, isA<SuccessBaseResponse<String>>());

        final success = result as SuccessBaseResponse<String>;

        expect(success.data, 'new_token');

        final captured = verify(
  mockApiClient.changePassword(captureAny),
).captured.single as ChangePasswordRequest;

expect(captured.password, 'oldPass');
expect(captured.newPassword, 'newPass');
      },
    );

    test('should return empty string when token is null', () async {
      final response = ChangePasswordResponse(message: 'success', token: null);

      when(mockApiClient.changePassword(any)).thenAnswer((_) async => response);

      final result = await dataSource.changePassword('oldPass', 'newPass');

      expect(result, isA<SuccessBaseResponse<String>>());

      final success = result as SuccessBaseResponse<String>;

      expect(success.data, '');
    });

    test('should return ErrorBaseResponse when api call fails', () async {
      when(
        mockApiClient.changePassword(any),
      ).thenThrow(Exception('Server Error'));

      final result = await dataSource.changePassword('oldPass', 'newPass');

      expect(result, isA<ErrorBaseResponse<String>>());
    });
  });
}
