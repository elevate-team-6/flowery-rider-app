import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/data/data_sources/auth_local_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/data_sources/auth_remote_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/country_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/driver_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_type_model.dart';
import 'package:flowery_rider_app/features/auth/data/repo/auth_repo_impl.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/vehicle_type_entity.dart';

import 'auth_repo_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSourceContract, AuthLocalDataSourceContract])
void main() {
  setUpAll(() {
    provideDummy<BaseResponse<SignUpResponse>>(
      ErrorBaseResponse<SignUpResponse>('dummy'),
    );

    provideDummy<BaseResponse<VehicleResponse>>(
      ErrorBaseResponse<VehicleResponse>('dummy'),
    );
  });
  late MockAuthRemoteDataSourceContract remoteDataSource;
  late MockAuthLocalDataSourceContract localDataSource;

  late AuthRepoImpl repo;

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSourceContract();
    localDataSource = MockAuthLocalDataSourceContract();

    repo = AuthRepoImpl(remoteDataSource, localDataSource);
  });

  group('signup', () {
    test('should return DriverEntity when signup succeeds', () async {
      when(remoteDataSource.signup(any)).thenAnswer(
        (_) async => SuccessBaseResponse(
          SignUpResponse(
            driver: DriverModel(
              id: '1',
              firstName: 'Youssef',
              lastName: 'Singer',
              email: 'test@test.com',
              phone: '01000000000',
              country: 'Egypt',
              gender: 'Male',
              vehicleType: 'Car',
              vehicleNumber: '123',
              vehicleLicense: 'license',
              nid: '123456789',
              nidImg: 'nid.png',
              photo: '',
              role: 'driver',
            ),
          ),
        ),
      );

      final result = await repo.signup(
        const SignUpRequest(
          country: '',
          firstName: '',
          lastName: '',
          vehicleType: '',
          vehicleNumber: '',
          nid: '',
          email: '',
          password: '',
          rePassword: '',
          gender: '',
          phone: '',
          vehicleLicense: null,
          nidImg: null,
        ),
      );

      expect(result, isA<SuccessBaseResponse>());
    });

    test('should return error when driver is null', () async {
      when(remoteDataSource.signup(any)).thenAnswer(
        (_) async => SuccessBaseResponse(SignUpResponse(driver: null)),
      );

      final result = await repo.signup(
        const SignUpRequest(
          country: '',
          firstName: '',
          lastName: '',
          vehicleType: '',
          vehicleNumber: '',
          nid: '',
          email: '',
          password: '',
          rePassword: '',
          gender: '',
          phone: '',
          vehicleLicense: null,
          nidImg: null,
        ),
      );

      expect(result, isA<ErrorBaseResponse>());
    });

    test('should return error when api fails', () async {
      when(
        remoteDataSource.signup(any),
      ).thenAnswer((_) async => ErrorBaseResponse('Server Error'));

      final result = await repo.signup(
        const SignUpRequest(
          country: '',
          firstName: '',
          lastName: '',
          vehicleType: '',
          vehicleNumber: '',
          nid: '',
          email: '',
          password: '',
          rePassword: '',
          gender: '',
          phone: '',
          vehicleLicense: null,
          nidImg: null,
        ),
      );

      expect(result, isA<ErrorBaseResponse>());
    });
  });

  group('getCountries', () {
    test('should return countries from local datasource', () async {
      when(localDataSource.getCountries()).thenAnswer(
        (_) async => [
          CountryModel(
            isoCode: 'EG',
            name: 'Egypt',
            phoneCode: '20',
            flag: '🇪🇬',
            currency: 'EGP',
          ),
        ],
      );

      final result = await repo.getCountries();

      expect(result.length, 1);
      expect(result.first.name, 'Egypt');

      verify(localDataSource.getCountries()).called(1);
    });
  });

  group('getVehicles', () {
    test('should return vehicles when api succeeds', () async {
      when(remoteDataSource.vehicles()).thenAnswer(
        (_) async => SuccessBaseResponse(
          VehicleResponse(
            vehicles: [
              VehicleModel(id: '1', type: 'Car', image: 'car.png'),
              VehicleModel(id: '2', type: 'Motorbike', image: 'bike.png'),
            ],
          ),
        ),
      );

      final result = await repo.getVehicles();

      expect(result, isA<SuccessBaseResponse<List<VehicleTypeEntity>>>());

      final data =
          (result as SuccessBaseResponse<List<VehicleTypeEntity>>).data;

      expect(data?.length, 2);
      expect(data?.first.type, 'Car');

      verify(remoteDataSource.vehicles()).called(1);
    });

    test('should return error when api fails', () async {
      when(
        remoteDataSource.vehicles(),
      ).thenAnswer((_) async => ErrorBaseResponse('Server Error'));

      final result = await repo.getVehicles();

      expect(result, isA<ErrorBaseResponse<List<VehicleTypeEntity>>>());

      verify(remoteDataSource.vehicles()).called(1);
    });
  });
}
