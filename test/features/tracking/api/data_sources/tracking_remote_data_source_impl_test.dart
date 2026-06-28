import 'package:dio/dio.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/tracking/api/api_client/tracking_api_client.dart';
import 'package:flowery_rider_app/features/tracking/api/data_sources/tracking_remote_data_source_impl.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/pending_orders_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'tracking_remote_data_source_impl_test.mocks.dart';

@GenerateMocks([TrackingApiClient])
void main() {
  late MockTrackingApiClient mockApiClient;
  late TrackingRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockTrackingApiClient();
    dataSource = TrackingRemoteDataSourceImpl(mockApiClient);
  });

  const fakeResponse = PendingOrdersResponseModel(message: 'success');

  test('returns SuccessBaseResponse when api call succeeds', () async {
    when(
      mockApiClient.getPendingOrders(page: 1),
    ).thenAnswer((_) async => fakeResponse);

    final result = await dataSource.getPendingOrders(page: 1);

    verify(mockApiClient.getPendingOrders(page: 1)).called(1);
    expect(result, isA<SuccessBaseResponse<PendingOrdersResponseModel>>());
    expect(
      (result as SuccessBaseResponse<PendingOrdersResponseModel>).data,
      fakeResponse,
    );
  });

  test('returns ErrorBaseResponse when api call throws DioException', () async {
    when(mockApiClient.getPendingOrders(page: anyNamed('page'))).thenThrow(
      DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      ),
    );

    final result = await dataSource.getPendingOrders(page: 1);

    expect(result, isA<ErrorBaseResponse<PendingOrdersResponseModel>>());
    expect(
      (result as ErrorBaseResponse<PendingOrdersResponseModel>).errorMessage,
      isNotEmpty,
    );
  });

  test(
    'returns ErrorBaseResponse when api call throws generic Exception',
    () async {
      when(
        mockApiClient.getPendingOrders(page: anyNamed('page')),
      ).thenThrow(Exception('boom'));

      final result = await dataSource.getPendingOrders(page: null);

      expect(result, isA<ErrorBaseResponse<PendingOrdersResponseModel>>());
    },
  );
}
