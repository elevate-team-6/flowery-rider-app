import 'dart:async';

import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/widgets/custom_text_field.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_events.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'reset_password_screen_test.mocks.dart';

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
        child: const ResetPasswordScreen(email: tEmail),
      ),
    );
  }

  group('ResetPasswordScreen Widget Tests', () {
    testWidgets('renders both password fields and continue button', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text(AppStrings.resetPasswordTitle), findsOneWidget);
      expect(find.byType(CustomTextField), findsNWidgets(2));
      expect(find.text(AppStrings.newPassword), findsOneWidget);
      expect(find.text(AppStrings.confirmPassword), findsWidgets);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.text(AppStrings.continueText),
        ),
        findsOneWidget,
      );
    });

    testWidgets(
      'calls resetPassword when valid matching passwords are submitted',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        final passwordFields = find.byType(CustomTextField);
        await tester.enterText(passwordFields.at(0), 'Password123!');
        await tester.enterText(passwordFields.at(1), 'Password123!');
        await tester.pump();

        await tester.tap(
          find.ancestor(
            of: find.text(AppStrings.continueText),
            matching: find.byType(ElevatedButton),
          ),
        );
        await tester.pump();

        verify(mockCubit.doEvent(argThat(isA<ResetPasswordEvent>()))).called(1);
      },
    );

    testWidgets('shows validation error when passwords do not match', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final passwordFields = find.byType(CustomTextField);
      await tester.enterText(passwordFields.at(0), 'Password123!');
      await tester.enterText(passwordFields.at(1), 'Different123!');
      await tester.pump();

      await tester.tap(
        find.ancestor(
          of: find.text(AppStrings.continueText),
          matching: find.byType(ElevatedButton),
        ),
      );
      await tester.pump();

      verifyNever(mockCubit.doEvent(argThat(isA<ResetPasswordEvent>())));
    });
  });
}
