import 'dart:async';

import 'package:flowery_rider_app/config/base_ui_event/base_ui_event.dart';
import 'package:flowery_rider_app/core/utils/app_routes.dart';
import 'package:flowery_rider_app/core/utils/app_strings.dart';
import 'package:flowery_rider_app/core/widgets/custom_text_field.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/widgets/email_step_widget.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/widgets/otp_step_widget.dart';
import 'package:flowery_rider_app/features/auth/presentation/screens/widgets/reset_password_step_widget.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_cubit.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_events.dart';
import 'package:flowery_rider_app/features/auth/presentation/view_model/forget_password_view_model/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'forget_password_screen_test.mocks.dart';

@GenerateMocks([ForgetPasswordCubit])
void main() {
  late MockForgetPasswordCubit mockCubit;
  late StreamController<BaseUiEvent> eventController;

  setUp(() {
    mockCubit = MockForgetPasswordCubit();
    eventController = StreamController<BaseUiEvent>.broadcast();

    when(mockCubit.state).thenReturn(const ForgetPasswordState());
    when(
      mockCubit.stream,
    ).thenAnswer((_) => const Stream<ForgetPasswordState>.empty());
    when(mockCubit.eventStream).thenAnswer((_) => eventController.stream);
    when(mockCubit.close()).thenAnswer((_) async => {});

    // Set a consistent screen size for tests to avoid overflows
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.platformDispatcher.views.first.physicalSize = const Size(
      1080,
      2400,
    );
    binding.platformDispatcher.views.first.devicePixelRatio = 1.0;
  });

  tearDown(() {
    eventController.close();
  });

  Widget createWidgetUnderTest() {
    return ScreenUtilInit(
      designSize: const Size(1080, 2400),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => MaterialApp(
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => BlocProvider<ForgetPasswordCubit>.value(
              value: mockCubit,
              child: const ForgotPasswordScreen(),
            ),
          );
        },
      ),
    );
  }

  group('ForgotPasswordScreen Flow Tests', () {
    testWidgets('starts with EmailStepWidget and navigates to OtpStepWidget', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Initial Step: Email
      expect(find.byType(EmailStepWidget), findsOneWidget);
      expect(find.text(AppStrings.forgetPasswordTitle), findsOneWidget);

      // Simulate success event for email submission
      eventController.add(
        NavigateEvent(AppRoutes.verifyResetCode, arguments: 'test@example.com'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Should navigate to OTP Step
      expect(find.byType(OtpStepWidget), findsOneWidget);
      expect(find.text(AppStrings.emailVerification), findsOneWidget);
    });

    testWidgets('navigates from OtpStepWidget to ResetPasswordStepWidget', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Move to OTP Step
      eventController.add(
        NavigateEvent(AppRoutes.verifyResetCode, arguments: 'test@example.com'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Simulate success event for OTP verification
      eventController.add(
        NavigateEvent(AppRoutes.resetPassword, arguments: 'test@example.com'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Should navigate to Reset Password Step
      expect(find.byType(ResetPasswordStepWidget), findsOneWidget);
      expect(find.text(AppStrings.resetPasswordTitle), findsOneWidget);
    });

    testWidgets('back button navigates to previous step', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Move to OTP Step
      eventController.add(
        NavigateEvent(AppRoutes.verifyResetCode, arguments: 'test@example.com'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(OtpStepWidget), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Should be back to Email Step
      expect(find.byType(EmailStepWidget), findsOneWidget);
    });
  });

  group('Step Widgets Individual Tests', () {
    testWidgets('EmailStepWidget calls doEvent on confirm', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1080, 2400),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) => MaterialApp(
            home: BlocProvider<ForgetPasswordCubit>.value(
              value: mockCubit,
              child: const Scaffold(body: EmailStepWidget()),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.confirm));
      await tester.pump();

      verify(mockCubit.doEvent(argThat(isA<ForgetPasswordEvent>()))).called(1);
    });

    testWidgets('OtpStepWidget calls doEvent on completed PIN', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1080, 2400),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) => MaterialApp(
            home: BlocProvider<ForgetPasswordCubit>.value(
              value: mockCubit,
              child: const Scaffold(
                body: OtpStepWidget(email: 'test@example.com'),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(PinCodeTextField), '123456');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      verify(mockCubit.doEvent(argThat(isA<VerifyResetCodeEvent>()))).called(1);
    });

    testWidgets('ResetPasswordStepWidget calls doEvent on continue', (
      tester,
    ) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(1080, 2400),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) => MaterialApp(
            home: BlocProvider<ForgetPasswordCubit>.value(
              value: mockCubit,
              child: const Scaffold(
                body: ResetPasswordStepWidget(email: 'test@example.com'),
              ),
            ),
          ),
        ),
      );

      final passwordFields = find.byType(CustomTextField);
      await tester.enterText(passwordFields.at(0), 'Password123!');
      await tester.enterText(passwordFields.at(1), 'Password123!');
      await tester.pump();

      await tester.tap(
        find.widgetWithText(ElevatedButton, AppStrings.continueText),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      verify(mockCubit.doEvent(argThat(isA<ResetPasswordEvent>()))).called(1);
    });
  });
}
