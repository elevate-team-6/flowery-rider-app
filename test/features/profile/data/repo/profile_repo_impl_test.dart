import 'package:flowery_rider_app/features/profile/data/models/response/driver_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/profile/data/models/response/profile_response.dart';
import 'package:flowery_rider_app/features/profile/data/repo/profile_repo_impl.dart';
import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';

import 'profile_repo_impl_test.mocks.dart';

@GenerateMocks([ProfileRemoteDataSourceContract, SecureCacheHelper])
void main() {
  setUpAll(() {
    provideDummy<BaseResponse<void>>(SuccessBaseResponse<void>(null));

    provideDummy<BaseResponse<ProfileResponse>>(
      ErrorBaseResponse<ProfileResponse>('dummy'),
    );
  });
  late MockProfileRemoteDataSourceContract remoteDataSource;
  late MockSecureCacheHelper secureCacheHelper;
  late ProfileRepoImpl repo;

  setUp(() {
    remoteDataSource = MockProfileRemoteDataSourceContract();
    secureCacheHelper = MockSecureCacheHelper();

    repo = ProfileRepoImpl(remoteDataSource, secureCacheHelper);
  });

  group('logout', () {
    test('should delete token and return success response', () async {
      final successResponse = SuccessBaseResponse<void>(null);

      when(remoteDataSource.logout()).thenAnswer((_) async => successResponse);

      when(
        secureCacheHelper.deleteData(key: anyNamed('key')),
      ).thenAnswer((_) async {});

      final result = await repo.logout();

      expect(result, successResponse);

      verify(remoteDataSource.logout()).called(1);

      verify(secureCacheHelper.deleteData(key: AppKeys.tokenKey)).called(1);
    });

    test('should delete token and return error response', () async {
      final errorResponse = ErrorBaseResponse<void>('error');

      when(remoteDataSource.logout()).thenAnswer((_) async => errorResponse);

      when(
        secureCacheHelper.deleteData(key: anyNamed('key')),
      ).thenAnswer((_) async {});

      final result = await repo.logout();

      expect(result, errorResponse);

      verify(remoteDataSource.logout()).called(1);

      verify(secureCacheHelper.deleteData(key: AppKeys.tokenKey)).called(1);
    });
  });

  group('profile', () {
    test('should return DriverEntity when profile request succeeds', () async {
      final profileResponse = ProfileResponse(
        driver: DriverModel(firstName: 'Ahmed', lastName: 'Ali'),
      );

      when(remoteDataSource.profile()).thenAnswer(
        (_) async => SuccessBaseResponse<ProfileResponse>(profileResponse),
      );

      final result = await repo.profile();

      expect(result, isA<SuccessBaseResponse<DriverEntity>>());

      final successResult = result as SuccessBaseResponse<DriverEntity>;

      expect(successResult.data?.firstName, 'Ahmed');

      verify(remoteDataSource.profile()).called(1);
    });

    test('should return userNotFound when driver is null', () async {
      final profileResponse = ProfileResponse(driver: null);

      when(remoteDataSource.profile()).thenAnswer(
        (_) async => SuccessBaseResponse<ProfileResponse>(profileResponse),
      );

      final result = await repo.profile();

      expect(result, isA<ErrorBaseResponse<DriverEntity>>());

      final error = result as ErrorBaseResponse<DriverEntity>;

      expect(error.errorMessage, AppStrings.userNotFound);

      verify(remoteDataSource.profile()).called(1);
    });

    test(
      'should return error response when remote data source fails',
      () async {
        when(remoteDataSource.profile()).thenAnswer(
          (_) async => ErrorBaseResponse<ProfileResponse>('server error'),
        );

        final result = await repo.profile();

        expect(result, isA<ErrorBaseResponse<DriverEntity>>());

        final error = result as ErrorBaseResponse<DriverEntity>;

        expect(error.errorMessage, 'server error');

        verify(remoteDataSource.profile()).called(1);
      },
    );
  });
}
