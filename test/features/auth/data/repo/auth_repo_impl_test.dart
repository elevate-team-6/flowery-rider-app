import 'package:flowery_rider_app/features/auth/data/models/response/signup/country_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/driver_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/data/data_sources/auth_local_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:flowery_rider_app/features/auth/data/repo/auth_repo_impl.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSourceContract, AuthLocalDataSourceContract])
void main() {
  setUpAll(() {
    provideDummy<BaseResponse<SignUpResponse>>(
      ErrorBaseResponse<SignUpResponse>('dummy'),
    );
  });
  late MockAuthRemoteDataSourceContract mockRemoteDataSource;
  late MockAuthLocalDataSourceContract mockLocalDataSource;

  late AuthRepoImpl repo;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSourceContract();
    mockLocalDataSource = MockAuthLocalDataSourceContract();

    repo = AuthRepoImpl(mockRemoteDataSource, mockLocalDataSource);
  });

  group('signup', () {
    test(
      'should return SuccessBaseResponse<DriverEntity> when signup succeeds',
      () async {
        final request = SignUpRequest();

        final response = SignUpResponse(
          driver: DriverModel(
            firstName: 'GoOo'
            
          )
        );

        when(
          mockRemoteDataSource.signup(request),
        ).thenAnswer((_) async => SuccessBaseResponse(response));

        final result = await repo.signup(request);

        expect(result, isA<SuccessBaseResponse>());

        verify(mockRemoteDataSource.signup(request)).called(1);
      },
    );

    test('should return ErrorBaseResponse when driver is null', () async {
      final request = SignUpRequest();

      when(mockRemoteDataSource.signup(request)).thenAnswer(
        (_) async => SuccessBaseResponse(SignUpResponse(driver: null)),
      );

      final result = await repo.signup(request);

      expect(result, isA<ErrorBaseResponse>());

      verify(mockRemoteDataSource.signup(request)).called(1);
    });

    test('should return ErrorBaseResponse when remote returns error', () async {
      final request = SignUpRequest();

      when(
        mockRemoteDataSource.signup(request),
      ).thenAnswer((_) async => ErrorBaseResponse('Server Error'));

      final result = await repo.signup(request);

      expect(result, isA<ErrorBaseResponse>());

      verify(mockRemoteDataSource.signup(request)).called(1);
    });
  });

  group('getCountries', () {
    test('should return countries from local datasource', () async {
      final List<CountryModel> countries = [
        CountryModel(
          name: 'Egypt',
          flag: '🇪🇬',
          isoCode: '',
          phoneCode: '',
          currency: '',
        ),
      ];

      when(
        mockLocalDataSource.getCountries(),
      ).thenAnswer((_) async => countries);

      final result = await repo.getCountries();

      expect(result, isNotEmpty);

      verify(mockLocalDataSource.getCountries()).called(1);
    });
  });
}
