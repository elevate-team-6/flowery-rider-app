import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/features/tracking/api/api_client/tracking_api_client.dart';
import 'package:flowery_rider_app/features/tracking/api/data_sources/tracking_remote_data_source_impl.dart';
import 'package:flowery_rider_app/features/tracking/data/models/request/update_order_state_request_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/all_driver_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/order_shipping_firestore_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/pending_orders_response_model.dart';
import 'package:flowery_rider_app/features/tracking/data/models/response/update_order_state_response_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'tracking_remote_data_source_impl_test.mocks.dart';

@GenerateMocks(
  [TrackingApiClient, FirebaseFirestore],
  customMocks: [
    MockSpec<CollectionReference<Map<String, dynamic>>>(
      as: #MockCollectionReference,
    ),
    MockSpec<DocumentReference<Map<String, dynamic>>>(
      as: #MockDocumentReference,
    ),
    MockSpec<DocumentSnapshot<Map<String, dynamic>>>(as: #MockDocumentSnapshot),
  ],
)
void main() {
  late MockTrackingApiClient mockApiClient;
  late MockFirebaseFirestore mockFirestore;
  late TrackingRemoteDataSourceImpl dataSource;

  setUp(() {
    mockApiClient = MockTrackingApiClient();
    mockFirestore = MockFirebaseFirestore();
    dataSource = TrackingRemoteDataSourceImpl(mockApiClient, mockFirestore);
  });

  group('getDriverOrders', () {
    const fakeResponse = AllDriverOrdersResponseModel(message: 'success');

    test(
      'returns SuccessBaseResponse when api call succeeds with page',
      () async {
        when(
          mockApiClient.getDriverOrders(page: 1),
        ).thenAnswer((_) async => fakeResponse);

        final result = await dataSource.getDriverOrders(page: 1);

        verify(mockApiClient.getDriverOrders(page: 1)).called(1);
        expect(
          result,
          isA<SuccessBaseResponse<AllDriverOrdersResponseModel>>(),
        );
        expect(
          (result as SuccessBaseResponse<AllDriverOrdersResponseModel>).data,
          fakeResponse,
        );
      },
    );

    test(
      'returns SuccessBaseResponse when api call succeeds without page',
      () async {
        when(
          mockApiClient.getDriverOrders(page: null),
        ).thenAnswer((_) async => fakeResponse);

        final result = await dataSource.getDriverOrders();

        verify(mockApiClient.getDriverOrders(page: null)).called(1);
        expect(
          result,
          isA<SuccessBaseResponse<AllDriverOrdersResponseModel>>(),
        );
      },
    );

    test(
      'returns ErrorBaseResponse when api call throws DioException',
      () async {
        when(mockApiClient.getDriverOrders(page: anyNamed('page'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ),
        );

        final result = await dataSource.getDriverOrders(page: 1);

        expect(result, isA<ErrorBaseResponse<AllDriverOrdersResponseModel>>());
        expect(
          (result as ErrorBaseResponse<AllDriverOrdersResponseModel>)
              .errorMessage,
          isNotEmpty,
        );
      },
    );

    test(
      'returns ErrorBaseResponse when api call throws generic Exception',
      () async {
        when(
          mockApiClient.getDriverOrders(page: anyNamed('page')),
        ).thenThrow(Exception('boom'));

        final result = await dataSource.getDriverOrders(page: 1);

        expect(result, isA<ErrorBaseResponse<AllDriverOrdersResponseModel>>());
        expect(
          (result as ErrorBaseResponse<AllDriverOrdersResponseModel>)
              .errorMessage,
          'unknownError',
        );
      },
    );
  });

  group('getPendingOrders', () {
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

    test(
      'returns ErrorBaseResponse when api call throws DioException',
      () async {
        when(mockApiClient.getPendingOrders(page: anyNamed('page'))).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.connectionError,
          ),
        );

        final result = await dataSource.getPendingOrders(page: 1);

        expect(result, isA<ErrorBaseResponse<PendingOrdersResponseModel>>());
        expect(
          (result as ErrorBaseResponse<PendingOrdersResponseModel>)
              .errorMessage,
          isNotEmpty,
        );
      },
    );

    test(
      'returns ErrorBaseResponse when api call throws generic Exception',
      () async {
        when(
          mockApiClient.getPendingOrders(page: anyNamed('page')),
        ).thenThrow(Exception('boom'));

        final result = await dataSource.getPendingOrders(page: 1);

        expect(result, isA<ErrorBaseResponse<PendingOrdersResponseModel>>());
        expect(
          (result as ErrorBaseResponse<PendingOrdersResponseModel>)
              .errorMessage,
          'unknownError',
        );
      },
    );
  });

  group('startOrder', () {
    const fakeActionResponse = UpdateOrderStateResponseModel(
      message: 'success',
    );

    test('returns SuccessBaseResponse when api call succeeds', () async {
      when(
        mockApiClient.startOrder('123'),
      ).thenAnswer((_) async => fakeActionResponse);

      final result = await dataSource.startOrder('123');

      verify(mockApiClient.startOrder('123')).called(1);
      expect(result, isA<SuccessBaseResponse<UpdateOrderStateResponseModel>>());
      expect(
        (result as SuccessBaseResponse<UpdateOrderStateResponseModel>).data,
        fakeActionResponse,
      );
    });

    test(
      'returns ErrorBaseResponse when api call throws DioException',
      () async {
        when(mockApiClient.startOrder(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await dataSource.startOrder('123');

        expect(result, isA<ErrorBaseResponse<UpdateOrderStateResponseModel>>());
      },
    );

    test(
      'returns ErrorBaseResponse when api call throws generic Exception',
      () async {
        when(mockApiClient.startOrder(any)).thenThrow(Exception('crash'));

        final result = await dataSource.startOrder('123');

        expect(result, isA<ErrorBaseResponse<UpdateOrderStateResponseModel>>());
        expect(
          (result as ErrorBaseResponse<UpdateOrderStateResponseModel>)
              .errorMessage,
          'unknownError',
        );
      },
    );
  });

  group('getOrderShipping', () {
    late MockCollectionReference mockCollection;
    late MockDocumentReference mockDoc;
    late MockDocumentSnapshot mockSnapshot;

    setUp(() {
      mockCollection = MockCollectionReference();
      mockDoc = MockDocumentReference();
      mockSnapshot = MockDocumentSnapshot();
      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDoc);
      when(mockDoc.get()).thenAnswer((_) async => mockSnapshot);
    });

    test('returns the shipping model from the order document', () async {
      when(mockSnapshot.exists).thenReturn(true);
      when(mockSnapshot.data()).thenReturn({
        AppConstants.shippingAddressField: {
          AppConstants.streetField: 'Nasr City',
          AppConstants.cityField: 'Cairo',
          AppConstants.phoneField: '0122',
          AppConstants.latField: 30.1,
          AppConstants.longField: 31.2,
        },
      });

      final result = await dataSource.getOrderShipping('order1');

      expect(result, isA<OrderShippingFirestoreModel>());
      expect(result?.street, 'Nasr City');
      expect(result?.city, 'Cairo');
      expect(result?.lat, '30.1');
      expect(result?.long, '31.2');
      verify(mockFirestore.collection(AppConstants.ordersCollection)).called(1);
      verify(mockCollection.doc('order1')).called(1);
    });

    test('returns null when the document does not exist', () async {
      when(mockSnapshot.exists).thenReturn(false);
      when(mockSnapshot.data()).thenReturn(null);

      final result = await dataSource.getOrderShipping('order1');

      expect(result, isNull);
    });
  });

  group('updateOrderState', () {
    const fakeActionResponse = UpdateOrderStateResponseModel(
      message: 'success',
    );

    test('returns SuccessBaseResponse when api call succeeds', () async {
      when(
        mockApiClient.updateOrderState(
          '123',
          const UpdateOrderStateRequestModel(state: OrderStatus.inProgress),
        ),
      ).thenAnswer((_) async => fakeActionResponse);

      final result = await dataSource.updateOrderState(
        '123',
        OrderStatus.inProgress,
      );

      verify(
        mockApiClient.updateOrderState(
          '123',
          const UpdateOrderStateRequestModel(state: OrderStatus.inProgress),
        ),
      ).called(1);
      expect(result, isA<SuccessBaseResponse<UpdateOrderStateResponseModel>>());
      expect(
        (result as SuccessBaseResponse<UpdateOrderStateResponseModel>).data,
        fakeActionResponse,
      );
    });

    test(
      'returns ErrorBaseResponse when api call throws DioException',
      () async {
        when(mockApiClient.updateOrderState(any, any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ''),
            type: DioExceptionType.badResponse,
          ),
        );

        final result = await dataSource.updateOrderState(
          '123',
          OrderStatus.completed,
        );

        expect(result, isA<ErrorBaseResponse<UpdateOrderStateResponseModel>>());
      },
    );

    test(
      'returns ErrorBaseResponse when api call throws generic Exception',
      () async {
        when(
          mockApiClient.updateOrderState(any, any),
        ).thenThrow(Exception('fail'));

        final result = await dataSource.updateOrderState(
          '123',
          OrderStatus.inProgress,
        );

        expect(result, isA<ErrorBaseResponse<UpdateOrderStateResponseModel>>());
        expect(
          (result as ErrorBaseResponse<UpdateOrderStateResponseModel>)
              .errorMessage,
          'unknownError',
        );
      },
    );
  });
}
