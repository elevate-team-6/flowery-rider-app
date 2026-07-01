import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/features/notification/data/data_sources/notification_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/notification/data/repo/notification_repo_impl.dart';
import 'package:flowery_rider_app/features/notification/domain/entities/user_notification_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'notification_repo_impl_test.mocks.dart';

@GenerateMocks([
  NotificationRemoteDataSourceContract,
  SecureCacheHelper,
  FirebaseCrashlytics,
])
void main() {
  late NotificationRepoImpl repo;
  late MockNotificationRemoteDataSourceContract mockRemoteDataSource;
  late MockSecureCacheHelper mockSecureCacheHelper;
  late MockFirebaseCrashlytics mockCrashlytics;

  setUp(() {
    mockRemoteDataSource = MockNotificationRemoteDataSourceContract();
    mockSecureCacheHelper = MockSecureCacheHelper();
    mockCrashlytics = MockFirebaseCrashlytics();
    repo = NotificationRepoImpl(
      mockRemoteDataSource,
      mockSecureCacheHelper,
      mockCrashlytics,
    );
  });

  const tUserId = 'user123';
  const tOrderId = 'order123';
  const tState = UserNotificationState.accepted;

  group('updateOrderProgress', () {
    test(
      'should return SuccessBaseResponse even if FCM config is missing (graceful failure)',
      () async {
        when(
          mockSecureCacheHelper.readData(key: anyNamed('key')),
        ).thenAnswer((_) async => 'val');
        when(
          mockRemoteDataSource.updateOrderInFirestore(any),
        ).thenAnswer((_) async {});
        when(mockRemoteDataSource.getFcmConfig()).thenAnswer((_) async => null);

        final result = await repo.updateOrderProgress(
          userId: tUserId,
          orderId: tOrderId,
          state: tState,
        );

        expect(result, isA<SuccessBaseResponse<void>>());
        verify(mockRemoteDataSource.updateOrderInFirestore(any)).called(1);
        verify(mockRemoteDataSource.getFcmConfig()).called(1);
        verifyNever(mockRemoteDataSource.getUserData(any));
      },
    );

    test(
      'should return SuccessBaseResponse when FCM config fields are incomplete',
      () async {
        when(
          mockSecureCacheHelper.readData(key: anyNamed('key')),
        ).thenAnswer((_) async => 'val');
        when(
          mockRemoteDataSource.updateOrderInFirestore(any),
        ).thenAnswer((_) async {});
        when(mockRemoteDataSource.getFcmConfig()).thenAnswer(
          (_) async => {
            'project_id': 'project',
            // missing private_key and client_email
          },
        );

        final result = await repo.updateOrderProgress(
          userId: tUserId,
          orderId: tOrderId,
          state: tState,
        );

        expect(result, isA<SuccessBaseResponse<void>>());
        verify(
          mockCrashlytics.recordError(
            any,
            any,
            reason: anyNamed('reason'),
            fatal: anyNamed('fatal'),
          ),
        ).called(1);
      },
    );

    test(
      'should return SuccessBaseResponse when user data or token is missing',
      () async {
        when(
          mockSecureCacheHelper.readData(key: anyNamed('key')),
        ).thenAnswer((_) async => 'val');
        when(
          mockRemoteDataSource.updateOrderInFirestore(any),
        ).thenAnswer((_) async {});
        when(mockRemoteDataSource.getFcmConfig()).thenAnswer(
          (_) async => {
            'private_key': 'key',
            'client_email': 'email',
            'project_id': 'project',
          },
        );

        when(
          mockRemoteDataSource.getUserData(any),
        ).thenAnswer((_) async => null);

        final result = await repo.updateOrderProgress(
          userId: tUserId,
          orderId: tOrderId,
          state: tState,
        );

        expect(result, isA<SuccessBaseResponse<void>>());
      },
    );
  });
}
