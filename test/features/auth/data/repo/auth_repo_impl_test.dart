import 'package:flowery_rider_app/features/tracking/presentation/widgets/vehicle_type_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flowery_rider_app/config/base_response/base_response.dart';

import 'package:flowery_rider_app/features/auth/data/data_sources/auth_local_data_source_contract.dart';
import 'package:flowery_rider_app/features/auth/data/data_sources/auth_remote_data_source_contract.dart';

import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';


import 'package:flowery_rider_app/features/auth/data/models/response/signup/country_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/driver_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/signup_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/signup/vehicle_type_model.dart';

import 'package:flowery_rider_app/features/auth/data/models/response/sign_in_response_model.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/forgot_password_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/verify_reset_code_response.dart';
import 'package:flowery_rider_app/features/auth/data/models/response/reset_password_response.dart';

import 'package:flowery_rider_app/features/auth/data/repo/auth_repo_impl.dart';

import 'package:flowery_rider_app/features/auth/domain/entities/forget_password_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/sign_in_entity.dart';

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

    provideDummy<BaseResponse<SignInResponseModel>>(
      ErrorBaseResponse<SignInResponseModel>('dummy'),
    );

    provideDummy<BaseResponse<ForgetPasswordResponse>>(
      SuccessBaseResponse<ForgetPasswordResponse>(null),
    );

    provideDummy<BaseResponse<VerifyResetCodeResponse>>(
      SuccessBaseResponse<VerifyResetCodeResponse>(null),
    );

    provideDummy<BaseResponse<ResetPasswordResponse>>(
      SuccessBaseResponse<ResetPasswordResponse>(null),
    );
  });

  late MockAuthRemoteDataSourceContract remoteDataSource;
  late MockAuthRemoteDataSourceContract mockRemoteDataSource;
  late MockAuthLocalDataSourceContract localDataSource;

  late AuthRepoImpl repo;

  setUp(() {
    remoteDataSource = MockAuthRemoteDataSourceContract();
    mockRemoteDataSource = MockAuthRemoteDataSourceContract();
    localDataSource = MockAuthLocalDataSourceContract();

    repo = AuthRepoImpl(
      remoteDataSource,
      localDataSource,
      mockRemoteDataSource,
    );
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
    });
  });

  group('getVehicles', () {
    test('should return vehicles when api succeeds', () async {
      when(remoteDataSource.vehicles()).thenAnswer(
        (_) async => SuccessBaseResponse(
          VehicleResponse(
            vehicles: [VehicleModel(id: '1', type: 'Car', image: 'car.png')],
          ),
        ),
      );

      final result = await repo.getVehicles();

      expect(result, isA<SuccessBaseResponse<List<VehicleTypeEntity>>>());
    });
  });

  group('AuthRepoImpl - Sign In', () {
    const request = SignInRequestModel(
      email: 'test@test.com',
      password: 'Ahmed@123',
    );

    const response = SignInResponseModel(
      message: 'success',
      token: 'fake_token',
    );

    test('returns SuccessBaseResponse', () async {
      when(
        remoteDataSource.signIn(request),
      ).thenAnswer((_) async => SuccessBaseResponse(response));

      final result = await repo.signIn(request);

      expect(result, isA<SuccessBaseResponse<SignInEntity>>());
    });

    test('returns ErrorBaseResponse', () async {
      when(
        remoteDataSource.signIn(request),
      ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

      final result = await repo.signIn(request);

      expect(result, isA<ErrorBaseResponse<SignInEntity>>());
    });
  });

  group('AuthRepoImpl - Forget Password', () {
    test('should return Success', () async {
      when(mockRemoteDataSource.forgotPassword(any)).thenAnswer(
        (_) async => SuccessBaseResponse(
          const ForgetPasswordResponse(
            statusMsg: 'success',
            message: 'OTP sent',
          ),
        ),
      );

      final result = await repo.forgotPassword(email: 'test@test.com');

      expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());
    });
  });

  group('AuthRepoImpl - Verify Reset Code', () {
    test('should return Success', () async {
      when(mockRemoteDataSource.verifyResetCode(any)).thenAnswer(
        (_) async => SuccessBaseResponse(
          const VerifyResetCodeResponse(message: 'Verified'),
        ),
      );

      final result = await repo.verifyResetCode(resetCode: '123456');

      expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());
    });
  });

  group('AuthRepoImpl - Reset Password', () {
    test('should return Success', () async {
      when(mockRemoteDataSource.resetPassword(any)).thenAnswer(
        (_) async => SuccessBaseResponse(
          const ResetPasswordResponse(message: 'Success'),
        ),
      );

      final result = await repo.resetPassword(
        email: 'test@test.com',
        newPassword: '123456',
      );

      expect(result, isA<SuccessBaseResponse<ForgetPasswordEntity>>());
    });
  });
}
