import 'package:bloc_test/bloc_test.dart';
import 'package:flowery_rider_app/config/base_response/base_response.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/features/auth/domain/entities/forget_password_entity.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/forget_password_use_case.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:flowery_rider_app/features/auth/domain/use_cases/verify_reset_code_use_case.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_events.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'forget_password_cubit_test.mocks.dart';

@GenerateMocks([
  ForgetPasswordUseCase,
  VerifyResetCodeUseCase,
  ResetPasswordUseCase,
])
void main() {
  provideDummy<BaseResponse<ForgetPasswordEntity>>(SuccessBaseResponse(null));

  late ForgetPasswordCubit cubit;
  late MockForgetPasswordUseCase mockForgetPasswordUseCase;
  late MockVerifyResetCodeUseCase mockVerifyResetCodeUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;

  setUp(() {
    mockForgetPasswordUseCase = MockForgetPasswordUseCase();
    mockVerifyResetCodeUseCase = MockVerifyResetCodeUseCase();
    mockResetPasswordUseCase = MockResetPasswordUseCase();
    cubit = ForgetPasswordCubit(
      forgetPasswordUseCase: mockForgetPasswordUseCase,
      resetPasswordUseCase: mockResetPasswordUseCase,
      verifyResetCodeUseCase: mockVerifyResetCodeUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('ForgetPasswordCubit - forgotPassword tests', () {
    const tEmail = 'test@example.com';
    const tEntity = ForgetPasswordEntity(message: 'OTP sent');

    blocTest<ForgetPasswordCubit, ForgetPasswordState>(
      'should emit loading then success states when forgotPassword succeeds',
      build: () {
        when(
          mockForgetPasswordUseCase.call(email: anyNamed('email')),
        ).thenAnswer((_) async => SuccessBaseResponse(tEntity));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(ForgetPasswordEvent(email: tEmail)),
      expect: () => [
        isA<ForgetPasswordState>().having(
          (s) => s.forgotPasswordState.isLoading,
          'isLoading',
          true,
        ),
        isA<ForgetPasswordState>().having(
          (s) => s.forgotPasswordState.isLoading,
          'isLoading',
          false,
        ),
      ],
      verify: (cubit) {
        verify(mockForgetPasswordUseCase.call(email: tEmail)).called(1);
      },
    );

    test(
      'should emit NavigateEvent and DisplaySuccessEvent on success',
      () async {
        when(
          mockForgetPasswordUseCase.call(email: anyNamed('email')),
        ).thenAnswer((_) async => SuccessBaseResponse(tEntity));

        final events = [];
        cubit.eventStream.listen((event) => events.add(event));

        cubit.doEvent(ForgetPasswordEvent(email: tEmail));

        await Future.delayed(Duration.zero);

        expect(
          events,
          contains(
            isA<NavigateEvent>().having(
              (e) => e.routeName,
              'routeName',
              AppRoutes.verifyResetCode,
            ),
          ),
        );
        expect(events, contains(isA<DisplaySuccessEvent>()));
      },
    );

    blocTest<ForgetPasswordCubit, ForgetPasswordState>(
      'should emit loading then success states and error UI event when forgotPassword fails',
      build: () {
        when(
          mockForgetPasswordUseCase.call(email: anyNamed('email')),
        ).thenAnswer((_) async => ErrorBaseResponse('Invalid email'));
        return cubit;
      },
      act: (cubit) => cubit.doEvent(ForgetPasswordEvent(email: tEmail)),
      expect: () => [
        isA<ForgetPasswordState>().having(
          (s) => s.forgotPasswordState.isLoading,
          'isLoading',
          true,
        ),
        isA<ForgetPasswordState>().having(
          (s) => s.forgotPasswordState.isLoading,
          'isLoading',
          false,
        ),
      ],
    );
  });

  group('ForgetPasswordCubit - verifyResetCode tests', () {
    const tCode = '123456';
    const tEmail = 'test@example.com';
    const tEntity = ForgetPasswordEntity(message: 'Code correct');

    blocTest<ForgetPasswordCubit, ForgetPasswordState>(
      'should emit loading then success states when verifyResetCode succeeds',
      build: () {
        when(
          mockVerifyResetCodeUseCase.call(resetCode: anyNamed('resetCode')),
        ).thenAnswer((_) async => SuccessBaseResponse(tEntity));
        return cubit;
      },
      act: (cubit) =>
          cubit.doEvent(VerifyResetCodeEvent(resetCode: tCode, email: tEmail)),
      expect: () => [
        isA<ForgetPasswordState>().having(
          (s) => s.verifyResetCodeState.isLoading,
          'isLoading',
          true,
        ),
        isA<ForgetPasswordState>().having(
          (s) => s.verifyResetCodeState.isLoading,
          'isLoading',
          false,
        ),
      ],
    );

    test(
      'should emit NavigateEvent and DisplaySuccessEvent on success',
      () async {
        when(
          mockVerifyResetCodeUseCase.call(resetCode: anyNamed('resetCode')),
        ).thenAnswer((_) async => SuccessBaseResponse(tEntity));

        final events = [];
        cubit.eventStream.listen((event) => events.add(event));

        cubit.doEvent(VerifyResetCodeEvent(resetCode: tCode, email: tEmail));

        await Future.delayed(Duration.zero);

        expect(
          events,
          contains(
            isA<NavigateEvent>().having(
              (e) => e.routeName,
              'routeName',
              AppRoutes.resetPassword,
            ),
          ),
        );
        expect(events, contains(isA<DisplaySuccessEvent>()));
      },
    );
  });

  group('ForgetPasswordCubit - resetPassword tests', () {
    const tEmail = 'test@example.com';
    const tPass = 'newPassword123';
    const tEntity = ForgetPasswordEntity(message: 'Password reset');

    blocTest<ForgetPasswordCubit, ForgetPasswordState>(
      'should emit loading then success states when resetPassword succeeds',
      build: () {
        when(
          mockResetPasswordUseCase.call(
            email: anyNamed('email'),
            newPassword: anyNamed('newPassword'),
          ),
        ).thenAnswer((_) async => SuccessBaseResponse(tEntity));
        return cubit;
      },
      act: (cubit) =>
          cubit.doEvent(ResetPasswordEvent(newPassword: tPass, email: tEmail)),
      expect: () => [
        isA<ForgetPasswordState>().having(
          (s) => s.resetPasswordState.isLoading,
          'isLoading',
          true,
        ),
        isA<ForgetPasswordState>().having(
          (s) => s.resetPasswordState.isLoading,
          'isLoading',
          false,
        ),
      ],
    );

    test('should emit NavigateEvent to login on success', () async {
      when(
        mockResetPasswordUseCase.call(
          email: anyNamed('email'),
          newPassword: anyNamed('newPassword'),
        ),
      ).thenAnswer((_) async => SuccessBaseResponse(tEntity));

      final events = [];
      cubit.eventStream.listen((event) => events.add(event));

      cubit.doEvent(ResetPasswordEvent(newPassword: tPass, email: tEmail));

      await Future.delayed(Duration.zero);

      expect(
        events,
        contains(
          isA<NavigateEvent>().having(
            (e) => e.routeName,
            'routeName',
            AppRoutes.login,
          ),
        ),
      );
    });
  });
}
