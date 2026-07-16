import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/hive_helper.dart';
import 'package:flowery_rider_app/features/tracking/data/data_sources/tracking_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/all_driver_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/driver_order_data_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/inner_order_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/inner_shipping_address_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/metadata_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/order_store_model.dart';
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

@GenerateMocks([
  TrackingRemoteDataSourceContract,
  HiveHelper,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
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
  late MockHiveHelper mockHiveHelper;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocument;
  late MockDocumentSnapshot<Map<String, dynamic>> mockSnapshot;

  setUp(() {
    mockRemoteDataSource = MockTrackingRemoteDataSourceContract();
    mockHiveHelper = MockHiveHelper();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();

    repo = TrackingRepoImpl(
      mockRemoteDataSource,
      mockHiveHelper,
      mockFirestore,
    );

    // Default firestore mock setup
    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocument);
    when(mockDocument.get()).thenAnswer((_) async => mockSnapshot);
    when(mockSnapshot.exists).thenReturn(false);
  });

  group('getDriverOrders', () {
    const fakeResponse = AllDriverOrdersResponseModel(
      message: 'success',
      metadata: MetadataModel(currentPage: 1, totalPages: 5),
      orders: [
        DriverOrderDataModel(
          id: '1',
          order: InnerOrderModel(
            id: 'o1',
            orderNumber: '#123',
            totalPrice: 100,
            state: 'completed',
            user: UserModel(id: 'u1', firstName: 'John'),
            shippingAddress: InnerShippingAddressModel(
              street: 'S1',
              city: 'C1',
            ),
          ),
          store: OrderStoreModel(name: 'Store1', latLong: '1,2'),
        ),
      ],
    );

    test(
      'maps response to DriverOrdersEntity on success with pagination',
      () async {
        when(
          mockRemoteDataSource.getDriverOrders(page: 1),
        ).thenAnswer((_) async => SuccessBaseResponse(fakeResponse));

        final result = await repo.getDriverOrders(page: 1);

        verify(mockRemoteDataSource.getDriverOrders(page: 1)).called(1);
        expect(result, isA<SuccessBaseResponse<DriverOrdersEntity>>());
        final success = result as SuccessBaseResponse<DriverOrdersEntity>;
        expect(success.data!.orders, hasLength(1));
        expect(success.data!.currentPage, 1);
        expect(success.data!.totalPages, 5);
        expect(success.data!.orders.first.orderNumber, '#123');
      },
    );

    test('returns ErrorBaseResponse when data source fails', () async {
      when(
        mockRemoteDataSource.getDriverOrders(page: 1),
      ).thenAnswer((_) async => ErrorBaseResponse('server error'));

      final result = await repo.getDriverOrders(page: 1);

      expect(result, isA<ErrorBaseResponse<DriverOrdersEntity>>());
      expect((result as ErrorBaseResponse).errorMessage, 'server error');
    });

    test(
      'returns ErrorBaseResponse when mapping fails (Rule 6: try-catch)',
      () async {
        // Missing mandatory 'order' in model will cause DriverOrderDataModel.toEntity() to throw
        const invalidResponse = AllDriverOrdersResponseModel(
          orders: [DriverOrderDataModel(id: '1', order: null)],
        );

        when(
          mockRemoteDataSource.getDriverOrders(page: 1),
        ).thenAnswer((_) async => SuccessBaseResponse(invalidResponse));

        final result = await repo.getDriverOrders(page: 1);

        expect(result, isA<ErrorBaseResponse<DriverOrdersEntity>>());
        expect((result as ErrorBaseResponse).errorMessage, contains('Mapping'));
      },
    );
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

    test(
      'enriches order with Firestore address when API address is missing',
      () async {
        const missingAddressResponse = PendingOrdersResponseModel(
          orders: [
            TrackingOrderModel(
              id: 'enrich_id',
              shippingAddress: ShippingAddressModel(street: '_', city: '_'),
            ),
          ],
        );

        when(
          mockRemoteDataSource.getPendingOrders(page: 1),
        ).thenAnswer((_) async => SuccessBaseResponse(missingAddressResponse));

        when(mockSnapshot.exists).thenReturn(true);
        when(mockSnapshot.data()).thenReturn({
          'shippingAddress': {
            'street': 'Firestore Street',
            'city': 'Firestore City',
          },
        });

        final result = await repo.getPendingOrders(page: 1);

        final order = (result as SuccessBaseResponse<PendingOrdersEntity>)
            .data!
            .orders
            .first;
        expect(order.shippingAddress.street, 'Firestore Street');
        expect(order.shippingAddress.city, 'Firestore City');
      },
    );
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
        mockRemoteDataSource.updateOrderState('123', OrderStatus.completed),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeActionResponse));

      final result = await repo.updateOrderState('123', OrderStatus.completed);

      verify(
        mockRemoteDataSource.updateOrderState('123', OrderStatus.completed),
      ).called(1);
      expect(result, isA<SuccessBaseResponse<OrderEntity>>());
      expect(
        (result as SuccessBaseResponse<OrderEntity>).data!.state,
        'delivered',
      );
      expect((result).data!.totalPrice, 200);
    });
  });
}
