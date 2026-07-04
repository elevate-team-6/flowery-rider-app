import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
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
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forget_password_screen_test.mocks.dart';

/// Serves translations from memory so `.tr()` is deterministic without touching
/// the asset bundle. An empty map makes `.tr()` echo the key back, which is
/// exactly what the `find.text(AppStrings.*)` assertions expect.
class _InMemoryAssetLoader extends AssetLoader {
  const _InMemoryAssetLoader(this._data);

  final Map<String, Map<String, dynamic>> _data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      _data[locale.languageCode] ?? const {};
}

@GenerateMocks([ForgetPasswordCubit])
void main() {
  late MockForgetPasswordCubit mockCubit;
  late StreamController<BaseUiEvent> eventController;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

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

  /// Wraps [home] in an initialized EasyLocalization + MaterialApp so `.tr()`
  /// resolves deterministically across platforms (uninitialized `.tr()` behaves
  /// differently between package versions, which broke this suite on CI).
  Widget wrapApp(Widget home) {
    return EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      assetLoader: const _InMemoryAssetLoader({'en': <String, dynamic>{}}),
      child: Builder(
        builder: (context) => MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: home,
        ),
      ),
    );
  }

  Widget createWidgetUnderTest() {
    return wrapApp(
      BlocProvider<ForgetPasswordCubit>.value(
        value: mockCubit,
        child: const ForgotPasswordScreen(),
      ),
    );
  }

  group('ForgotPasswordScreen Flow Tests', () {
    testWidgets('starts with EmailStepWidget and navigates to OtpStepWidget', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Initial Step: Email
      expect(find.byType(EmailStepWidget), findsOneWidget);
      expect(find.text(AppStrings.forgetPasswordTitle), findsOneWidget);

      // Simulate success event for email submission
      eventController.add(
        NavigateEvent(AppRoutes.verifyResetCode, arguments: 'test@example.com'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 10));

      // Should navigate to OTP Step
      expect(find.byType(OtpStepWidget), findsOneWidget);
      expect(find.text(AppStrings.emailVerification), findsOneWidget);
    });

    testWidgets('navigates from OtpStepWidget to ResetPasswordStepWidget', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Move to OTP Step
      eventController.add(
        NavigateEvent(AppRoutes.verifyResetCode, arguments: 'test@example.com'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 10));

      // Simulate success event for OTP verification
      eventController.add(
        NavigateEvent(AppRoutes.resetPassword, arguments: 'test@example.com'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 10));

      // Should navigate to Reset Password Step
      expect(find.byType(ResetPasswordStepWidget), findsOneWidget);
      expect(find.text(AppStrings.resetPasswordTitle), findsOneWidget);
    });

    testWidgets('back button navigates to previous step', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Move to OTP Step
      eventController.add(
        NavigateEvent(AppRoutes.verifyResetCode, arguments: 'test@example.com'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 10));
      expect(find.byType(OtpStepWidget), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 10));

      // Should be back to Email Step
      expect(find.byType(EmailStepWidget), findsOneWidget);
    });
  });

  group('Step Widgets Individual Tests', () {
    testWidgets('EmailStepWidget calls doEvent on confirm', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          BlocProvider<ForgetPasswordCubit>.value(
            value: mockCubit,
            child: const Scaffold(body: EmailStepWidget()),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.tap(find.widgetWithText(ElevatedButton, AppStrings.confirm));
      await tester.pump();

      verify(mockCubit.doEvent(argThat(isA<ForgetPasswordEvent>()))).called(1);
    });

    testWidgets('OtpStepWidget calls doEvent on completed PIN', (tester) async {
      await tester.pumpWidget(
        wrapApp(
          BlocProvider<ForgetPasswordCubit>.value(
            value: mockCubit,
            child: const Scaffold(
              body: OtpStepWidget(email: 'test@example.com'),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.enterText(find.byType(PinCodeTextField), '123456');
      await tester.pump(const Duration(milliseconds: 300));

      verify(mockCubit.doEvent(argThat(isA<VerifyResetCodeEvent>()))).called(1);
    });

    testWidgets('ResetPasswordStepWidget calls doEvent on continue', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapApp(
          BlocProvider<ForgetPasswordCubit>.value(
            value: mockCubit,
            child: const Scaffold(
              body: ResetPasswordStepWidget(email: 'test@example.com'),
            ),
          ),
        ),
      );
      await tester.pump();

      final passwordFields = find.byType(CustomTextField);
      await tester.enterText(passwordFields.at(0), 'Password123!');
      await tester.enterText(passwordFields.at(1), 'Password123!');
      await tester.pump();

      await tester.tap(
        find.widgetWithText(ElevatedButton, AppStrings.continueText),
      );
      await tester.pump();

      verify(mockCubit.doEvent(argThat(isA<ResetPasswordEvent>()))).called(1);
    });
  });
}
