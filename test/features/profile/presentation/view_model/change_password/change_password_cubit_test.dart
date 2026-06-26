import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_cubit.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_events.dart';
import 'package:flowery_rider_app/features/profile/presentation/view_model/change_password/change_password_states.dart';

import 'change_password_cubit_test.mocks.dart';
@GenerateMocks([
  ChangePasswordUseCase,
  SecureCacheHelper,
])
void main() {
    setUpAll(() {
    provideDummy<BaseResponse<String>>(
      SuccessBaseResponse<String>('dummy_token'),
    );

    provideDummy<BaseResponse<void>>(
      SuccessBaseResponse<void>(null),
    );
  });
  late MockChangePasswordUseCase useCase;
  late MockSecureCacheHelper secureCacheHelper;
  late ChangePasswordCubit cubit;

  setUp(() {
    useCase = MockChangePasswordUseCase();
    secureCacheHelper = MockSecureCacheHelper();

    cubit = ChangePasswordCubit(
      useCase,
      secureCacheHelper,
    );
  });

  blocTest<ChangePasswordCubit, ChangePasswordState>(
    'emits loading then success when password changed successfully',
    build: () {
      when(
        useCase('oldPass', 'newPass'),
      ).thenAnswer(
        (_) async => SuccessBaseResponse<String>(
         'new_token',
        ),
      );

      when(
        secureCacheHelper.writeData(
          key: anyNamed('key'),
          value: anyNamed('value'),
        ),
      ).thenAnswer((_) async {});

      return cubit;
    },
    act: (cubit) async {
      await cubit.doIntent(
        const SubmitChangePasswordEvent(
          currentPassword: 'oldPass',
          newPassword: 'newPass',
        ),
      );
    },
    expect: () => [
      const ChangePasswordState(
        changePasswordState: BaseState(isLoading: true),
      ),
      const ChangePasswordState(
        changePasswordState: BaseState(),
      ),
    ],
    verify: (_) {
      verify(useCase('oldPass', 'newPass')).called(1);

      verify(
        secureCacheHelper.writeData(
          key: AppKeys.tokenKey,
          value: 'new_token',
        ),
      ).called(1);
    },
  );

  test(
  'emits DisplaySuccessEvent when password changed successfully',
  () async {
    when(
      useCase('oldPass', 'newPass'),
    ).thenAnswer(
      (_) async => SuccessBaseResponse<String>(
        'new_token',
      ),
    );

    when(
      secureCacheHelper.writeData(
        key: anyNamed('key'),
        value: anyNamed('value'),
      ),
    ).thenAnswer((_) async {});

    final expectation = expectLater(
      cubit.eventStream,
      emits(
        isA<DisplaySuccessEvent>(),
      ),
    );

    await cubit.doIntent(
      const SubmitChangePasswordEvent(
        currentPassword: 'oldPass',
        newPassword: 'newPass',
      ),
    );

    await expectation;
  },
);

  blocTest<ChangePasswordCubit, ChangePasswordState>(
    'emits loading then error when usecase fails',
    build: () {
      when(
        useCase('oldPass', 'newPass'),
      ).thenAnswer(
        (_) async => ErrorBaseResponse<String>(
          'wrong password',
        ),
      );

      return cubit;
    },
    act: (cubit) async {
      await cubit.doIntent(
        const SubmitChangePasswordEvent(
          currentPassword: 'oldPass',
          newPassword: 'newPass',
        ),
      );
    },
    expect: () => [
      const ChangePasswordState(
        changePasswordState: BaseState(isLoading: true),
      ),
      const ChangePasswordState(
        changePasswordState: BaseState(
          errorMessage: 'wrong password',
        ),
      ),
    ],
  );

  test(
  'emits DisplayErrorEvent when usecase fails',
  () async {
    when(
      useCase('oldPass', 'newPass'),
    ).thenAnswer(
      (_) async => ErrorBaseResponse<String>(
        'wrong password',
      ),
    );

    final expectation = expectLater(
      cubit.eventStream,
      emits(
        isA<DisplayErrorEvent>(),
      ),
    );

    await cubit.doIntent(
      const SubmitChangePasswordEvent(
        currentPassword: 'oldPass',
        newPassword: 'newPass',
      ),
    );

    await expectation;
  },
);

}