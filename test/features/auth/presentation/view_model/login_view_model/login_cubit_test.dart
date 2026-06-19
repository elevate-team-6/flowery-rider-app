import 'package:bloc_test/bloc_test.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/cache/secure_cache_helper.dart';
import 'package:flowery_rider_app/core/utils/app_keys.dart';
import 'package:flowery_rider_app/features/auth/data/models/request/sign_in_request_model.dart';
import 'package:flowery_rider_app/features/auth/domain/entites/sign_in_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_cubit.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_event.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/login_view_model/login_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_cubit_test.mocks.dart';

@GenerateMocks([SignInUseCase, SecureCacheHelper])
void main() {
  late MockSignInUseCase mockUseCase;
  late MockSecureCacheHelper mockCache;
  late LoginCubit cubit;

  const request = SignInRequestModel(
    email: 'test@test.com',
    password: 'Ahmed@123',
  );

  const fakeEntity = SignInEntity(message: 'success', token: 'fake_token');

  setUp(() {
    mockUseCase = MockSignInUseCase();
    mockCache = MockSecureCacheHelper();
    cubit = LoginCubit(mockUseCase, mockCache);

    provideDummy<BaseResponse<SignInEntity>>(ErrorBaseResponse('dummy'));
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  group('TogglePasswordVisibilityEvent', () {
    blocTest<LoginCubit, LoginState>(
      'toggles obscurePassword from true to false',
      build: () => cubit,
      act: (cubit) => cubit.doIntent(const TogglePasswordVisibilityEvent()),
      expect: () => [
        isA<LoginState>().having(
          (s) => s.obscurePassword,
          'obscurePassword',
          false,
        ),
      ],
    );
  });

  group('ToggleRememberMeEvent', () {
    blocTest<LoginCubit, LoginState>(
      'emits rememberMe true',
      build: () => cubit,
      act: (cubit) => cubit.doIntent(const ToggleRememberMeEvent(true)),
      expect: () => [
        isA<LoginState>().having((s) => s.rememberMe, 'rememberMe', true),
      ],
    );
  });

  group('LoadRememberedEmailEvent', () {
    test(
      'restores checkbox and emits fill text field event when remember me is on',
      () async {
        when(
          mockCache.readData(key: AppKeys.rememberMeKey),
        ).thenAnswer((_) async => 'true');
        when(
          mockCache.readData(key: AppKeys.emailKey),
        ).thenAnswer((_) async => 'test@test.com');

        final stateExpectation = expectLater(
          cubit.stream,
          emits(
            isA<LoginState>().having((s) => s.rememberMe, 'rememberMe', true),
          ),
        );
        final eventExpectation = expectLater(
          cubit.eventStream,
          emits(
            isA<FillTextFieldEvent>().having(
              (e) => e.text,
              'text',
              'test@test.com',
            ),
          ),
        );

        cubit.doIntent(const LoadRememberedEmailEvent());
        await Future.wait([stateExpectation, eventExpectation]);
      },
    );

    blocTest<LoginCubit, LoginState>(
      'emits nothing when remember me is off',
      setUp: () {
        when(
          mockCache.readData(key: AppKeys.rememberMeKey),
        ).thenAnswer((_) async => null);
      },
      build: () => cubit,
      act: (cubit) => cubit.doIntent(const LoadRememberedEmailEvent()),
      expect: () => [],
    );
  });

  group('LoginEvent', () {
    test(
      'emits loading then success side effects on valid credentials',
      () async {
        when(
          mockUseCase(request),
        ).thenAnswer((_) async => SuccessBaseResponse(fakeEntity));
        when(
          mockCache.writeData(key: anyNamed('key'), value: anyNamed('value')),
        ).thenAnswer((_) async {});
        when(
          mockCache.deleteData(key: anyNamed('key')),
        ).thenAnswer((_) async {});

        final expectation = expectLater(
          cubit.eventStream,
          emitsInOrder([
            isA<ShowLoadingEvent>(),
            isA<HideLoadingEvent>(),
            isA<DisplaySuccessEvent>(),
            isA<NavigateEvent>(),
          ]),
        );

        cubit.doIntent(const LoginEvent(request));
        await expectation;

        verify(
          mockCache.writeData(key: AppKeys.tokenKey, value: 'fake_token'),
        ).called(1);
      },
    );

    test(
      'emits loading then failure side effects on wrong credentials',
      () async {
        when(
          mockUseCase(request),
        ).thenAnswer((_) async => ErrorBaseResponse('invalid credentials'));

        final expectation = expectLater(
          cubit.eventStream,
          emitsInOrder([
            isA<ShowLoadingEvent>(),
            isA<HideLoadingEvent>(),
            isA<DisplayErrorEvent>().having(
              (e) => e.errorMessage,
              'errorMessage',
              'invalid credentials',
            ),
          ]),
        );

        cubit.doIntent(const LoginEvent(request));
        await expectation;
      },
    );
  });
}
