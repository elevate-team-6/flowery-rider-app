import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/vehicle_type_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/get_vehicle_type_use_case.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/edit_vehicle/edit_vehicle_states.dart';

import 'edit_vehicle_cubit_test.mocks.dart';

@GenerateMocks([GetVehicleTypeUseCase])
void main() {
    setUpAll(() {
    provideDummy<BaseResponse<List<VehicleTypeEntity>>>(
      SuccessBaseResponse<List<VehicleTypeEntity>>([]),
    );
  });
  late MockGetVehicleTypeUseCase mockGetVehicleTypeUseCase;
  late EditVehicleCubit cubit;

  setUp(() {
    mockGetVehicleTypeUseCase = MockGetVehicleTypeUseCase();

    cubit = EditVehicleCubit(getVehicleTypesUseCase: mockGetVehicleTypeUseCase);
  });

  tearDown(() {
    cubit.close();
  });

  group('EditVehicleCubit', () {
    final vehicles = [
      const VehicleTypeEntity(id: '1', type: 'Bike', image: ''),
      const VehicleTypeEntity(id: '2', type: 'Car', image: ''),
    ];

    blocTest<EditVehicleCubit, EditVehicleState>(
      'initialize event',
      build: () => cubit,
      act: (cubit) => cubit.doIntent(
        const InitializeEditVehicleEvent(
          vehicleTypeId: '2',
          vehicleNumber: '123',
          vehicleLicenseUrl: 'license.png',
        ),
      ),
      expect: () => [
        predicate<EditVehicleState>(
          (state) => state.drivingLicenseImageUrl == 'license.png',
        ),
      ],
    );

    blocTest<EditVehicleCubit, EditVehicleState>(
      'get vehicle types success',
      build: () {
        when(mockGetVehicleTypeUseCase()).thenAnswer(
          (_) async => SuccessBaseResponse<List<VehicleTypeEntity>>(vehicles),
        );

        return cubit;
      },
      act: (cubit) async {
        await cubit.doIntent(
          const InitializeEditVehicleEvent(
            vehicleTypeId: '2',
            vehicleNumber: '',
            vehicleLicenseUrl: '',
          ),
        );

        await cubit.doIntent(const GetVehicleTypesEvent());
      },
      expect: () => [
        isA<EditVehicleState>(),
        predicate<EditVehicleState>(
          (state) => state.vehicleTypesState.isLoading,
        ),
        predicate<EditVehicleState>(
          (state) =>
              state.vehicleTypesState.data?.length == 2 &&
              state.selectedVehicleType?.id == '2',
        ),
      ],
    );

    blocTest<EditVehicleCubit, EditVehicleState>(
      'get vehicle types error',
      build: () {
        when(mockGetVehicleTypeUseCase()).thenAnswer(
          (_) async => ErrorBaseResponse<List<VehicleTypeEntity>>('error'),
        );

        return cubit;
      },
      act: (cubit) => cubit.doIntent(const GetVehicleTypesEvent()),
      expect: () => [
        predicate<EditVehicleState>(
          (state) => state.vehicleTypesState.isLoading,
        ),
        predicate<EditVehicleState>(
          (state) => state.vehicleTypesState.errorMessage == 'error',
        ),
      ],
    );

    blocTest<EditVehicleCubit, EditVehicleState>(
      'change vehicle type',
      build: () => cubit,
      act: (cubit) => cubit.doIntent(ChangeVehicleTypeEvent(vehicles.first)),
      expect: () => [
        predicate<EditVehicleState>(
          (state) =>
              state.selectedVehicleType == vehicles.first && state.hasChanges,
        ),
      ],
    );

    blocTest<EditVehicleCubit, EditVehicleState>(
      'change vehicle number',
      build: () => cubit,
      act: (cubit) => cubit.doIntent(const ChangeVehicleNumberEvent()),
      expect: () => [predicate<EditVehicleState>((state) => state.hasChanges)],
    );

    blocTest<EditVehicleCubit, EditVehicleState>(
      'submit',
      build: () => cubit,
      seed: () => const EditVehicleState(hasChanges: true),
      act: (cubit) =>
          cubit.doIntent(const EditVehicleSubmitEvent(vehicleNumber: '')),
      expect: () => [predicate<EditVehicleState>((state) => !state.hasChanges)],
    );
  });
}
