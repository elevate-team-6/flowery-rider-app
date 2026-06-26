import 'package:flowery_rider_app/features/profile/data/repo/profile_repo_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/features/profile/data/data_sources/profile_remote_data_source_contract.dart';
import 'profile_repo_impl_test.mocks.dart';

@GenerateMocks([
  ProfileRemoteDataSourceContract,
  SecureCacheHelper,
])
void main() {
   setUpAll(() {
    provideDummy<BaseResponse<void>>(
      SuccessBaseResponse<void>(null),
    );

    provideDummy<BaseResponse<String>>(
      SuccessBaseResponse<String>( ''),
    );
  });
  late MockProfileRemoteDataSourceContract remoteDataSource;
  late MockSecureCacheHelper secureCacheHelper;
  late ProfileRepoImpl repo;

  setUp(() {
    remoteDataSource = MockProfileRemoteDataSourceContract();
    secureCacheHelper = MockSecureCacheHelper();

    repo = ProfileRepoImpl(
      remoteDataSource,
      secureCacheHelper,
    );
  });

  group('logout', () {
    test(
      'should call remote datasource logout and delete token when success',
      () async {
        // arrange
        when(
          remoteDataSource.logout(),
        ).thenAnswer(
          (_) async => SuccessBaseResponse<void>( null),
        );

        when(
          secureCacheHelper.deleteData(
            key: AppKeys.tokenKey,
          ),
        ).thenAnswer((_) async {});

        // act
        final result = await repo.logout();

        // assert
        expect(result, isA<SuccessBaseResponse<void>>());

        verify(remoteDataSource.logout()).called(1);

        verify(
          secureCacheHelper.deleteData(
            key: AppKeys.tokenKey,
          ),
        ).called(1);
      },
    );

    test(
      'should delete token even when remote logout fails',
      () async {
        // arrange
        when(
          remoteDataSource.logout(),
        ).thenAnswer(
          (_) async => ErrorBaseResponse<void>(
            'logout failed',
          ),
        );

        when(
          secureCacheHelper.deleteData(
            key: AppKeys.tokenKey,
          ),
        ).thenAnswer((_) async {});

        // act
        final result = await repo.logout();

        // assert
        expect(result, isA<ErrorBaseResponse<void>>());

        verify(remoteDataSource.logout()).called(1);

        verify(
          secureCacheHelper.deleteData(
            key: AppKeys.tokenKey,
          ),
        ).called(1);
      },
    );
  });

  group('changePassword', () {
    test(
      'should return success response from remote datasource',
      () async {
        // arrange
        when(
          remoteDataSource.changePassword(
            'oldPass',
            'newPass',
          ),
        ).thenAnswer(
          (_) async => SuccessBaseResponse<String>(
             'new_token',
          ),
        );

        // act
        final result = await repo.changePassword(
          'oldPass',
          'newPass',
        );

        // assert
        expect(result, isA<SuccessBaseResponse<String>>());

        verify(
          remoteDataSource.changePassword(
            'oldPass',
            'newPass',
          ),
        ).called(1);

        verifyNever(
          secureCacheHelper.deleteData(
            key: anyNamed('key'),
          ),
        );
      },
    );

    test(
      'should return error response from remote datasource',
      () async {
        // arrange
        when(
          remoteDataSource.changePassword(
            'oldPass',
            'newPass',
          ),
        ).thenAnswer(
          (_) async => ErrorBaseResponse<String>(
            'wrong password',
          ),
        );

        // act
        final result = await repo.changePassword(
          'oldPass',
          'newPass',
        );

        // assert
        expect(result, isA<ErrorBaseResponse<String>>());

        verify(
          remoteDataSource.changePassword(
            'oldPass',
            'newPass',
          ),
        ).called(1);

        verifyNever(
          secureCacheHelper.deleteData(
            key: anyNamed('key'),
          ),
        );
      },
    );
  });
}