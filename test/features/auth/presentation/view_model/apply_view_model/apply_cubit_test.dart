import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/driver_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/apply_use_case.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/get_countries_use_case.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_events.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/apply_view_model/apply_state.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/signup/signup_request.dart';

import 'apply_cubit_test.mocks.dart';

@GenerateMocks([GetCountriesUseCase, ApplyUseCase])
void main() {
  setUpAll(() {
    provideDummy<DriverEntity>(
      DriverEntity(
        country: '',
        firstName: '',
        lastName: '',
        vehicleType: '',
        vehicleNumber: '',
        vehicleLicense: '',
        nid: '',
        nidImg: '',
        email: '',
        gender: '',
        phone: '',
        photo: '',
        role: '',
        id: '',
      ),
    );

    provideDummy<BaseResponse<DriverEntity>>(
      ErrorBaseResponse<DriverEntity>('dummy'),
    );
  });
  late MockGetCountriesUseCase mockGetCountriesUseCase;
  late MockApplyUseCase mockApplyUseCase;
  late ApplyCubit cubit;

  setUp(() {
    mockGetCountriesUseCase = MockGetCountriesUseCase();
    mockApplyUseCase = MockApplyUseCase();

    cubit = ApplyCubit(
      getCountriesUseCase: mockGetCountriesUseCase,
      applyUseCase: mockApplyUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ApplyCubit', () {
    blocTest<ApplyCubit, ApplyState>(
      'emits loading then success when apply succeeds',
      build: () {
        when(mockApplyUseCase(any)).thenAnswer(
          (_) async => SuccessBaseResponse(
            DriverEntity(
              country: '',
              firstName: '',
              lastName: '',
              vehicleType: '',
              vehicleNumber: '',
              vehicleLicense: '',
              nid: '',
              nidImg: '',
              email: '',
              gender: '',
              phone: '',
              photo: '',
              role: '',
              id: '',
            ),
          ),
        );

        return cubit;
      },
      act: (cubit) => cubit.doIntent(ApplyDriverEvent(const SignUpRequest())),
      expect: () => [
        predicate<ApplyState>((s) => s.applyState.isLoading),
        predicate<ApplyState>(
          (s) => !s.applyState.isLoading && s.applyState.data != null,
        ),
      ],
    );

    blocTest<ApplyCubit, ApplyState>(
      'emits loading then error when apply fails',
      build: () {
        when(
          mockApplyUseCase(any),
        ).thenAnswer((_) async => ErrorBaseResponse('Server Error'));

        return cubit;
      },
      act: (cubit) => cubit.doIntent(ApplyDriverEvent(const SignUpRequest())),
      expect: () => [
        predicate<ApplyState>((s) => s.applyState.isLoading),
        predicate<ApplyState>(
          (s) => !s.applyState.isLoading && s.applyState.errorMessage != null,
        ),
      ],
    );

    test('should emit NavigateEvent when apply succeeds', () async {
      when(mockApplyUseCase(any)).thenAnswer(
        (_) async => SuccessBaseResponse(
          DriverEntity(
            country: '',
            firstName: '',
            lastName: '',
            vehicleType: '',
            vehicleNumber: '',
            vehicleLicense: '',
            nid: '',
            nidImg: '',
            email: '',
            gender: '',
            phone: '',
            photo: '',
            role: '',
            id: '',
          ),
        ),
      );

      await cubit.doIntent(ApplyDriverEvent(const SignUpRequest()));

      final event = await cubit.eventStream.first;

      expect(event, isA<NavigateEvent>());

      expect((event as NavigateEvent).routeName, AppRoutes.submit);
    });

    test('should emit DisplayErrorEvent when apply fails', () async {
      when(
        mockApplyUseCase(any),
      ).thenAnswer((_) async => ErrorBaseResponse('Server Error'));

      await cubit.doIntent(ApplyDriverEvent(const SignUpRequest()));

      final event = await cubit.eventStream.first;

      expect(event, isA<DisplayErrorEvent>());
    });
  });
}
