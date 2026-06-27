import 'package:bloc_test/bloc_test.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/core/entities/driver_entity.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/country_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/apply_use_case.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/get_countries_use_case.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/get_vehicle_type_use_case.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_events.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'apply_cubit_test.mocks.dart';

@GenerateMocks([GetCountriesUseCase, ApplyUseCase, GetVehicleTypeUseCase])
void main() {
  provideDummy<BaseResponse<List<VehicleTypeEntity>>>(
    ErrorBaseResponse('dummy'),
  );
  provideDummy<BaseResponse<DriverEntity>>(ErrorBaseResponse('dummy'));

  late ApplyCubit cubit;
  late MockGetCountriesUseCase mockGetCountriesUseCase;
  late MockApplyUseCase mockApplyUseCase;
  late MockGetVehicleTypeUseCase mockGetVehicleTypesUseCase;

  setUp(() {
    mockGetCountriesUseCase = MockGetCountriesUseCase();
    mockApplyUseCase = MockApplyUseCase();
    mockGetVehicleTypesUseCase = MockGetVehicleTypeUseCase();

    cubit = ApplyCubit(
      getCountriesUseCase: mockGetCountriesUseCase,
      applyUseCase: mockApplyUseCase,
      getVehicleTypesUseCase: mockGetVehicleTypesUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ApplyCubit Tests', () {
    const tCountries = [
      CountryEntity(
        id: '1',
        name: 'Egypt',
        isoCode: 'EG',
        phoneCode: '20',
        flag: '',
        currency: 'EGP',
      ),
    ];
    const tVehicleTypes = [
      VehicleTypeEntity(id: '1', type: 'Car', image: 'car.png'),
    ];

    blocTest<ApplyCubit, ApplyState>(
      'emits loading then success when GetCountriesEvent succeeds',
      build: () {
        when(mockGetCountriesUseCase()).thenAnswer((_) async => tCountries);
        return cubit;
      },
      act: (cubit) => cubit.doIntent(const GetCountriesEvent()),
      expect: () => [
        isA<ApplyState>().having(
          (s) => s.countriesState.isLoading,
          'isLoading',
          true,
        ),
        isA<ApplyState>().having(
          (s) => s.countriesState.data,
          'data',
          tCountries,
        ),
      ],
    );

    blocTest<ApplyCubit, ApplyState>(
      'emits loading then success when GetVehicleTypesEvent succeeds',
      build: () {
        when(
          mockGetVehicleTypesUseCase(),
        ).thenAnswer((_) async => SuccessBaseResponse(tVehicleTypes));
        return cubit;
      },
      act: (cubit) => cubit.doIntent(const GetVehicleTypesEvent()),
      expect: () => [
        isA<ApplyState>().having(
          (s) => s.vehicleTypesState.isLoading,
          'isLoading',
          true,
        ),
        isA<ApplyState>().having(
          (s) => s.vehicleTypesState.data,
          'data',
          tVehicleTypes,
        ),
      ],
    );

    blocTest<ApplyCubit, ApplyState>(
      'emits loading then success when ApplyDriverEvent succeeds',
      build: () {
        when(mockApplyUseCase(any)).thenAnswer(
          (_) async => SuccessBaseResponse(
            const DriverEntity(
              firstName: 'Ahmed',
              lastName: 'Ali',
              email: 'test@test.com',
              phone: '010',
              country: 'Egypt',
              gender: 'male',
              vehicleType: 'Car',
              vehicleNumber: '123',
              vehicleLicense: 'license.png',
              nid: '12345',
              nidImg: 'nid.png',
              role: 'driver',
              photo: 'photo.png',
              id: '1',
              name: 'Ahmed Ali',
            ),
          ),
        );
        return cubit;
      },
      act: (cubit) => cubit.doIntent(
        const ApplyDriverEvent(
          SignUpRequest(
            country: 'Egypt',
            firstName: 'Ahmed',
            lastName: 'Ali',
            vehicleType: 'Car',
            vehicleNumber: '123',
            nid: '12345',
            email: 'test@test.com',
            password: 'Password123',
            rePassword: 'Password123',
            gender: 'male',
            phone: '010',
            nidImg: null,
            vehicleLicense: null,
          ),
        ),
      ),
      expect: () => [
        isA<ApplyState>().having(
          (s) => s.applyState.isLoading,
          'isLoading',
          true,
        ),
        isA<ApplyState>().having(
          (s) => s.applyState.isLoading,
          'isLoading',
          false,
        ),
      ],
    );

    group('State Updates', () {
      blocTest<ApplyCubit, ApplyState>(
        'updates selectedCountry when ChangeCountryEvent is called',
        build: () => cubit,
        act: (cubit) => cubit.doIntent(ChangeCountryEvent(tCountries[0])),
        expect: () => [
          isA<ApplyState>().having(
            (s) => s.selectedCountry,
            'selectedCountry',
            tCountries[0],
          ),
        ],
      );

      blocTest<ApplyCubit, ApplyState>(
        'updates selectedVehicleType when ChangeVehicleTypeEvent is called',
        build: () => cubit,
        act: (cubit) =>
            cubit.doIntent(ChangeVehicleTypeEvent(tVehicleTypes[0])),
        expect: () => [
          isA<ApplyState>().having(
            (s) => s.selectedVehicleType,
            'selectedVehicleType',
            tVehicleTypes[0],
          ),
        ],
      );
    });
  });
}
