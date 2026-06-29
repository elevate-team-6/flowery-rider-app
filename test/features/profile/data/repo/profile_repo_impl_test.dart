import 'dart:io';

import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/profile/data/models/request/edit_profile_request.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/driver_model.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/driver_response_model.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response_model.dart';
import 'package:flowery_rider_app/features/profile/data/repo/profile_repo_impl.dart';
import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'profile_repo_impl_test.mocks.dart';

@GenerateMocks([ProfileRemoteDataSourceContract, SecureCacheHelper])
void main() {
  setUpAll(() {
    provideDummy<BaseResponse<ProfileResponseModel>>(
      ErrorBaseResponse('dummy'),
    );
    provideDummy<BaseResponse<ProfileResponse>>(
      ErrorBaseResponse<ProfileResponse>('dummy'),
    );
    provideDummy<BaseResponse<void>>(SuccessBaseResponse<void>(null));
  });

  late ProfileRepoImpl repo;
  late MockProfileRemoteDataSourceContract mockRemoteDataSource;
  late MockSecureCacheHelper mockCache;

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSourceContract();
    mockCache = MockSecureCacheHelper();
    repo = ProfileRepoImpl(mockRemoteDataSource, mockCache);
  });

  const fakeResponse = ProfileResponseModel(
    message: 'success',
    driver: DriverResponseModel(
      id: '1',
      firstName: 'Ahmed',
      lastName: 'Ali',
      email: 'ahmed@test.com',
      phone: '+201030313971',
    ),
  );

  const request = EditProfileRequest(
    firstName: 'Ahmed',
    lastName: 'Ali',
    email: 'ahmed@test.com',
    phone: '+201030313971',
  );

  group('getProfileData', () {
    test('maps response model to entity on success', () async {
      when(
        mockRemoteDataSource.getProfileData(),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeResponse));

      final result = await repo.getProfileData();

      verify(mockRemoteDataSource.getProfileData()).called(1);
      expect(result, isA<SuccessBaseResponse<DriverEntity>>());
      final success = result as SuccessBaseResponse<DriverEntity>;
      expect(success.data?.id, '1');
      expect(success.data?.firstName, 'Ahmed');
      expect(success.data?.email, 'ahmed@test.com');
    });

    test('returns null entity data when driver is null', () async {
      when(mockRemoteDataSource.getProfileData()).thenAnswer(
        (_) async => SuccessBaseResponse(const ProfileResponseModel()),
      );

      final result = await repo.getProfileData();

      expect(result, isA<SuccessBaseResponse<DriverEntity>>());
      expect((result as SuccessBaseResponse<DriverEntity>).data, isNull);
    });

    test('propagates error message on failure', () async {
      when(
        mockRemoteDataSource.getProfileData(),
      ).thenAnswer((_) async => ErrorBaseResponse('network error'));

      final result = await repo.getProfileData();

      expect(result, isA<ErrorBaseResponse<DriverEntity>>());
      expect((result as ErrorBaseResponse).errorMessage, 'network error');
    });

    test('returns error when a required driver field is missing', () async {
      const incompleteResponse = ProfileResponseModel(
        message: 'success',
        driver: DriverResponseModel(
          // id is null -> mapping to the entity must fail.
          firstName: 'Ahmed',
          lastName: 'Ali',
          email: 'ahmed@test.com',
          phone: '+201030313971',
        ),
      );
      when(
        mockRemoteDataSource.getProfileData(),
      ).thenAnswer((_) async => SuccessBaseResponse(incompleteResponse));

      final result = await repo.getProfileData();

      expect(result, isA<ErrorBaseResponse<DriverEntity>>());
    });
  });

  group('editProfile', () {
    test('maps response model to entity on success', () async {
      when(
        mockRemoteDataSource.editProfile(request),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeResponse));

      final result = await repo.editProfile(request);

      verify(mockRemoteDataSource.editProfile(request)).called(1);
      expect(result, isA<SuccessBaseResponse<DriverEntity>>());
      expect(
        (result as SuccessBaseResponse<DriverEntity>).data?.firstName,
        'Ahmed',
      );
    });

    test('propagates error message on failure', () async {
      when(
        mockRemoteDataSource.editProfile(any),
      ).thenAnswer((_) async => ErrorBaseResponse('validation error'));

      final result = await repo.editProfile(request);

      expect(result, isA<ErrorBaseResponse<DriverEntity>>());
      expect((result as ErrorBaseResponse).errorMessage, 'validation error');
    });
  });

  group('uploadPhoto', () {
    final photo = File('avatar.png');

    test('maps response model to entity on success', () async {
      when(
        mockRemoteDataSource.uploadPhoto(photo),
      ).thenAnswer((_) async => SuccessBaseResponse(fakeResponse));

      final result = await repo.uploadPhoto(photo);

      verify(mockRemoteDataSource.uploadPhoto(photo)).called(1);
      expect(result, isA<SuccessBaseResponse<DriverEntity>>());
      expect((result as SuccessBaseResponse<DriverEntity>).data?.id, '1');
    });

    test('propagates error message on failure', () async {
      when(
        mockRemoteDataSource.uploadPhoto(any),
      ).thenAnswer((_) async => ErrorBaseResponse('upload failed'));

      final result = await repo.uploadPhoto(photo);

      expect(result, isA<ErrorBaseResponse<DriverEntity>>());
    });
  });

  group('profile', () {
    test('should return DriverEntity when profile request succeeds', () async {
      final profileResponse = ProfileResponse(
        driver: DriverModel(firstName: 'Ahmed', lastName: 'Ali'),
      );

      when(mockRemoteDataSource.profile()).thenAnswer(
        (_) async => SuccessBaseResponse<ProfileResponse>(profileResponse),
      );

      final result = await repo.profile();

      expect(result, isA<SuccessBaseResponse<DriverEntity>>());

      final successResult = result as SuccessBaseResponse<DriverEntity>;

      expect(successResult.data?.firstName, 'Ahmed');

      verify(mockRemoteDataSource.profile()).called(1);
    });

    test('should return userNotFound when driver is null', () async {
      final profileResponse = ProfileResponse(driver: null);

      when(mockRemoteDataSource.profile()).thenAnswer(
        (_) async => SuccessBaseResponse<ProfileResponse>(profileResponse),
      );

      final result = await repo.profile();

      expect(result, isA<ErrorBaseResponse<DriverEntity>>());

      final error = result as ErrorBaseResponse<DriverEntity>;

      expect(error.errorMessage, AppStrings.userNotFound);

      verify(mockRemoteDataSource.profile()).called(1);
    });

    test(
      'should return error response when remote data source fails',
      () async {
        when(mockRemoteDataSource.profile()).thenAnswer(
          (_) async => ErrorBaseResponse<ProfileResponse>('server error'),
        );

        final result = await repo.profile();

        expect(result, isA<ErrorBaseResponse<DriverEntity>>());

        final error = result as ErrorBaseResponse<DriverEntity>;

        expect(error.errorMessage, 'server error');

        verify(mockRemoteDataSource.profile()).called(1);
      },
    );
  });

  group('logout', () {
    test('clears the cached token and returns the remote result', () async {
      when(
        mockRemoteDataSource.logout(),
      ).thenAnswer((_) async => SuccessBaseResponse(null));
      when(mockCache.deleteData(key: anyNamed('key'))).thenAnswer((_) async {});

      final result = await repo.logout();

      verify(mockRemoteDataSource.logout()).called(1);
      verify(mockCache.deleteData(key: AppKeys.tokenKey)).called(1);
      expect(result, isA<SuccessBaseResponse<void>>());
    });

    test('still clears the token even when remote logout fails', () async {
      when(
        mockRemoteDataSource.logout(),
      ).thenAnswer((_) async => ErrorBaseResponse('network error'));
      when(mockCache.deleteData(key: anyNamed('key'))).thenAnswer((_) async {});

      final result = await repo.logout();

      verify(mockCache.deleteData(key: AppKeys.tokenKey)).called(1);
      expect(result, isA<ErrorBaseResponse<void>>());
    });
  });
}
