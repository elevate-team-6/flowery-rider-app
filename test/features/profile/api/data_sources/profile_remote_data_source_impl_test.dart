import 'package:flowery_rider_app/features/profile/api/api_client/profile_api_client.dart';
import 'package:flowery_rider_app/features/profile/api/data_sources/profile_remote_data_source_impl.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flowery_rider_app/config/base_response/base_response.dart';

import 'profile_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([ProfileApiClient])
void main() {
  late MockProfileApiClient mockApiClient;
  late ProfileRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockProfileApiClient();
    dataSource = ProfileRemoteDataSourceImpl(mockApiClient);
  });

  group('logout', () {
    test('should return SuccessBaseResponse when api call succeeds', () async {
      when(
        mockApiClient.logout(),
      ).thenAnswer((_) async => SuccessBaseResponse<void>(null));

      final result = await dataSource.logout();

      expect(result, isA<SuccessBaseResponse<void>>());

      verify(mockApiClient.logout()).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });

    test('should return ErrorBaseResponse when api call fails', () async {
      when(mockApiClient.logout()).thenThrow(Exception('network error'));

      final result = await dataSource.logout();

      expect(result, isA<ErrorBaseResponse<void>>());

      verify(mockApiClient.logout()).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });
  });

  group('profile', () {
    test(
      'should return SuccessBaseResponse<ProfileResponse> when api succeeds',
      () async {
        final response = ProfileResponse();

        when(mockApiClient.profile()).thenAnswer((_) async => response);

        final result = await dataSource.profile();

        expect(result, isA<SuccessBaseResponse<ProfileResponse>>());

        verify(mockApiClient.profile()).called(1);
        verifyNoMoreInteractions(mockApiClient);
      },
    );

    test('should return ErrorBaseResponse when api throws exception', () async {
      when(mockApiClient.profile()).thenThrow(Exception('server error'));

      final result = await dataSource.profile();

      expect(result, isA<ErrorBaseResponse<ProfileResponse>>());

      verify(mockApiClient.profile()).called(1);
      verifyNoMoreInteractions(mockApiClient);
    });
  });
}
