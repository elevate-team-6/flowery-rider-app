import 'dart:async';

import 'package:flowery_rider_app/config/base_state/base_state.dart';
import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/verify_reset_code_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_events.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'verify_reset_code_screen_test.mocks.dart';

@GenerateMocks([ForgetPasswordCubit])
void main() {
  late MockForgetPasswordCubit mockCubit;
  late StreamController<BaseUiEvent> eventController;
  const tEmail = 'test@example.com';

  setUp(() {
    mockCubit = MockForgetPasswordCubit();
    eventController = StreamController<BaseUiEvent>.broadcast();

    when(mockCubit.state).thenReturn(const ForgetPasswordState());
    when(
      mockCubit.stream,
    ).thenAnswer((_) => const Stream<ForgetPasswordState>.empty());
    when(mockCubit.eventStream).thenAnswer((_) => eventController.stream);
    when(mockCubit.close()).thenAnswer((_) async => {});
  });

  tearDown(() {
    eventController.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<ForgetPasswordCubit>.value(
        value: mockCubit,
        child: const VerifyResetCodeScreen(email: tEmail),
      ),
    );
  }

  group('VerifyResetCodeScreen Widget Tests', () {
    testWidgets('renders PIN fields and email text correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text(AppStrings.emailVerification), findsOneWidget);
      expect(find.byType(PinCodeTextField), findsOneWidget);
      expect(
        find.textContaining(AppStrings.resend, findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('calls verifyResetCode when PIN is fully entered', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(PinCodeTextField), '123456');
      await tester.pump(const Duration(milliseconds: 300));

      verify(mockCubit.doEvent(argThat(isA<VerifyResetCodeEvent>()))).called(1);
    });

    testWidgets('shows error UI when state has an error message', (
      tester,
    ) async {
      final errorState = ForgetPasswordState(
        verifyResetCodeState: BaseState(errorMessage: 'Invalid OTP'),
      );
      when(mockCubit.state).thenReturn(errorState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Invalid OTP'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('calls resend event when clicking resend link', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final resendRichText = find.textContaining(
        AppStrings.resend,
        findRichText: true,
      );
      final rect = tester.getRect(resendRichText);
      await tester.tapAt(Offset(rect.right - 5, rect.center.dy));
      await tester.pump();

      verify(mockCubit.doEvent(argThat(isA<ForgetPasswordEvent>()))).called(1);
    });
  });
}
