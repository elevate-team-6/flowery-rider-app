import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/core/utils/app_constants.dart';
import 'package:flowery_rider_app/features/notification/api/data_sources/notification_remote_data_source_impl.dart';
import 'package:flowery_rider_app/features/notification/data/models/order_firestore_model.dart';
import 'package:flowery_rider_app/features/notification/data/models/user_firestore_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'notification_remote_data_source_impl_test.mocks.dart';

@GenerateMocks(
  [FirebaseFirestore, Dio],
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
  late NotificationRemoteDataSourceImpl dataSource;
  late MockFirebaseFirestore mockFirestore;
  late MockDio mockDio;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockDio = MockDio();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    dataSource = NotificationRemoteDataSourceImpl(mockFirestore, mockDio);
  });

  const tUserId = 'user123';
  final tUserData = {'fcmToken': 'token123', 'language': 'en'};

  group('getUserData', () {
    test('should return UserFirestoreModel when document exists', () async {
      when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(tUserData);

      final result = await dataSource.getUserData(tUserId);

      expect(result, isA<UserFirestoreModel>());
      expect(result?.fcmToken, 'token123');
      verify(mockFirestore.collection(AppConstants.usersCollection)).called(1);
      verify(mockCollectionReference.doc(tUserId)).called(1);
    });

    test('should return null when document does not exist', () async {
      when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      final result = await dataSource.getUserData(tUserId);

      expect(result, isNull);
    });

    test('should throw exception when firestore call fails', () async {
      when(
        mockFirestore.collection(any),
      ).thenThrow(Exception('Firestore error'));

      expect(() => dataSource.getUserData(tUserId), throwsException);
    });
  });

  group('getFcmConfig', () {
    test('should return map when config document exists', () async {
      when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(
        mockDocumentReference.get(),
      ).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn({'apiKey': 'val'});

      final result = await dataSource.getFcmConfig();

      expect(result, isA<Map<String, dynamic>>());
      expect(result?['apiKey'], 'val');
    });
  });

  group('sendPushNotification', () {
    final tParams = {
      'token': 'token',
      'title': 'title',
      'body': 'body',
      'accessToken': 'access',
      'projectId': 'project',
    };

    test(
      'should return SuccessBaseResponse(true) when statusCode is 200',
      () async {
        when(
          mockDio.post(
            any,
            options: anyNamed('options'),
            data: anyNamed('data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          ),
        );

        final result = await dataSource.sendPushNotification(
          token: tParams['token']!,
          title: tParams['title']!,
          body: tParams['body']!,
          accessToken: tParams['accessToken']!,
          projectId: tParams['projectId']!,
        );

        expect(result, isA<SuccessBaseResponse<bool>>());
        expect((result as SuccessBaseResponse).data, true);
      },
    );

    test(
      'should return SuccessBaseResponse(false) when statusCode is not 200',
      () async {
        when(
          mockDio.post(
            any,
            options: anyNamed('options'),
            data: anyNamed('data'),
          ),
        ).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
          ),
        );

        final result = await dataSource.sendPushNotification(
          token: tParams['token']!,
          title: tParams['title']!,
          body: tParams['body']!,
          accessToken: tParams['accessToken']!,
          projectId: tParams['projectId']!,
        );

        expect(result, isA<SuccessBaseResponse<bool>>());
        expect((result as SuccessBaseResponse).data, false);
      },
    );

    test('should return ErrorBaseResponse when Dio fails', () async {
      when(
        mockDio.post(any, options: anyNamed('options'), data: anyNamed('data')),
      ).thenThrow(DioException(requestOptions: RequestOptions(path: '')));

      final result = await dataSource.sendPushNotification(
        token: tParams['token']!,
        title: tParams['title']!,
        body: tParams['body']!,
        accessToken: tParams['accessToken']!,
        projectId: tParams['projectId']!,
      );

      expect(result, isA<ErrorBaseResponse>());
    });
  });

  group('updateOrderInFirestore', () {
    test('should call set with any SetOptions', () async {
      final tModel = OrderFirestoreModel(
        orderId: '1',
        status: 'pending',
        riderId: 'r1',
        riderName: 'rider',
        riderPhone: '123',
      );

      when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);

      await dataSource.updateOrderInFirestore(tModel);

      verify(mockDocumentReference.set(tModel.toJson(), any)).called(1);
    });
  });

  group('saveNotificationToHistory', () {
    test('should call update with correct data structure', () async {
      when(mockFirestore.collection(any)).thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);

      await dataSource.saveNotificationToHistory(
        userId: 'u1',
        title: 't',
        body: 'b',
        data: {'key': 'val'},
      );

      verify(mockDocumentReference.update(any)).called(1);
    });
  });
}
