import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/tracking/data/data_sources/tracking_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/order_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/pending_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/repo/tracking_repo_impl.dart';
import 'package:flowery_rider_app/features/tracking/domain/entities/order_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'tracking_repo_impl_test.mocks.dart';

@GenerateMocks([TrackingRemoteDataSourceContract])
void main() {
  provideDummy<BaseResponse<PendingOrdersResponseModel>>(
    ErrorBaseResponse('dummy'),
  );

  late TrackingRepoImpl repo;
  late MockTrackingRemoteDataSourceContract mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockTrackingRemoteDataSourceContract();
    repo = TrackingRepoImpl(mockRemoteDataSource);
  });

  const fakeResponse = PendingOrdersResponseModel(
    message: 'success',
    orders: [OrderModel(id: '1', orderNumber: 'ORD-1')],
  );

  test('maps response model to entity on success', () async {
    when(
      mockRemoteDataSource.getPendingOrders(page: 1),
    ).thenAnswer((_) async => SuccessBaseResponse(fakeResponse));

    final result = await repo.getPendingOrders(page: 1);

    verify(mockRemoteDataSource.getPendingOrders(page: 1)).called(1);
    expect(result, isA<SuccessBaseResponse<PendingOrdersEntity>>());
    final success = result as SuccessBaseResponse<PendingOrdersEntity>;
    expect(success.data?.message, 'success');
    expect(success.data?.orders, hasLength(1));
    expect(success.data?.orders?.first.id, '1');
    expect(success.data?.orders?.first.orderNumber, 'ORD-1');
  });

  test('returns null entity data when success data is null', () async {
    when(
      mockRemoteDataSource.getPendingOrders(page: anyNamed('page')),
    ).thenAnswer((_) async => SuccessBaseResponse(null));

    final result = await repo.getPendingOrders();

    expect(result, isA<SuccessBaseResponse<PendingOrdersEntity>>());
    expect((result as SuccessBaseResponse<PendingOrdersEntity>).data, isNull);
  });

  test('propagates error message on failure', () async {
    when(
      mockRemoteDataSource.getPendingOrders(page: anyNamed('page')),
    ).thenAnswer((_) async => ErrorBaseResponse('network error'));

    final result = await repo.getPendingOrders(page: 1);

    expect(result, isA<ErrorBaseResponse<PendingOrdersEntity>>());
    expect((result as ErrorBaseResponse).errorMessage, 'network error');
  });
}
