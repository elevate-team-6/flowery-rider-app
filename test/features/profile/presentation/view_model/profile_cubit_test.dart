import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/mockito.dart' as mockito;

import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/features/profile/domain/entities/driver_entity.dart';
import 'package:flowery_rider_app/features/profile/domain/use_cases/logout_use_case.dart';
import 'package:flowery_rider_app/features/profile/domain/use_cases/profile_use_case.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/profile_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/profile_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/profile_states.dart';

import 'profile_cubit_test.mocks.dart';

@GenerateMocks([LogoutUseCase, ProfileUseCase])
void main() {
  late MockLogoutUseCase mockLogoutUseCase;
  late MockProfileUseCase mockProfileUseCase;
  late ProfileCubit cubit;

  setUpAll(() {
    mockito.provideDummy<BaseResponse<void>>(ErrorBaseResponse<void>('dummy'));

    mockito.provideDummy<BaseResponse<DriverEntity>>(
      ErrorBaseResponse<DriverEntity>('dummy'),
    );
  });

  setUp(() {
    mockLogoutUseCase = MockLogoutUseCase();
    mockProfileUseCase = MockProfileUseCase();

    cubit = ProfileCubit(mockLogoutUseCase, mockProfileUseCase);
  });

  tearDown(() async {
    await cubit.close();
  });

  group('Get Profile', () {
    blocTest<ProfileCubit, ProfileStates>(
      'should emit loading then success state when profile succeeds',
      build: () {
        when(mockProfileUseCase.call()).thenAnswer(
          (_) async => SuccessBaseResponse<DriverEntity>(
            const DriverEntity(firstName: 'Ahmed', lastName: 'Ali'),
          ),
        );

        return cubit;
      },
      act: (cubit) {
        cubit.doEvent(const GetProfileEvent());
      },
      expect: () => [
        const ProfileStates(profileState: BaseState(isLoading: true)),
        const ProfileStates(
          profileState: BaseState(
            data: DriverEntity(firstName: 'Ahmed', lastName: 'Ali'),
          ),
        ),
      ],
      verify: (_) {
        verify(mockProfileUseCase.call()).called(1);
      },
    );

    blocTest<ProfileCubit, ProfileStates>(
      'should emit loading then empty state when profile fails',
      build: () {
        when(mockProfileUseCase.call()).thenAnswer(
          (_) async => ErrorBaseResponse<DriverEntity>('server error'),
        );

        return cubit;
      },
      act: (cubit) {
        cubit.doEvent(const GetProfileEvent());
      },
      expect: () => [
        const ProfileStates(profileState: BaseState(isLoading: true)),
        const ProfileStates(profileState: BaseState()),
      ],
      verify: (_) {
        verify(mockProfileUseCase.call()).called(1);
      },
    );
  });

  group('Logout', () {
    blocTest<ProfileCubit, ProfileStates>(
      'should emit loading then idle when logout succeeds',
      build: () {
        when(
          mockLogoutUseCase.call(),
        ).thenAnswer((_) async => SuccessBaseResponse<void>(null));

        return cubit;
      },
      act: (cubit) {
        cubit.doEvent(const LogoutEvent());
      },
      expect: () => [
        const ProfileStates(logoutState: BaseState(isLoading: true)),
        const ProfileStates(logoutState: BaseState()),
      ],
      verify: (_) {
        verify(mockLogoutUseCase.call()).called(1);
      },
    );

    blocTest<ProfileCubit, ProfileStates>(
      'should emit loading then idle when logout fails',
      build: () {
        when(
          mockLogoutUseCase.call(),
        ).thenAnswer((_) async => ErrorBaseResponse<void>('logout error'));

        return cubit;
      },
      act: (cubit) {
        cubit.doEvent(const LogoutEvent());
      },
      expect: () => [
        const ProfileStates(logoutState: BaseState(isLoading: true)),
        const ProfileStates(logoutState: BaseState()),
      ],
      verify: (_) {
        verify(mockLogoutUseCase.call()).called(1);
      },
    );
  });
}
