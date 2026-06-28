import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/tracking/data/data_sources/tracking_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/all_driver_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/pending_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/shipping_address_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/store_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/tracking_order_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/update_order_state_data_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/update_order_state_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/user_model.dart';
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
  provideDummy<BaseResponse<UpdateOrderStateResponseModel>>(
    ErrorBaseResponse('dummy'),
  );
  provideDummy<BaseResponse<AllDriverOrdersResponseModel>>(
    ErrorBaseResponse('dummy'),
  );

  late TrackingRepoImpl repo;
  late MockTrackingRemoteDataSourceContract mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockTrackingRemoteDataSourceContract();
    repo = TrackingRepoImpl(mockRemoteDataSource);
  });

  group('getPendingOrders', () {
    const fakeResponse = PendingOrdersResponseModel(
      message: 'success',
      orders: [
        TrackingOrderModel(
          id: '1',
          orderNumber: 'ORD-1',
          totalPrice: 100,
          state: 'pending',
          createdAt: 'date',
          user: UserModel(id: 'u1', firstName: 'John', lastName: 'Doe'),
          store: StoreModel(name: 'Store', phoneNumber: '123'),
          shippingAddress: ShippingAddressModel(street: 'Street', city: 'City'),
        ),
      ],
    );

    test(
      'maps response model to entity on success (including nested models)',
      () async {
        when(
          mockRemoteDataSource.getPendingOrders(page: 1),
        ).thenAnswer((_) async => SuccessBaseResponse(fakeResponse));

        final result = await repo.getPendingOrders(page: 1);

        verify(mockRemoteDataSource.getPendingOrders(page: 1)).called(1);
        expect(result, isA<SuccessBaseResponse<PendingOrdersEntity>>());
        final success = result as SuccessBaseResponse<PendingOrdersEntity>;
        expect(success.data!.message, 'success');
        expect(success.data!.orders, hasLength(1));
        final order = success.data!.orders.first;
        expect(order.id, '1');
        expect(order.user.fullName, 'John Doe');
        expect(order.store.name, 'Store');
        expect(order.store.phoneNumber, '123');
      },
    );

    test('propagates error message on failure', () async {
      when(
        mockRemoteDataSource.getPendingOrders(page: anyNamed('page')),
      ).thenAnswer((_) async => ErrorBaseResponse('network error'));

      final result = await repo.getPendingOrders(page: 1);

      expect(result, isA<ErrorBaseResponse<PendingOrdersEntity>>());
      expect((result as ErrorBaseResponse).errorMessage, 'network error');
    });
  });

  group('startOrder', () {
    const fakeActionResponse = UpdateOrderStateResponseModel(
      message: 'success',
      order: UpdateOrderStateDataModel(
        id: '123',
        orderNumber: 'ORD-123',
        totalPrice: 150,
        state: 'inProgress',
        user: 'user_id',
      ),
    );

    test('maps response to entity on success', () async {
      when(
        mockRemoteDataSource.startOrder('123'),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeActionResponse));

      final result = await repo.startOrder('123');

      verify(mockRemoteDataSource.startOrder('123')).called(1);
      expect(result, isA<SuccessBaseResponse<OrderEntity>>());
      final success = result as SuccessBaseResponse<OrderEntity>;
      expect(success.data!.id, '123');
      expect(success.data!.state, 'inProgress');
      expect(success.data!.user.id, 'user_id');
    });

    test('propagates error on failure', () async {
      when(
        mockRemoteDataSource.startOrder(any),
      ).thenAnswer((_) async => ErrorBaseResponse('fail'));

      final result = await repo.startOrder('123');

      expect(result, isA<ErrorBaseResponse<OrderEntity>>());
      expect((result as ErrorBaseResponse).errorMessage, 'fail');
    });
  });

  group('updateOrderState', () {
    const fakeActionResponse = UpdateOrderStateResponseModel(
      message: 'success',
      order: UpdateOrderStateDataModel(
        id: '123',
        state: 'delivered',
        totalPrice: 200,
      ),
    );

    test('maps response to entity on success', () async {
      when(
        mockRemoteDataSource.updateOrderState('123', OrderStatus.delivered),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeActionResponse));

      final result = await repo.updateOrderState('123', OrderStatus.delivered);

      verify(
        mockRemoteDataSource.updateOrderState('123', OrderStatus.delivered),
      ).called(1);
      expect(result, isA<SuccessBaseResponse<OrderEntity>>());
      expect(
        (result as SuccessBaseResponse<OrderEntity>).data!.state,
        'delivered',
      );
      expect((result).data!.totalPrice, 200);
    });

    test('propagates error on failure', () async {
      when(
        mockRemoteDataSource.updateOrderState(any, any),
      ).thenAnswer((_) async => ErrorBaseResponse('fail'));

      final result = await repo.updateOrderState('123', OrderStatus.delivered);

      expect(result, isA<ErrorBaseResponse<OrderEntity>>());
      expect((result as ErrorBaseResponse).errorMessage, 'fail');
    });
  });
}
